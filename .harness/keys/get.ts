import { fetchIdentity } from './keys';

const name = process.argv[2] || 'admin';

console.log(fetchIdentity(name).getPrincipal().toString());