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

# 0 = true, basically verbose logging; 1 = false or little logging
verbose=1

function is_verbose_mode {
    [ $verbose -eq 0 ];
}

# 0 = true so setting to 1 once cleanup is done
temp_file_cleanup_needed=0

function handle_err {
    is_verbose_mode && echo_warn "ERROR handler called."
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
    is_verbose_mode && echo_info "EXIT handler called."
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
if is_verbose_mode ; then
    echo_info "${errorlog} created"
fi

function psql_exec_file {
    local opts=''
    echo_ok "${1}"
    if is_verbose_mode ; then
        opts="--echo-errors --echo-queries"
        echo_info "psql ${opts} ${2} -f ${3} 2>${errorlog}"
    else
        opts="--quiet"
    fi
    psql $opts $2 -f $3 2>$errorlog
    if [[ 0 -ne $? ]]; then
        echo_err "Failed: ${1}, Exit status: ${?}"
        return 1
    fi
    if is_verbose_mode ; then
        echo_ok "Succeeded: ${1}, Exit status: ${?}"
    fi
}

# run scripts for postgreSQL setup etc.
if [ "$( psql -tAc "SELECT 1 FROM pg_database WHERE datname='${database}'" )" = "1" ]; then
    if is_verbose_mode ; then
        echo_info "Database already exists"
        echo_info "Dropping database ${database};"
    fi
    dropdb "${database}";
fi

echo_ok "Creating database ${database}."
psql --quiet -c "CREATE DATABASE ${database};"
psql --quiet -c "ALTER USER postgres PASSWORD 'pass';"

# run scripts containing DDL and INSERT stmts.
pushd /nibrs/STATES/LA >/dev/null
psql_exec_file "Creating database tables and relationships." $database ./postgres_setup.sql
psql_exec_file "Seeding the database..." $database ./postgres_load.sql
popd >/dev/null

rm -f "${errorlog}"
temp_file_cleanup_needed=1

echo_ok "Setup Complete!"
