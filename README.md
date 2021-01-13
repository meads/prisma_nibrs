# Prisma Example PostgreSQL

This is largely just a surface area to try out the Prisma library and interface with some existing data. The data is from (NIBRS) the national incident based reporting system, which are crime datasets made publicly available. I needed some existing database and thought eh let's make it interesting. Also this data is purported to be in 5th normal form. Ideally I would like to be able to reflect a GraphQL Schema definition from the model that was generated but that really depends on what data fields need to be exposed based on some client expectations.

## Setup

```bash
# install dependencies (prisma and typescript essentially)
npm install

# requires a local postgres instance running with the connection string specified in the .env file. My connection is checked in so it is uncommented.
DATABASE_URL="postgresql://postgres:pass@localhost:5432/nibrs_data?schema=public"

# you can follow the setup instructions in the data/ directory if you have problems, but basic steps I have reduced it to are:

# 1 switch to the postgres user and call db_init target
sudo su postgres
make db_init
# press ctrl+d to exit or type exit

# 2 run prisma introspection and prisma model generation etc.
make db_migrate 

# 3 in one shell run watch command
make code_watch

# 4 in separate shell run exec node script command
make code_exec
```

