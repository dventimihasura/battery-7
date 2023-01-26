#!/usr/bin/bash

set -x

docker-compose up -d
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://localhost:8083/healthz)" != "200" ]]; do sleep 5; done
pushd graphql-engine-1 && hasura deploy && popd
pushd graphql-engine-2 && hasura deploy && popd
pushd graphql-engine-3 && hasura deploy && popd
pushd graphql-engine-4 && hasura deploy && popd
pushd graphql-engine-5 && hasura deploy && popd
k6 run -q -u1 -d10s test_1.js --summary-export test_1.json
k6 run -q -u1 -d10s test_2.js --summary-export test_2.json
k6 run -q -u1 -d10s test_3.js --summary-export test_3.json
cat test_2.json | jq -r '.metrics.http_req_duration.avg'
cat test_3.json | jq -r '.metrics.http_req_duration.avg'
docker-compose down

