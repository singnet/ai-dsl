# SNET Marketplace Space

## Overview

Script to populate an atomspace with knowledge pertaining to the
SingularityNET Marketplace.  That knowledge may include

1. a description of all AI services on the marketplace;
2. the relationship between AI services, such as their connectivity
   potential (whether the output of a given service can be used as
   input of another);
3. TBD.

## MeTTa File Dump

A generated file from that script should be present in that repository
as well.  Such a file may not be up to date, but can serve as an
example.

To regenerate that file see below.

## Docker

Probably the easiest way to run that script is via a docker container.
A Dockerfile under this folder can be used to build a docker image
containing
1. the SNET CLI tool pre-installed, pre-configured for the user;
2. the script to generate SNET Marketplace knowledge in MeTTa format.

To locally build the docker image run

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
personal wallet.  The name of your identity can be anything of your
choosing.

After a few minutes you should have a docker image, called
`snet-marketplace-space`, containing `snet` and preconfigured with
your identity and wallet.

You may then run `gen-snet-marketplace-space.sh` within a container of
that image

```bash
docker run --name snet-marketplace-space-container snet-marketplace-space ./gen-snet-marketplace-space.sh
```

Beware it may take a few minutes.  The script should eventually
end with the message

```
Generated snet_marketplace_<DATETIME>.metta
```

which you can subsequently copy to the host

```bash
docker cp snet-marketplace-space-container:/home/user/snet_marketplace_<DATETIME>.metta .
```

After which the container can be discarded

```bash
docker rm snet-marketplace-space-container
```

## Run Script without Docker

### Prerequisites

- jq

## SNET Marketplace Knowledge Representation

### Organization

```
(: OrganizationID Type)
```

For instance, to express that `snet` is an organization ID

```
(: snet OrganizationID)
```

### Service

```
(: ServiceOf (-> OrganizationID Type))
```

For instance, to express `cntk-image-recon` is a service of `snet`

```
(: cntk-image-recon (ServiceOf snet))
```

Attributes are expressed as function mapping.  Examples of attributes
of service are

```
version
display_name
service_type
...
```

For instance the following expresses that the version of service
`cntk-image-recon` is 1

```
(= (version cntk-image-recon) 1)
```

Attributes can be accompanied by their type declarations, such as

```
(: version (-> (ServiceOf $org_id) Number))
```

Another example with `display_name` of `cntk-image-recon` would be

```
(= (display_name cntk-image-recon) "AI Sight")
```

with the accompanied declaration

```
(: display_name (-> (ServiceOf $org_id) String))
```

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
