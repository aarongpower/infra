#!/usr/bin/env bash

# Encrypt private key with my two yubikey identities as recipients
echo "Encrypting private key to both yubikey identities"
cat ~/.ssh/id_ed25519 | rage -r age1yubikey1q2lqyan5fvt00jxfjh2h79sp6nzxgf4yzmtxcf0m4ejejejwy9rjzla2dud -r age1yubikey1q0h3cqyc0rdz5qud502fpgcla08usfh3cyqtaj3zawzumjfcx6y3xnqx5mh -o ~/.nixcfg/home/secrets/turbo-squid.age

# Copy public key as well
echo "Copying public key"
cp -v ~/.ssh/id_ed25519 ~/.nixcfg/home/secrets/turbo-squid.pub
