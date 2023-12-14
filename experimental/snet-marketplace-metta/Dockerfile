FROM ubuntu:20.04

# Install prerequisites
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install -y sudo
RUN apt install -y wget
RUN apt install -y psmisc
RUN apt install -y python3 python3-pip git
RUN apt install -y nodejs npm
RUN apt install -y jq
RUN apt install -y html2text
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN apt install -y ./google-chrome-stable_current_amd64.deb
RUN rm google-chrome-stable_current_amd64.deb

# Declare arg variables
ARG IDENTITY_NAME
ARG PRIVATE_KEY

# Create user
ENV USER=user
RUN useradd -m -G sudo -p "" user
RUN chsh -s /bin/bash user
USER ${USER}
ENV HOME=/home/${USER}
WORKDIR ${HOME}

# Set local directories
ENV LOCAL=${HOME}/.local
ENV PATH=${LOCAL}/bin:${PATH}
RUN mkdir -p ${LOCAL}/bin

# Install SNET CLI
WORKDIR ${HOME}
RUN git clone https://github.com/singnet/snet-cli.git
WORKDIR snet-cli/packages/snet_cli
RUN ./scripts/blockchain install
RUN pip3 install -e .
WORKDIR ${HOME}

# Copy script for generating the snet marketplace atomspace in MeTTa format
COPY gen-snet-marketplace-metta.sh .

# Create identity
RUN snet identity create ${IDENTITY_NAME} key --private-key ${PRIVATE_KEY}
