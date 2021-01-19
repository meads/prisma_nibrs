_introspect:
	npx prisma _introspect
_generate:
	npx prisma _generate
_migrate: introspect _generate
code_watch:
	npx tsc -w
code_exec:
	node ./app/dist/main.js
db_init:
	./setup.sh
app_init:
	docker-compose up
clean_containers:
	sudo docker container stop $(docker container ls -aq)
