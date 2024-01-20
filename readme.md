# Nushell Debian Package

This repository builds a debian package out of Nushell

Currently only for:

| OS                   | Architecture  |
|----------------------|----------------|
| Ubuntu 22.04 (Jammy) | amd64 (x86_64) |

## Prequisites

- `dpkg-deb 1.21.1` which comes with Ubuntu 22.04
- `nushell 0.89.0`

## Building the debian package

```sh
# Create a debian package
./scripts/main.nu 0.89.0

# Build a docker container that install the debian package
docker build -t testing_nushell_debian_package -f docker/test.dockerfile .

# Run the version command in the container (the -t flag ensure colored output)
docker run --rm -t testing_nushell_debian_package "-c version"
```

## Package cloud

I've uploaded nushell to packagecloud on a trial basis to test it out.

Install Nushell 0.89.0 from there with

```sh
# In case you're inside a docker container, otherwise you probably already have curl and sudo
apt update -qq && apt install -y curl sudo

# Setup the apt repository from packagecloud
curl -s https://packagecloud.io/install/repositories/Inveracity/nushell/script.deb.sh | sudo bash

# Install nushell
apt install -y nushell

# Run nushell
nu -n
```
