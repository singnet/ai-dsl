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

A MeTTa file generated from that script is present under the `metta`
subfolder.  Such a file may not be up to date, but can serve as an
example.  Look for

```
metta/snet_marketplace_YYYY-MM-DDThh:mm:ss+00:00.metta
```

where Y stands for year, M for month, D for day, h for hour, m for
minute and s for second.

An example MeTTa file

```
metta/examples.metta
```

of how such dump can be used is provided as well.

## JSON Files Dumps

JSON files representing service metadata are obtained while running
the script and present as well in the subfolder `json`.  Look for

```
json/ORG.json
json/ORG.SERVICE.json
```

where `ORG` and `SERVICE` represent the organization and service
respective identifiers.

The JSON files are not timestamped, but they should have been produced
at the same time as the MeTTa file, which is timestamped.

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

which you can subsequently copy to the host, under the `metta`
subfolder, with the following command line

```bash
docker cp snet-marketplace-space-container:/home/user/snet_marketplace_<DATETIME>.metta metta
```

In addition the json metadata files are listed as well and can be
copied to the host, under the `json` subfolder, with the following
command line

```bash
for f in JSON_FILES; do docker cp snet-marketplace-space-container:/home/user/${f} json; done
```

where JSON_FILES is a space seperated list of json files (beware that
due to BASH command line length limit you might not be able to copy
all files at onces).

After all that the container can be discarded

```bash
docker rm snet-marketplace-space-container
```

## Run Script without Docker

### Prerequisites

- hyperon, https://github.com/trueagi-io/hyperon-experimental
- jq, https://jqlang.github.io/jq/, for JSON parsing
- chromium, https://www.chromium.org, or google-chrome,
  https://www.google.com/chrome/index.html, for reading URL content.
- html2text, https://github.com/grobian/html2text, for converting html
  to text.

## SNET Marketplace Knowledge Representation

For now the knowledge representation is described in the MeTTa file
under the `metta` subfolder.  Look for the string `Type Definitions`.

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
