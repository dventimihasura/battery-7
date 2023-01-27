import http from 'k6/http';
import { sleep } from 'k6';
export default function () {
    const headers = {'Content-Type': 'application/json'};
    const query = `{"query":"query {product(id: ${Math.floor(Math.random()*10)+1}) {id name}}"}`
    const res = http.post('http://127.0.0.1:8085/v1/graphql', query, {headers: headers});
}
