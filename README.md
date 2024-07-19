# staking
All staking related configurations


## Notes

1. Allow prometheus to access node_exporter

Need to allow it from ufw:
```shell
docker network ls
docker network inspect <network name>
sudo ufw allow from <IPAM Subnet, example 172.17.0.0/16> to any port 9100
sudo ufw reload
```

### Setup a new network

*. generate jwt token
`openssl rand -hex 32 | tr -d "\n" > jwtsecret`

*. Generate validator_keys
`./deposit new-mnemonic --num_validators=<validator number> --mnemonic_language=english --chain=<network> --execution_address=<withdrawal address>`

*. Create passwords files
