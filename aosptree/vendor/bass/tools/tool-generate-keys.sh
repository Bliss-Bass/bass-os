# Provide a key pair for signing.
#
# This script generates a key pair for signing builds.
# It requires the development tools to be installed in the Android tree.
#
# Copyright (C) 2024 BlissLabs

subject='/C=US/ST=California/L=Mountain View/O=Android/OU=Android/CN=Android/emailAddress=contact@blisslabs.org'
mkdir vendor/bliss/config/signing
for x in testkey releasekey platform shared media networkstack; do \
  ./development/tools/make_key vendor/bliss/config/signing/$x "$subject"; \
done