introspect:
	npx prisma introspect
generate:
	npx prisma generate
db_migrate: introspect generate
code_watch:
	npx tsc -w
code_exec:
	node ./app/dist/main.js