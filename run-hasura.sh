#! /bin/bash
docker run -d -p 7070:7070 \
       --network="host" \
       -e HASURA_GRAPHQL_DATABASE_URL=postgresql://postgres:mysecretpassword@localhost:5432/postgres \
       -e HASURA_GRAPHQL_ENABLE_CONSOLE=true \
       -e HASURA_GRAPHQL_DEV_MODE=true \
       hasura/graphql-engine:v2.0.2
