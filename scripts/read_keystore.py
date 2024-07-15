from web3.auto import w3
import json
import getpass

# Prompt the user for the keystore file path
keystore_file_path = input("Enter the path to your keystore file: ")

# Load the keystore file
with open(keystore_file_path) as keyfile:
  encrypted_key = json.load(keyfile)

# Prompt the user for the password securely
password = getpass.getpass("Enter the password for your keystore file: ")

# Decrypt the keystore file to get the private key
private_key = w3.eth.account.decrypt(encrypted_key, password)

# Get the public address from the private key
account = w3.eth.account.from_key(private_key)
public_address = account.address

print(f"Public Address: {public_address}")