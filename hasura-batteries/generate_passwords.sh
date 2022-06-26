set="abcdefghijklmonpqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
n=10
postgres_password=""
for i in `seq 1 $n`; do
    char=${set:$RANDOM % ${#set}:1}
    postgres_password+=$char
done
echo $postgres_password

dir=$PWD
echo $dir
# randomly generated 10 char postgres password
sed -i "s/kaushik_replace_postgrespassword/$postgres_password/g" "/tmp/deployment/hasura-batteries/docker-compose.yml"

hasura_secret=""
for i in `seq 1 $n`; do
    char=${set:$RANDOM % ${#set}:1}
    hasura_secret+=$char
done
echo $hasura_secret

export HASURA_SECRET=${hasura_secret}
export POSTGRES_PASSWORD=${postgres_password}

# randomly generated 10 chars hasura secret
sed -i "s/kaushik_replace_myadminsecret/$hasura_secret/g" "/tmp/deployment/hasura-batteries/docker-compose.yml"

# Use this key in the bootstrap_hasura as well
sed -i "s/myadminsecretkey/$hasura_secret/g" "/tmp/deployment/hasura-batteries/bootstrap_hasura.sh"

# Get the ip address
IP_ADDRESS=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
# # GET the instance id
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
# get instance region
# INSTANCE_REGION=$(curl -s 'http://169.254.169.254/latest/dynamic/instance-identity/document' | python -c "import sys, json; print json.load(sys.stdin)['region']")

# post these to the status update on rocketgraph

curl -d '{
    "instance_ip": "'$IP_ADDRESS'",
    "instance_id": "'$INSTANCE_ID'",
    "hasura_secret": "'$hasura_secret'",
    "postgres_password": "'$postgres_password'"
}
' -H "Content-Type: application/json" \
  -X POST https://rocketgraph.io/api/project-state/

echo "done"