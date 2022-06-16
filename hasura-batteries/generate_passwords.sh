set="abcdefghijklmonpqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
n=10
postgres_password=""
for i in `seq 1 $n`; do
    char=${set:$RANDOM % ${#set}:1}
    postgres_password+=$char
done
echo $postgres_password

# dir=$PWD
# echo $dir
# # randomly generated 10 char postgres password
# sed -i "s/kaushik_replace_postgrespassword/$postgres_password/g" "$dir/docker-compose.yml"

hasura_secret=""
for i in `seq 1 $n`; do
    char=${set:$RANDOM % ${#set}:1}
    hasura_secret+=$char
done
echo $hasura_secret

# # randomly generated 10 chars hasura secret
# sed -i "s/kaushik_replace_myadminsecret/$hasura_secret/g" "$dir/docker-compose.yml"

# # Get the ip address
IP_ADDRESS=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
# # GET the instance id
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
# # get instance region
# # INSTANCE_REGION=$(curl -s 'http://169.254.169.254/latest/dynamic/instance-identity/document' | python -c "import sys, json; print json.load(sys.stdin)['region']")

# # post these to the status update on rocketgraph



docker_data="version: '3.6'
services:
  postgres:
    image: postgres:12
    restart: always
    volumes:
    - db_data:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: "$postgres_password"
  graphql-engine:
    image: hasura/graphql-engine:v2.0.7
    ports:
    - '8080:8080'
    depends_on:
    - 'postgres'
    restart: always
    environment:
      ## postgres database to store Hasura metadata
      HASURA_GRAPHQL_METADATA_DATABASE_URL: postgres://postgres:$postgres_password@postgres:5432/postgres
      ## this env var can be used to add the above postgres database to Hasura as a data source. this can be removed/updated based on your needs
      PG_DATABASE_URL: postgres://postgres:$postgres_password@postgres:5432/postgres
      ## enable the console served by server
      HASURA_GRAPHQL_ENABLE_CONSOLE: 'true' # set to 'false' to disable console
      ## enable debugging mode. It is recommended to disable this in production
      HASURA_GRAPHQL_DEV_MODE: 'true'
      HASURA_GRAPHQL_ENABLED_LOG_TYPES: startup, http-log, webhook-log, websocket-log, query-log
      ## uncomment next line to set an admin secret
      HASURA_GRAPHQL_ADMIN_SECRET: $hasura_secret
      HASURA_GRAPHQL_UNAUTHORIZED_ROLE: public
      HASURA_GRAPHQL_JWT_SECRET: '{
        'type': 'HS256',
        'key': 'If it is able to parse any of the above successfully, then it will use that parsed time to refresh/refetch the JWKs again. If it is unable to parse, then it will not refresh the JWKs'
      }'
  hasura-batteries:
    image: rocketsgraphql/hasura-batteries:latest
    ports:
      - '7000:7000'
    depends_on:
      - 'graphql-engine'
    links:
      - 'graphql-engine'
    restart: always

volumes:
  db_data:
"

echo $docker_data >> /tmp/deployment/hasura-batteries/docker-compose.yml

curl -d '{
    "instance_ip": "'$IP_ADDRESS'",
    "instance_id": "'$INSTANCE_ID'",
    "hasura_secret": "'$hasura_secret'",
    "postgres_password": "'$postgres_password'"
}
' -H "Content-Type: application/json" \
  -X POST https://rocketgraph.io/api/project-state/

echo "done"