start:
	docker-compose up -d
	sleep 2
	docker-compose exec postgres createdb 7dbs -U postgres
	docker-compose exec postgres psql 7dbs -U postgres -f /sql/day1.sql
	docker-compose exec postgres psql 7dbs -U postgres -f /sql/day2.sql

stop:
	docker-compose down -v --remove-orphans --rmi local
