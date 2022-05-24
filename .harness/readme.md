# Canister Test Harness

This test harness uses DFX to run the test environment, then relies on typescript and jest to handle test definitions, execution, etc.

## Keys

Principals are required to make send test messages, and those principals may need to be granted permissions, tokens, etc., so persisting them becomes necessary. Keys are stored in the local filesystem outside of source control, but they are not encrypted and should not be considered safe for real permissions or assets.

## Interface Bindings

The test agent requires up-to-date interface bindings in order to send messages to canisters. These are stored in source control and are generated using a slightly processed `dfx generate`, accessible via `npm run interface`.
