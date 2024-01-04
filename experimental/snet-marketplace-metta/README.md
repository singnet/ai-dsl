# SNET Marketplace Space in MeTTa Format

## Overview

Script to populate an atomspace (in MeTTa format) with knowledge about
the SingularityNET Marketplace.  That knowledge base includes

- Information about every organization on the marketplace.
- Information about every AI service on the marketplace, such as
  - name
  - IPFS address
  - long and short descriptions
  - protobuf specification
  - etc.
- Relationships between AI services, such as their potential
  connectivity potential (whether the output of a given service can be
  used as input of another).  This is to be precisely determined.

## MeTTa File Dump

A MeTTa file generated from that script is present under the
`output/metta` subfolder.  Such a file may not be up to date, but can
serve as an example.  Look for

```
output/metta/snet_marketplace_YYYY-MM-DDThh:mm:ss+00:00.metta
```

where Y stands for year, M for month, D for day, h for hour, m for
minute and s for second.

A usage example of the generated MeTTa file above

```
metta/examples.metta
```

## JSON Files Dumps

JSON files representing service metadata are obtained while running
the script and present as well in the subfolder `output/json`.  Look
for

```
output/json/ORG.json
output/json/ORG.SERVICE.json
```

where `ORG` and `SERVICE` represent the organization and service
respective identifiers.

The JSON files are not timestamped, but they should have been produced
at the same time as the MeTTa file, which is timestamped.

## Run Script with Docker

Probably the easiest way to run that script is via a docker container.
A Dockerfile under this folder can be used to build a docker image
containing
1. the SNET CLI tool pre-installed, pre-configured for the user;
2. the script to generate SNET Marketplace knowledge in MeTTa format.

To locally build the docker image, you may run

```bash
docker build -t snet-marketplace-metta \
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
`snet-marketplace-metta`, containing `snet` and preconfigured with
your identity and wallet.

You may then run `gen-snet-marketplace-metta.sh` within a container of
that image

```bash
docker run --name snet-marketplace-metta-container snet-marketplace-metta ./gen-snet-marketplace-metta.sh
```

Beware it may take a few minutes.  The script should eventually
end with the message

```
MeTTa file `snet_marketplace_<DATETIME>.metta` has been generated
under `output/metta` alongside intermediary JSON and Python files,
respectively under `output/json` and `output/client_libraries`.
```

The `json` and `client_libraries` directories are themselves
subdivided into `<ORG>/<SERVICE>` subdirectories respectively
containing metadata JSON files, Python client libraries alongside
protobuf specifications.

Finally you may copy the `output` folder to the host by typing

```bash
docker cp snet-marketplace-metta-container:/home/user/output .
```

After all that is done, the container can be discarded

```bash
docker rm snet-marketplace-metta-container
```

### Only crawl a subset of services

The `gen-snet-marketplace-metta.sh` script accept arguments to
restrict crawling only a subset of organizations or services.  The
usage is as follows

```bash
gen-snet-marketplace-metta.sh [<ORG1>[.<SERVICE1>] ... <ORGn>[.<SERVICEn>]]
```

If only organization is provided then all its services are crawled.
If both service and organization is provided then only the provided
service is crawled.

For instance

```bash
./gen-snet-marketplace-metta.sh snet
```

crawls all services of the snet organization, while

```bash
gen-snet-marketplace-metta.sh snet nunet.binary-classification-service
```

crawls all services of snet plus the binary-classification-service
service of nunet.

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
under the `output/metta` subfolder.  Look for `Type Definitions`.

## Troubleshooting

### Docker

#### Permission denied

As you try to build the docker image you may get the error

```
permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock
```

Probably the simplest way to fix that is to add your user to the
docker group.  To do that, enter

```
sudo usermod -aG docker $USER
```

then logout and login again.

For more ways see [here](https://linuxhandbook.com/docker-permission-denied/).

#### Enter the docker container for debugging

To enter the docker container created above for further debugging, type

```bash
docker exec -it snet-marketplace-metta-container bash
```

You may need to start the container before you can enter, if so type

```bash
docker start snet-marketplace-metta-container
```
#### Remove container

Upon attempting to remove the container, you may get an error like

```
docker: Error response from daemon: Conflict. The container name "/snet-marketplace-metta-container" is already in use by container "aa4f2bcd0661956903640579e09f053df14aa6fe4a63cdba8ef9acebd04176ef". You have to remove (or rename) that container to be able to reuse that name.
```

If so, stop the container

```bash
docker stop snet-marketplace-metta-container
```

and try again.

#### Purge everything

Sometimes it may be useful to purge docker images and containers.
This may happen when incrementally building a docker image fails.  To
purge all images and containers from your system, run the following
command (be careful, that command will purge ALL docker images and
container from your system):

```bash
docker system prune -a
```
