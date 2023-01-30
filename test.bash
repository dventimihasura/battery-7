#!/usr/bin/bash

set -x				# Turn on debug output.
set -e				# Exit if a pipeline fails.
set -o pipefail			# Exit status of a pipeline is the last command.
set -m				# Turn on job control.

# Start the services.

docker-compose up -d

# Deploy Hasura projects in the proper order, after their health checks pass.

while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://localhost:8082/healthz)" != "200" ]]; do sleep 5; done
pushd graphql-engine-2 && hasura deploy --skip-update-check && popd
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://localhost:8083/healthz)" != "200" ]]; do sleep 5; done
pushd graphql-engine-3 && hasura deploy --skip-update-check && popd
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://localhost:8084/healthz)" != "200" ]]; do sleep 5; done
pushd graphql-engine-4 && hasura deploy --skip-update-check && popd
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://localhost:8085/healthz)" != "200" ]]; do sleep 5; done
pushd graphql-engine-5 && hasura deploy --skip-update-check && popd
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://localhost:8081/healthz)" != "200" ]]; do sleep 5; done
pushd graphql-engine-1 && hasura deploy --skip-update-check && popd

# Run the load test scripts.

k6 run -q -u1 -d10s test_1.js --summary-export test_1.json
k6 run -q -u1 -d10s test_2.js --summary-export test_2.json
k6 run -q -u1 -d10s test_3.js --summary-export test_3.json

# Extract the relevant metrics into a log file.

cat test_2.json | jq -r '"graphql-engine-1: \(.metrics.http_req_duration)"' >> k6.log
cat test_3.json | jq -r '"graphql-engine-5: \(.metrics.http_req_duration)"' >> k6.log

# Stop the services.

docker-compose down

