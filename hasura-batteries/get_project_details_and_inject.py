import sys
import requests
from requests.exceptions import HTTPError

FILENAME="docker-compose.yml"
METADATA_URL="https://52b6-106-193-170-83.ngrok-free.app/metadata/project-state"
# METADATA_URL=
try:
    instance_id = sys.argv[1]
    response = requests.get(METADATA_URL, params={'instanceId': instance_id})
    response.raise_for_status()
    # access JSOn content
    jsonResponse = response.json()
    postgres_password = jsonResponse['postgresql_password']
    postgresql_endpoint = jsonResponse['postgresql_endpoint']
    hasura_secret = jsonResponse['hasura_secret']
    #read input file
    fin = open(FILENAME, "rt")
    #read file contents to string
    data = fin.read()
    #replace all occurrences of the required string
    data = data.replace('kaushik_replace_postgres_password', postgres_password)
    data = data.replace('kaushik_replace_postgres_endpoint', postgresql_endpoint)
    data = data.replace('kaushik_replace_hasura_secret', hasura_secret)
    # kaushik_replace_hasura_secret

    #close the input file
    fin.close()
    #open the input file in write mode
    fin = open(FILENAME, "wt")
    #overrite the input file with the resulting data
    fin.write(data)
    #close the file
    fin.close()

except HTTPError as http_err:
    print(f'HTTP error occurred: {http_err}')
except Exception as err:
    print(f'Other error occurred: {err}')