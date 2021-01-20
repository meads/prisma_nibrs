# Prisma Example PostgreSQL

This is largely just a surface area to try out the Prisma library and interface with some existing data. The data is from (NIBRS) the national incident based reporting system, which are crime datasets made publicly available. I needed some existing database and thought eh let's make it interesting. Also this data is purported to be in 5th normal form. Ideally I would like to be able to reflect a GraphQL Schema definition from the model that was generated but that really depends on what data fields need to be exposed based on some client expectations.

## Setup

### System requirements
npm, docker-compose/docker

```bash
# 1. Install the npm dependencies.
npm install

# 2 Run docker-compose up to start the db instance and seed its' data.
make db_init 

# 3 In a separate shell tab run this command which causes the introspection and migrate prisma commands to be executed
make migrate

# 4 In a separate shell tab run this command which causes tsc to be called in watch mode 
# (may require a ctrl+s "save" in src/main.ts to initially generate the .js files)
make code_watch

# 5 In a separate shell tab execute the node script containing your prisma queries/backend code.
# (output is displayed in the console using console.table function 🧙‍♂️)
make code_exec
```

