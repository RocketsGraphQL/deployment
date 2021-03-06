# docker-compose up -d

# Wait for the hasura to be up
bash -c 'while [[ "$(curl http://localhost:8080/healthz)" != "OK" ]]; do sleep 5; done'

# Connect DB
curl -d '{
  "type": "pg_add_source",
  "args": {
    "name": "postgres",
    "configuration": {
      "connection_info": {
        "database_url": {
          "from_env": "PG_DATABASE_URL"
        },
        "pool_settings": {
          "retries": 1,
          "idle_timeout": 180,
          "max_connections": 50
        }
      }
    }
  }
}
' -H "Content-Type: application/json" \
  -H "X-Hasura-Role: admin" \
  -H "X-hasura-admin-secret: myadminsecretkey" \
  -X POST http://localhost:8080/v1/metadata

# Create table
curl -d '
    {
        "type": "run_sql",
        "source": "postgres",
        "args": {
            "source": "postgres",
            "cascade": true,
            "sql": "CREATE TABLE users(id uuid NOT NULL DEFAULT gen_random_uuid(), name text NOT NULL, email text NOT NULL, passwordhash text NOT NULL, role text NOT NULL DEFAULT user, refresh text NOT NULL, PRIMARY KEY (id));"
        }
    }
' -H "Content-Type: application/json" \
  -H "X-Hasura-Role: admin" \
  -H "X-hasura-admin-secret: myadminsecretkey" \
  -X POST http://localhost:8080/v2/query


# Track table
curl -d '
    {
        "type":"bulk",
        "source":"postgres",
        "resource_version":2,
        "args":[
            {
                "type":"pg_track_table",
                "args":{
                    "table":{
                        "name":"users",
                        "schema":"public"
                    },
                    "source":"postgres"
                }
            }
        ]
    }
' -H "Content-Type: application/json" \
  -H "X-Hasura-Role: admin" \
  -H "X-hasura-admin-secret: myadminsecretkey" \
  -X POST http://localhost:8080/v1/metadata
