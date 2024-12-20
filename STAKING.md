# Staking

## Steps

1. Make sure your node is configured correctly

Follow https://holesky.launchpad.ethereum.org/en/checklist for holesky and mainnet URL respectively.

2. Run an ethereum node

go to docker-compose.yml, and comment out (if not already) validator & validator account import & mev related containers.

start a el & beacon-node and have it syn to tip.

3. Download [staking-deposit-cli](https://github.com/ethereum/staking-deposit-cli)

First install it, and then generate validator keys (follow README)
`./deposit.sh existing-mnemonic --num_validators 1 --chain $CHAIN --eth1_withdrawal_address $WITHDRAWAL_ADDRESS`

Move generated validator_keys folder to root directory (of the specific network)

4. create keys files

* Create a wallet-pwd file with wallet password under secrets folder
* Create a keystore-pwd file with keystore password under secrets folder

5. Uncomment validator / validator-import-account / mev containers

Run `./up.sh` again

6. empty out `keystore-pwd` (remember to comment out `VALIDATOR_WALLET_FORCE_RECREATE` if enabled before)

6. Deposit ETH (go to ethereum launchpad)