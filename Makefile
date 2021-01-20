introspect:
	npx prisma introspect
generate:
	npx prisma generate
migrate: introspect generate
code_watch:
	npx tsc -w
code_exec:
	node ./app/dist/main.js
db_init: clean_containers
	docker-compose up
clean_containers:
	echo "$$(docker ps -a | grep -E "prisma_nibrs" | awk '{print $$1}')" | xargs --no-run-if-empty docker rm -f 
	
