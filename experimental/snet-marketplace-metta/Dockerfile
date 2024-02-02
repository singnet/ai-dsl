FROM debian:12

# Install prerequisites
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install -y sudo
RUN apt install -y wget
RUN apt install -y psmisc
RUN apt install -y python3 python3-pip python3-venv python-is-python3
RUN apt install -y git
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

# Create python environment
RUN python -m venv base
ENV ACTIVATE=${HOME}/base/bin/activate

# Set local directories
ENV LOCAL=${HOME}/.local
ENV PATH=${LOCAL}/bin:${PATH}
RUN mkdir -p ${LOCAL}/bin

# Install SNET CLI
WORKDIR ${HOME}
RUN git clone https://github.com/singnet/snet-cli.git
WORKDIR snet-cli/packages/snet_cli
RUN . ${ACTIVATE} && ./scripts/blockchain install
RUN . ${ACTIVATE} && pip install -e .

# Install protobuf-metta
WORKDIR ${HOME}
RUN git clone https://github.com/trueagi-io/protobuf-metta.git
WORKDIR protobuf-metta
RUN . ${ACTIVATE} && pip install grpcio-tools
RUN . ${ACTIVATE} && pip install wheel
RUN . ${ACTIVATE} && python setup.py bdist_wheel
RUN . ${ACTIVATE} && pip install dist/protobuf_metta-0.1.0-py3-none-any.whl
WORKDIR ${HOME}

# Copy script for generating the snet marketplace atomspace in MeTTa format
COPY gen-snet-marketplace-metta.sh .

# Create identity
RUN . ${ACTIVATE} && snet identity create ${IDENTITY_NAME} key --private-key ${PRIVATE_KEY}

# Add launch.sh script to source the python environment and launch the
# snet crawler
RUN echo "#!/bin/bash" > ${HOME}/launch.sh
RUN echo "source ${ACTIVATE}" >> ${HOME}/launch.sh
RUN echo "./gen-snet-marketplace-metta.sh \$@" >> ${HOME}/launch.sh
RUN chmod a+x ${HOME}/launch.sh
