introspect:
	npx prisma introspect
generate:
	npx prisma generate
migrate: introspect generate
code_watch:
	npx tsc -w
code_exec:
	node ./app/dist/main.js
db_init:
	# the below line of code will remove the last running container
	# from the list and can be used in front of the below command for 
	# subequent runs by using logical and operator &&
	#   docker rm -f "$$(docker ps -a | awk 'NR == 2 {print $$1}')"
	sudo chown -R root:root data && docker-compose up
clean_containers:
	sudo docker container stop $$(docker container ls -aq)
