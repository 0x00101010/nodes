#!/bin/bash
set -eu

mkdir -p secrets
openssl rand -hex 32 | tr -d "\n" >secrets/jwtsecret

docker compose up --build -d
