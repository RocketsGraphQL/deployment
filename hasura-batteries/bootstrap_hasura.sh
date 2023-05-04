# docker-compose up -d

# Wait for the hasura to be up
bash -c 'while [[ "$(curl http://localhost:8080/healthz)" != "OK" ]]; do sleep 5; done'

# # Get the ip address
IP_ADDRESS=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
# GET the instance id
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# # And then post it to the project state to finish setting up databases
# curl -d '{
#     "type": "FINISHED_BOOTING_HASURA"
#     "instance_ip": "'$IP_ADDRESS'",
#     "instance_id": "'$INSTANCE_ID'"
# }
# ' -H "Content-Type: application/json" \
#   -X POST https://rocketgraph.io/metadata/project-state/

# Connect DB
# Modify this to be able to add AWS RDS as
# backend database
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

# curl -d '{
#   "type": "pg_add_source",
#   "args": {
#     "name": "postgres",
#     "configuration": {
#       "connection_info": {
#         "database_url": {
#           "name": "postgres",
#           "password": "POSTGRESQL_PASSWORD",
#           "database": "postgres",
#           "host": "host",
#           "port": "port"
#         },
#         "pool_settings": {
#           "retries": 1,
#           "idle_timeout": 180,
#           "max_connections": 50
#         }
#       }
#     }
#   }
# }
# ' -H "Content-Type: application/json" \
#   -H "X-Hasura-Role: admin" \
#   -H "X-hasura-admin-secret: myadminsecretkey" \
#   -X POST http://localhost:8080/v1/metadata

# Create users table
curl -d '
    {
        "type": "run_sql",
        "source": "postgres",
        "args": {
            "source": "postgres",
            "cascade": true,
            "sql": "CREATE TABLE users(id uuid NOT NULL DEFAULT gen_random_uuid(), name text, email text NOT NULL, passwordhash text, PRIMARY KEY (id));"
        }
    }
' -H "Content-Type: application/json" \
  -H "X-Hasura-Role: admin" \
  -H "X-hasura-admin-secret: myadminsecretkey" \
  -X POST http://localhost:8080/v2/query

# create providers table
# with one to many on users
# for various login methods

curl -d '
    {
        "type": "run_sql",
        "source": "postgres",
        "args": {
            "source": "postgres",
            "cascade": true,
            "sql": "CREATE TABLE providers(id uuid NOT NULL DEFAULT gen_random_uuid(), provider text NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, user_id uuid REFERENCES users(id), PRIMARY KEY (id));"
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
                        "name":"providers",
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

# Create array relationship
# providers.user_id -> user.id
# curl -d '
#     {
#       "type": "pg_create_object_relationship",
#       "args": {
#         "source": "postgres",
#         "table": "providers",
#         "name": "user",
#         "using": {
#            "foreign_key_constraint_on": "user_id"
#         }
#       }
#     }
# ' -H "Content-Type: application/json" \
#   -H "X-Hasura-Role: admin" \
#   -H "X-hasura-admin-secret: myadminsecretkey" \
#   -X POST http://localhost:8080/v1/metadata


# Track relationship
curl -d '
    {
        "type":"bulk",
        "source":"postgres",
        "args":[
            {
              "type": "pg_create_object_relationship",
              "args": {
                "source": "postgres",
                "table": "providers",
                "name": "user",
                "using": {
                  "foreign_key_constraint_on": "user_id"
                }
              }
            }
        ]
    }
' -H "Content-Type: application/json" \
  -H "X-Hasura-Role: admin" \
  -H "X-hasura-admin-secret: myadminsecretkey" \
  -X POST http://localhost:8080/v1/metadata

METADATA_URL=https://52b6-106-193-170-83.ngrok-free.app/metadata/project-state
# METADATA_URL=https://rocketgraph.io/metadata/project-state/
# And then post it to the project state to finish setting up databases
curl -d '{
    "state": "FINISHED_SETTING_UP_TABLES_AND_RELATIONSHIPS",
    "instance_ip": "'$IP_ADDRESS'",
    "instance_id": "'$INSTANCE_ID'"
}
' -H "Content-Type: application/json" \
  -X POST $METADATA_URL

# And then post it to the project state to finish setting up databases
curl -d '{
    "state": "FINISHED_SETTING_UP_HASURA_BATTERIES",
    "instance_ip": "'$IP_ADDRESS'",
    "instance_id": "'$INSTANCE_ID'"
}
' -H "Content-Type: application/json" \
  -X POST $METADATA_URL