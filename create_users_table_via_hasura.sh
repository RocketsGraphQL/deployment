curl -d '
    {
        "type": "run_sql",
        "source": "postgres",
        "args": {
            "source": "postgres",
            "cascade": true,
            "sql": "CREATE TABLE users(id serial NOT NULL, name text NOT NULL, email text NOT NULL, passwordhash text NOT NULL, PRIMARY KEY (id));"
        }
    }
' -H "Content-Type: application/json" -X POST http://localhost:8080/v2/query