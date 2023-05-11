
# Fetch metadata about the container
# Get the ip address
IP_ADDRESS=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
# GET the instance id
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
# get instance region
# INSTANCE_REGION=$(curl -s 'http://169.254.169.254/latest/dynamic/instance-identity/document' | python -c "import sys, json; print json.load(sys.stdin)['region']")

METADATA_URL=https://rocketgraph.io/metadata/project-state
# Now post the metadata to Rocketgraph server to link
# the instance with this id to the ip address we just fetched
# And then post it to the project state to link both of them
curl -d '{
    "state": "READY_FOR_DEPLOYMENT",
    "instance_ip": "'$IP_ADDRESS'",
    "instance_id": "'$INSTANCE_ID'"
}
' -H "Content-Type: application/json" \
  -X POST $METADATA_URL


sudo python3 /tmp/deployment/hasura-batteries/get_project_details_and_inject.py $INSTANCE_ID

docker-compose -f /tmp/deployment/hasura-batteries/docker-compose.yml up -d
/bin/bash /tmp/deployment/hasura-batteries/bootstrap_hasura.sh