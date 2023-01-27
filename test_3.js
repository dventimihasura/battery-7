import http from 'k6/http';
import { sleep } from 'k6';
export default function () {
    const headers = {'Content-Type': 'application/json'};
    const query = `http://localhost:8085/api/rest/product/${Math.floor(Math.random()*10)+1}`
    const res = http.get(query, {headers: headers});
}
