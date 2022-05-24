# Motoko Boilerplate

If I was to start a Motoko project today, this is what it would look like.

- Simple admin access control module
- Memory monitoring, cycles monitoring, and logging with Canistergeek
- A typescript test harness with a github action
- Quint's vessel package set

## Use

```sh
npm i
npm run make-admin
dfx start --background
.scripts/deploy
.scripts/copy-interface
npm t
```

Then find and replace `motoko-boilerplate` and `MotokoBoilerplate` with your project name.
