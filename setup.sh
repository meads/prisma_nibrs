#!/usr/bin/env bash

set -e

function say {
# say @b@green[[Success]] 
     echo "$@" | sed \
             -e "s/\(\(@\(red\|green\|yellow\|blue\|magenta\|cyan\|white\|reset\|b\|u\)\)\+\)[[]\{2\}\(.*\)[]]\{2\}/\1\4@reset/g" \
             -e "s/@red/$(tput setaf 1)/g" \
             -e "s/@green/$(tput setaf 2)/g" \
             -e "s/@yellow/$(tput setaf 3)/g" \
             -e "s/@blue/$(tput setaf 4)/g" \
             -e "s/@magenta/$(tput setaf 5)/g" \
             -e "s/@cyan/$(tput setaf 6)/g" \
             -e "s/@white/$(tput setaf 7)/g" \
             -e "s/@reset/$(tput sgr0)/g" \
             -e "s/@b/$(tput bold)/g" \
             -e "s/@u/$(tput sgr 0 1)/g"
}
function echo_ok {
    echo
    say @b@green[[$1]]
    echo
}
function echo_err {
    echo
    say @b@red[[$1]]
    echo
}
function echo_warn {
    echo
    say @b@yellow[[$1]]
    echo
}
function echo_info {
  echo
  say @b@reset[[$1]]
  echo
}


echo_warn "$(pwd)"

# 0 = true so setting to 1 once cleanup is done
temp_file_cleanup_needed=0

function handle_err {
    echo_warn "ERROR handler called."
    local errors=''
    if [ -a $errorlog ]; then
        errors=$(cat $errorlog)
    fi
    if [ ${#errors} -ne 0 ]; then
        echo_err "$errors"
    fi

    if [ $temp_file_cleanup_needed -eq 0 ]; then
        echo_warn "Removing error log."
        rm -f $errorlog
        temp_file_cleanup_needed=1
    fi    
}

function handle_exit {
    echo_info "EXIT handler called."
    local errors=''
    if [ -a $errorlog ]; then
        errors=$(cat $errorlog)
    fi
    if [ ${#errors} -ne 0 ]; then
        echo_err "$errors"
    fi
    if [ $temp_file_cleanup_needed -eq 0 ]; then
        echo_err "Removing error log."
        rm -f $errorlog
        temp_file_cleanup_needed=1
    fi
}

trap handle_err ERR
trap handle_exit EXIT

if [ "$(whoami)" != "postgres" ]; then
    echo_warn "Oops this needs to be run again as 'postgres' user."
    echo_info "sudo su postgres"
    exit 1
fi

database=nibrs_data
errorlog=$(mktemp)
echo_info "$errorlog created"

function psql_exec_file {
    local opts="--echo-errors --echo-queries"
    # local opts="--quiet"
    echo_info "Executing: $1"
    echo_info "psql $opts $2 -f $3 2>$errorlog"
    psql $opts $2 -f $3 2>$errorlog
    if [[ 0 -ne $? ]]; then
        echo_err "Failed: $1, Exit status: $?"
        return 1
    fi
    echo_ok "Succeeded: $1, Exit status: $?"
}

# run scripts for postgreSQL setup etc.
if [ "$( psql -tAc "SELECT 1 FROM pg_database WHERE datname='$database'" )" = "1" ]; then
    echo_info "Database already exists"
    echo_info "Dropping database $database;"
    dropdb $database;
fi

echo_ok "Creating database $database."
psql -c "CREATE DATABASE $database;"
echo_ok "Sleeping for few seconds while database is created."

psql -c "ALTER USER postgres PASSWORD 'pass';"

# run scripts containing DDL and INSERT stmts.
pushd /var/local/data/STATES/LA
# data/STATES/LA
psql_exec_file "Creating database tables and relationships." $database ./postgres_setup.sql
psql_exec_file "Seeding the database..." $database ./postgres_load.sql
popd

working_dir="$(pwd)"

echo_info "Restore working directory '$working_dir'."

echo_info "Deleting $errorlog file."

rm -f $errorlog
temp_file_cleanup_needed=1

echo_ok "PostgreSQL Db Setup Complete!"
