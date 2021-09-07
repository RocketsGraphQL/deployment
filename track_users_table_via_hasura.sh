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
' -H "Content-Type: application/json" -X POST http://localhost:8080/v1/metadata