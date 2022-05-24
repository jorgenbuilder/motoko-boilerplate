import 'isomorphic-fetch'
import dotenv from 'dotenv'
import { readFileSync } from 'fs'
import { Actor, ActorSubclass, HttpAgent, HttpAgentOptions, Identity } from "@dfinity/agent"
import { IDL } from "@dfinity/candid"
import { Principal } from "@dfinity/principal"
import { idlFactory } from './interface/motoko-boilerplate/motoko-boilerplate.did'
import { _SERVICE } from './interface/motoko-boilerplate/motoko-boilerplate.did.d'

dotenv.config({
    path: './.env/.env.local'
});

const canisters = JSON.parse(readFileSync(`${__dirname}/../../.dfx/local/canister_ids.json`).toString());

export function createActor<T>(canisterId: string | Principal, idlFactory: IDL.InterfaceFactory, options: HttpAgentOptions) : ActorSubclass<T> {
    const agent = new HttpAgent({
        host: process.env.HOST,
        ...options
    });

    agent.fetchRootKey().catch(err => {
        console.warn("Unable to fetch root key. Check to ensure that your local replica is running");
        console.error(err);
    });

    return Actor.createActor(idlFactory, {
        agent,
        canisterId,
    });
};

export function motokoWalletActor (identity?: Identity) : ActorSubclass<_SERVICE> {
    return createActor(canisters['motoko-boilerplate'].local, idlFactory, { identity });
};