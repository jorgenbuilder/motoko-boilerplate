import { Ed25519KeyIdentity } from '@dfinity/identity'
import { motokoWalletActor } from '../actors/actor'
import { fetchIdentity } from '../keys/keys';

const MotokoWalletAnon = motokoWalletActor();
const MotokoWalletAdmin = motokoWalletActor(fetchIdentity("admin"));

const randomPrincipal = Ed25519KeyIdentity.generate().getPrincipal();

describe("Admin module admin functions", () => {
    it("addAdmin is NOT callable by users", async () => {
        const rejected = await MotokoWalletAnon.addAdmin(randomPrincipal).catch(r => true);
        expect(rejected).toBe(true);
    });
    it("removeAdmin is NOT callable by users", async () => {
        const rejected = await MotokoWalletAnon.removeAdmin(randomPrincipal).catch(r => true);
        expect(rejected).toBe(true);
    });
    it("addAdmin IS callable by admins", async () => {
        const success = await MotokoWalletAdmin.addAdmin(randomPrincipal).then(r => true);
        expect(success).toBe(true);
    });
    it("removeAdmin IS callable by admins", async () => {
        const success = await MotokoWalletAdmin.removeAdmin(randomPrincipal).then(r => true);
        expect(success).toBe(true);
    });
});

describe("Canistergeek module admin functions", () => {});