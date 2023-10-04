# SNET Marketplace Space

## Overview

Script to populate an atomspace with knowledge pertaining to the
SingularityNET Marketplace.  That knowledge may include

1. a description of all AI services on the marketplace;
2. the relationship between AI services, such as their connectivity
   potential (whether the output of a given service can be used as
   input of another);
3. TBD.

## Docker

A Dockerfile under this folder, beside that README.md, can be used to
build a docker image with the SNET CLI tool pre-installed, and a
script to generate a MeTTa file reflecting the current state of the
SNET Marketplace.

To build locally the docker image run

```bash
docker build -t snet-marketplace-space \
    --build-arg IDENTITY_NAME=<YOUR_IDENTITY_NAME> \
    --build-arg PRIVATE_KEY=<YOUR_PRIVATE_KEY> \
    .
```

where `<YOUR_IDENTITY_NAME>` should be replaced by the name of your
identity and `<YOUR_PRIVATE_KEY>` should be replaced by the private
key of your Ethereum wallet.  No fund, ETH, AGIX or otherwise, is
required to be in that wallet in order to crawl the SNET Marketplace
and generate a MeTTa dump of the marketplace.  It is adviced to use a
dedicated wallet specially setup for that purpose rather than your
personal wallet.  The name of your identity can be anything you
choose.

After a few minutes you should have a docker image, called
`snet-marketplace-space`, containing `snet` and preconfigured for your
identity and wallet.

You may then enter a container of that image with

```bash
docker run -it snet-marketplace-space bash -i
```

Once inside the contain you may run the following script

```bash
./gen-snet-marketplace-space.sh
```

This should result in the creation of a file called

```
snet_marketplace_<DATETIME>.metta
```

that contains a dump of the state of the SingularityNET Marketplace at
the date and time of generation.

## MeTTa File Dump

Alternatively a file generated from that script is present as well.
Such a file may not be up to date, but can serve as an example.

## SNET Marketplace Knowledge Representation

NEXT

## Troubleshooting

### Docker

Sometimes it may be useful to purge docker images and containers.
This may happen when incrementally building a docker image fails.  To
purge all images and containers from your system, run the following
command (be careful, that command will purge ALL docker images and
container from your system):

```bash
docker system prune -a
```
