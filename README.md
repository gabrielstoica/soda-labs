# SodaLabs Foundry Implementation

Simple boilerplate for getting started quickly developing Foundry projects.

## Getting started

Make sure to read the [installation guide](https://book.getfoundry.sh/getting-started/installation) if this is the first
time when using Foundry.

Create a new Foundry project based on this template using the following command:

```bash
forge init myProject --template https://github.com/gabrielstoica/foundry-boilerplate/
cd myProject
forge compile
```

## Features

The `foundry.toml` file contains the most used foundry configurations in order to interact with custom `rpc_endpoints`,
verify your smart contracts on `etehrscan` or adjust the `verbosity` level and the amount of fuzz `runs`.

In order to update the `rpc_endpoints`, create a new `.env` file based on the existing `.env.example` file and customize
it to your needs. Currently, there are only two `rpc_endpoints` available: mainnet and sepolia:

```bash
[rpc_endpoints]
mainnet = "${MAINNET_RPC_URL}"
sepolia = "${SEPOLIA_RPC_URL}"
```

## Usage

### Compile

Use the following command to compile all the project's smart contracts:

```bash
forge compile
```

### Test

Use the following command to run all the project's tests:

```bash
forge test
```

### Deploy

Use the following command to deploy the smart contract on Sepolia testnet:

```bash
forge script script/StringStorage.s.sol --rpc-url sepolia --broadcast --verify
```

### If you want to test the deployment process locally:

1. Spin up a local Ethereum [Geth](https://geth.ethereum.org/downloads) node:

```bash
geth --http --sepolia --syncmode "snap"
```

2. Update the `.env` file with a private key of an account having enough funds on the `Sepolia` testnet.
3. Run the deployment command:

```bash
forge script script/StringStorage.sol --fork-url http://127.0.0.1:8545
```
