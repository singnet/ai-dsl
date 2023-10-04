#!/bin/bash

#############
# Constants #
#############

# Define output MeTTa filename
DATETIME=$(date --iso-8601=seconds)
METTA_FILENAME="snet_marketplace_${DATETIME}.metta"

#############
# Functions #
#############

# Takes the organization name as first argument and service as second
# argument and outputs knowledge that service in MeTTa format.
service_to_metta() {
    local org="$1"
    local service="$2"
    echo "(: ${service} (ServiceOf ${org}))"
}

# Takes the organization name as first argument and outputs knowledge
# about that organization in MeTTa format.
organization_to_metta() {
    local org="$1"
    echo "(: ${org} Organization)"
    echo
    echo ";; Services of ${org}"
    for service in $(snet organization list-services ${org} | tail --lines=+3 | cut -f2 -d" "); do
        service_to_metta ${org} ${service}
    done
}

########
# Main #
########

# Set the network to mainnet
snet network mainnet

# Write header
cat <<EOF > ${METTA_FILENAME}
;; File generated with gen-snet-marketplace-space.sh
;;
;; It contains:
;;
;; 1. a description of all AI services on the marketplace;
;; 2. the relationship between AI services, such as their potential
;;    connectivity (whether the output of a given service can be used
;;    as input of another).

EOF

# Write all organizations
cat <<EOF >> ${METTA_FILENAME}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SingularityNET Organizations ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
EOF
for org in $(snet organization list | tail --lines=+2); do
    echo "Collect information about ${org}"
    echo >> ${METTA_FILENAME}
    echo ";; Organization: ${org}" >> ${METTA_FILENAME}
    organization_to_metta "${org}" >> ${METTA_FILENAME}
done
echo "Generated ${METTA_FILENAME}"
