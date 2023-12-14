#!/bin/bash

# set -x

#############
# Constants #
#############

# Define output MeTTa filename
DATETIME=$(date --iso-8601=seconds)
METTA_FILENAME="snet_marketplace_${DATETIME}.metta"
METTA_FILEPATH="metta/${METTA_FILENAME}"

#############
# Functions #
#############

# Output the given arguments to the stderr, timestamped.
log() {
    echo "[$(date --iso-8601=seconds)] $@" 1>&2
}

# Given in argument a record name, and a list of record field names
# and a list of their types, generate the MeTTa code to define the
# corresponding constructor and access functions.
#
# For instance:
#
# record_type_to_metta Rec field1 String field2 Number
#
# outputs:
#
# ;; Define Rec type
# (: Rec Type)
#
# ;; Define Rec constructor
# (: MkRec (-> String ; field1
#              Number ; field2
#              Rec))
#
# ;; Define Rec access functions
# (= (Rec.field1 (MkRec $field1
#                       $field2)) $field1)
# (= (Rec.field2 (MkRec $field1
#                       $field2)) $field2)
record_type_to_metta() {
    local record_name="$1"
    shift
    local fields_count=$(($# / 2))
    declare -a fields
    declare -a types
    for i in $(seq 1 ${fields_count})
    do
        fields[${i}]="$1"
        types[${i}]="$2"
        shift
        shift
    done

    # Output record type and constructor definitions
    echo ";; Define ${record_name} type"
    echo "(: ${record_name} Type)"
    echo
    echo ";; Define ${record_name} constructor"
    echo "(: Mk${record_name}"
    echo "   (->"
    for i in $(seq 1 ${fields_count})
    do
        echo "       ${types[${i}]} ; ${fields[${i}]}"
    done
    echo "       ${record_name}))"

    # Output record access functions
    echo
    echo ";; Define ${record_name} access functions"
    for i in $(seq 1 ${fields_count})
    do
        echo "(: ${record_name}.${fields[${i}]} (-> ${record_name} ${types[${i}]}))"
        echo "(= (${record_name}.${fields[${i}]}"
        echo "      (Mk${record_name}"
        for j in $(seq 1 ${fields_count})
        do
            echo "        \$${fields[${j}]}"
        done
        echo "       )"
        echo "   )"
        echo "   \$${fields[${i}]})"
    done
}

# Output type, constructor and access function definitions in MeTTa
# format.
type_definitions_to_metta() {
cat <<EOF
;; Define List type and constructor
(: List (-> \$a Type))
(: Nil (List \$a))
(: Cons (-> \$a (List \$a) (List \$a)))

;; Define List functions

;; Return the head of a list
(: head (-> (List \$a) \$a))
(= (head (Cons \$head \$tail)) \$head)

;; Return the tail of a list
(: tail (-> (List \$a) \$a))
(= (tail (Cons \$head \$tail)) \$tail)

;; Return True iff the given list is empty
(: empty (-> (List \$a) Bool))
(= (empty Nil) True)
(= (empty (Cons \$head \$tail)) False)

;; Return the length of a list
(: length (-> (List \$a) Number))
(= (length Nil) 0)
(= (length (Const \$head \$tail)) (+ 1 (length \$tail)))

;; Return the element of a list at a given index
(: indexElem (-> (List \$a) Number \$a))
(= (indexElem (Cons \$head \$tail) $k)
   (if (< 0 $k) (indexElem \$tail (- \$k 1)) \$head))

;; Define OrganizationID type
(: OrganizationID Type)

;; Define access function from organization ID to organization data
;; structure (see Organization defined further below)
(: organization (-> OrganizationID Organization))

$(record_type_to_metta Organization org_name String org_id String org_type String description Description assets "(List Assets)" contacts "(List Contact)" groups "(List Group)")

$(record_type_to_metta Description url String url_content String description String short_description String)

;; Define ServiceID type.  A service ID must be associated to an
;; organization ID.
(: ServiceID (-> OrganizationID Type))

;; Define access function from service ID to service data structure
;; (see Service defined further below).
(: service (-> (ServiceID \$org) Service))

$(record_type_to_metta Pricing price_model String price_in_cogs Number default Bool)

$(record_type_to_metta Group group_name String pricing Pricing endpoints "(List String)" group_id String free_calls Number free_call_signer_address String daemon_addresses "(List String)")

$(record_type_to_metta ServiceDescription url String url_content String description String short_description String)

$(record_type_to_metta Contributor name String email_id String)

$(record_type_to_metta Medium order Number url String file_type String alt_text)

$(record_type_to_metta Service version Number display_name String encoding String service_type String model_ipfs_hash String mpe_address String groups "(List Group)" service_description ServiceDescription contributors "(List Contributor)" media "(List Medium)" tags "(List String)")
EOF
}

# Takes the organization id as first argument and outputs knowledge
# about that organization in MeTTa format.
organization_to_metta() {
    local org="$1"

    # Save json metadata of that organization in a file
    local metadata_filepath=json/${org}.json
    snet organization print-metadata ${org} ${org} > ${metadata_filepath}

    # Log
    log "Collect information about ${org}"

    # Output organization data
    cat <<EOF

;; OrganizationID definition of ${org}
(: ${org} OrganizationID)

;; Organization metadata of ${org}
(= (organization ${org})
   ; Organization
   (MkOrganization
       ; org_name
       $(jq '.org_name' ${metadata_filepath})
       ; org_id
       $(jq '.org_id' ${metadata_filepath})
       ; org_type
       $(jq '.org_type' ${metadata_filepath})
       ; description
       $(description_to_metta ${metadata_filepath})
       ; assets
       Nil
       ; contacts
       Nil
       ; groups
       Nil
   )
)

;; Services of ${org}

EOF
    for service in $(snet organization list-services ${org} | tail --lines=+3 | cut -f2 -d" "); do
        service_to_metta ${org} ${service}
    done
}

# Takes the organization id as first argument and service as second
# argument and outputs knowledge about that service in MeTTa format.
service_to_metta() {
    local org="$1"
    local service="$2"

    # Save json metadata of that service in a file
    local metadata_filepath=json/${org}.${service}.json
    snet service print-metadata ${org} ${service} > ${metadata_filepath}

    # Log
    log "Collect information about ${org}.${service}"

    # Output service data
    cat <<EOF

;; ServiceID definition of ${org}.${service}"
(: ${org}.${service} (ServiceID ${org}))

;; Service metadata of ${org}.${service}
(= (service ${org}.${service})
   ; Service
   (MkService
       ; version
       $(jq '.version' ${metadata_filepath})
       ; display_name
       $(jq '.display_name' ${metadata_filepath})
       ; encoding
       $(jq '.encoding' ${metadata_filepath})
       ; service_type
       $(jq '.service_type' ${metadata_filepath})
       ; model_ipfs_hash
       $(jq '.model_ipfs_hash' ${metadata_filepath})
       ; mpe_address
       $(jq '.mpe_address' ${metadata_filepath})
       ; groups
       $(groups_to_metta ${metadata_filepath})
       ; service_description
       $(service_description_to_metta ${metadata_filepath})
       ; contributors
       $(contributors_to_metta ${metadata_filepath})
       ; media
       $(media_to_metta ${metadata_filepath})
       ; tags
       $(tags_to_metta ${metadata_filepath})
   )
)
EOF
}

# Take a metadata file of the service an output its groups in MeTTa
# format.
groups_to_metta() {
    local metadata_filepath="$1"
    local groups_length=$(jq '.groups | length' ${metadata_filepath})
    # TODO: see https://www.baeldung.com/linux/jq-command-json to deal with array
    echo "Nil"
}

# Given a url as argument, output its textual content.
url_textual_content() {
    local url="$1"

    # Detect browser to read content of url.  Only chromium and
    # google-chrome are supported because they provide headless
    # javascript rendering (firefox does not support that).
    if [ -z $(command -v chromium) ]
    then if [ -z $(command -v google-chrome) ]
         then log "chromium or google-chrome is required"
              exit 1
         else browser=google-chrome
         fi
    else browser=chromium
    fi

    $browser --headless --no-sandbox --disable-gpu --dump-dom ${url:1:-1} 2> /dev/null | html2text
}

# Take a metadata file of an organization and output its description
# in MeTTa format.
description_to_metta() {
    local metadata_filepath="$1"
    local url="$(jq '.description.url' ${metadata_filepath})"

    # Get textual content of the url
    # TODO: support docker
    # local url_content="$(url_textual_content ${url})"
    local url_content=null

    # Output Description constructor to MeTTa
    cat <<EOF
(MkDescription
           ; url
           ${url}
           ; url content
           ${url_content}
           ; description
           $(jq '.description.description' ${metadata_filepath})
           ; short_description
           $(jq '.description.short_description' ${metadata_filepath}))
EOF
}

# Take a metadata file of a service and output its description in
# MeTTa format.
service_description_to_metta() {
    local metadata_filepath="$1"
    local url="$(jq '.service_description.url' ${metadata_filepath})"

    # Get textual content of the url
    # TODO: support docker
    # local url_content="$(url_textual_content ${url})"
    local url_content=null

    # Output ServiceDescription constructor to MeTTa
    cat <<EOF
(MkServiceDescription
           ; url
           ${url}
           ; url content
           ${url_content}
           ; description
           $(jq '.service_description.description' ${metadata_filepath})
           ; short_description
           $(jq '.service_description.short_description' ${metadata_filepath}))
EOF
}

contributors_to_metta() {
    local metadata_filepath="$1"
    # TODO
    echo "Nil"
}

media_to_metta() {
    local metadata_filepath="$1"
    # TODO
    echo "Nil"
}

tags_to_metta() {
    local metadata_filepath="$1"
    local tags=Nil
    local tags_length=$(jq '.tags | length' ${metadata_filepath})
    for i in $(seq 0 $((tags_length - 1)))
    do
        jq_cmd=".tags[${i}]"
        tags="(Cons $(jq ${jq_cmd} ${metadata_filepath}) ${tags})"
    done
    echo "${tags}"
}

########
# Main #
########

# # Test tags_to_metta
# tags_to_metta json/snet.zeta36-chess-alpha-zero.json
# exit 0

# Set the network to mainnet
snet network mainnet

# Create metta and json subfolders
mkdir metta 2> /dev/null
mkdir json 2> /dev/null

# Write header
cat <<EOF > ${METTA_FILEPATH}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; File generated by gen-snet-marketplace-space.sh                     ;;
;;                                                                     ;;
;; It contains:                                                        ;;
;;                                                                     ;;
;; 1. a description of all AI services on the marketplace;             ;;
;; 2. the relationship between AI services, such as their potential    ;;
;;    connectivity (whether the output of a given service can be used  ;;
;;    as input of another).                                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EOF

# Write type definitions
cat <<EOF >> ${METTA_FILEPATH}
;;;;;;;;;;;;;;;;;;;;;;
;; Type Definitions ;;
;;;;;;;;;;;;;;;;;;;;;;

EOF
type_definitions_to_metta >> ${METTA_FILEPATH}

# Write organizations
cat <<EOF >> ${METTA_FILEPATH}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SingularityNET MarketPlace Data ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
EOF
for org in $(snet organization list | tail --lines=+2); do
    echo >> ${METTA_FILEPATH}
    organization_to_metta "${org}" >> ${METTA_FILEPATH}
done

# Output concluding messages
log "During the process the following metadata JSON files have been generated under the json subfolder"
ls json/*.json
log "The following metta file has been generated under the metta folder"
log "${METTA_FILEPATH}"
log
log "If you ran that script via the provided docker container, you may run the following command to copy the json files to the host:"
log
log "for f in $(ls json | tr '\n' ' '); do docker cp snet-marketplace-space-container:/home/user/json/\${f} json; done"
log
log "If you ran that script via the provided docker container, you may run the following command to copy the metta file to the host:"
log "docker cp snet-marketplace-space-container:/home/user/metta/${METTA_FILENAME} metta"
