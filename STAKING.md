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

7. Deposit ETH (go to ethereum launchpad)

## Migrate to multiple validators config

- create separate volumes for different validators

- update existing validator & account import container config
    - update container tag & container_name with postfix
    - update depends_on with postfix
    - update volumes mapping to newly created volume
    - add `keys/{validator name}` string to volumes mapping
    - add environment section
        - set `VALIDATOR_SUGGESTED_FEE_RECIPIENT`
    - change port mapping from using `VALIDATOR_METRICS_PORT` to hardcoded port
- move existing validator_keys and secrets to keys/family folder (create if not exists)
    - add back keystore-pwd if deleted

- run account import container, check logs to make sure it's imported correctly

- stop old validator to avoid slashing

- start new validator

- inside `.env`
    - remove `VALIDATOR_SUGGESTED_FEE_RECIPIENT` and `VALIDATOR_METRICS_PORT`

- Confirmation
    - validator-account-import
        - Make sure account import successful
        - rerun exits correctly
    - mev-boost
        - Make sure logs shows no errors, 5xx
        - `msg="http: POST /eth/v1/builder/validators 200" duration=0.072223 method=POST path=/eth/v1/builder/validators status=200 version=v1.8.1`
    - validator
        - Make sure registration log seems good
    - beacon-node
        - Make sure no error log for relay
        - `successfully registered validator(s) on builder" num_registrations=1`
    - run up.sh to make sure everything restarts ok