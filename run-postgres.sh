docker run -d \
    --network="host" \
    --name some-postgres \
    -e POSTGRES_PASSWORD=mysecretpassword \
    -e PGDATA=/var/lib/postgresql/data/pgdata \
    -v /:/var/lib/postgresql/data \
    -p 5432:5432 \
    postgres
