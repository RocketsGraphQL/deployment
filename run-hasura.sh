#! /bin/bash
docker run -d -p 8080:8080 \
       --network="host" \
       -e HASURA_GRAPHQL_DATABASE_URL=postgresql://market_data_access:1234@localhost:5432/market_data \
       -e HASURA_GRAPHQL_ENABLE_CONSOLE=true \
       -e HASURA_GRAPHQL_DEV_MODE=true \
       hasura/graphql-engine:v2.0.2