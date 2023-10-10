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

# Output type, constructor and access function definitions in MeTTa
# format.
type_definitions_to_metta() {
cat <<EOF
;; Define List type and constructor
(: List (-> \$a Type))
(: Nil (List \$a))
(: Cons (-> \$a (List \$a) (List \$a)))

;; Define OrganizationID type
(: OrganizationID Type)

;; NEXT: define Organization type, with access function from
;; OrganizationID to Organization.

;; Define ServiceID type.  A service ID must be associated to an
;; organization ID.
(: ServiceID (-> OrganizationID Type))

;; Define accessibility function from service ID to service data
;; structure (see Service defined further below).
(: service (-> (ServiceID \$org) Service))

;; Define Pricing type
(: Pricing Type)

;; Define Pricing constructor
(: MkPricing (-> String      ; price_model
                 Number      ; price_in_cogs
                 Bool        ; default
                 Pricing))

;; Define Pricing access functions, price_model, price_in_cogs and default
(: Pricing.price_model (-> Pricing String))
(= (price_model (MkPricing \$price_model
                           \$price_in_cogs
                           \$default)) \$price_mode)
(: Pricing.price_in_cogs (-> Pricing Number))
(= (price_in_cog (MkPricing \$price_model
                            \$price_in_cogs
                            \$default)) \$price_in_cogs)
(: Pricing.default (-> Pricing Bool))
(= (Pricing.default (MkPricing \$price_model
                               \$price_in_cogs
                               \$default)) \$default)

;; Define Group type
(: Group Type)

;; Define Group constructor
(: MkGroup (-> String        ; group_name
               Pricing       ; pricing
               (List String) ; endpoints
               String        ; group_id
               Number        ; free_calls
               String        ; free_call_signer_address
               (List String) ; daemon_addresses
               Group))

;; Define Group access functions
(: Group.group_name (-> Group String))
(= (Group.group_name (Group \$group_name
                            \$pricing
                            \$endpoints
                            \$group_id
                            \$free_calls
                            \$free_call_signer_address
                            \$daemon_addresses)) \$group_name)
(: Group.pricing (-> Group Pricing))
(= (Group.pricing (Group \$group_name
                         \$pricing
                         \$endpoints
                         \$group_id
                         \$free_calls
                         \$free_call_signer_address
                         \$daemon_addresses)) \$pricing)
(: Group.endpoints (-> Group (List String)))
(= (Group.endpoints (Group \$group_name
                           \$pricing
                           \$endpoints
                           \$group_id
                           \$free_calls
                           \$free_call_signer_address
                           \$daemon_addresses)) \$endpoints)
(: Group.group_id (-> Group String))
(= (Group.group_id (Group \$group_name
                           \$pricing
                           \$endpoints
                           \$group_id
                           \$free_calls
                           \$free_call_signer_address
                           \$daemon_addresses)) \$group_id)
(: Group.free_calls (-> Group Number))
(= (Group.free_calls (Group \$group_name
                            \$pricing
                            \$endpoints
                            \$group_id
                            \$free_calls
                            \$free_call_signer_address
                            \$daemon_addresses)) \$free_calls)
(: Group.free_call_signer_address (-> Group String))
(= (Group.free_call_signer_address (Group \$group_name
                                          \$pricing
                                          \$endpoints
                                          \$group_id
                                          \$free_calls
                                          \$free_call_signer_address
                                          \$daemon_addresses)) \$free_call_signer_address)
(: Group.daemon_addresses (-> Group (List String)))
(= (Group.daemon_addresses (Group \$group_name
                                  \$pricing
                                  \$endpoints
                                  \$group_id
                                  \$free_calls
                                  \$free_call_signer_address
                                  \$daemon_addresses)) \$daemon_addresses)

;; Define ServiceDescription type
(: ServiceDescription Type)

;; Define ServiceDescription constructor
(: MkServiceDescription (-> String               ; url
                            String               ; description
                            String               ; short_description
                            ServiceDescription))

;; Define ServiceDescription access functions
(: ServiceDescription.url (-> ServiceDescription String))
(= (ServiceDescription.url (MkServiceDescription \$url
                                                 \$description
                                                 \$short_description)) \$url)
(: ServiceDescription.description (-> ServiceDescription String))
(= (ServiceDescription.description (MkServiceDescription \$url
                                                         \$description
                                                         \$short_description)) \$description)
(: ServiceDescription.short_description (-> ServiceDescription String))
(= (ServiceDescription.short_description (MkServiceDescription \$url
                                                               \$description
                                                               \$short_description)) \$short_description)

;; Define Contributor type
(: Contributor Type)

;; Define Contributor constructor
(: MkContributor (-> String  ; name
                     String  ; email_id
                     Contributor))

;; Define Contributor access functions
(: Contributor.name (-> Contributor String))
(= (Contributor.name (MkContributor \$name
                                    \$email_id)) \$name)
(: Contributor.email_id (-> Contributor String))
(= (Contributor.email_id (MkContributor \$name
                                        \$email_id)) \$email_id)

;; Define Media type
(: Medium Type)

;; Define Medium constructor
(: MkMedium (-> Number  ; order
                String  ; url
                String  ; file_type
                String  ; alt_text
                Medium))

;; Define Medium access functions
(: Medium.order (-> Medium Number))
(= (Medium.order (Medium \$order
                         \$url
                         \$file_type
                         \$alt_text)) \$order)
(: Medium.url (-> Medium String))
(= (Medium.url (Medium \$order
                       \$url
                       \$file_type
                       \$alt_text)) \$url)
(: Medium.file_type (-> Medium String))
(= (Medium.file_type (Medium \$order
                             \$url
                             \$file_type
                             \$alt_text)) \$file_type)
(: Medium.alt_text (-> Medium String))
(= (Medium.alt_text (Medium \$order
                            \$url
                            \$file_type
                            \$alt_text)) \$alt_text)

;; Define Service type
(: Service Type)

;; Define Service constructor, called as follows
(: MkService (-> Number             ; version
                 String             ; display_name
                 String             ; encoding
                 String             ; service_type
                 String             ; model_ipfs_hash
                 String             ; mpe_address
                 (List Group)       ; groups
                 ServiceDescription ; service_description
                 (List Contributor) ; contributors
                 (List Medium)      ; media
                 (List String)      ; tags
                 Service))

;; Define Service access functions
(: Service.version (-> Service Number))
(= (Service.version (MkService \$version
                               \$display_name
                               \$encoding
                               \$service_type
                               \$model_ipfs_hash
                               \$mpe_address
                               \$groups
                               \$service_description
                               \$contributors
                               \$media
                               \$tags)) \$version)
(: Service.display_name (-> Service String))
(= (Service.display_name (MkService \$version
                                    \$display_name
                                    \$encoding
                                    \$service_type
                                    \$model_ipfs_hash
                                    \$mpe_address
                                    \$groups
                                    \$service_description
                                    \$contributors
                                    \$media
                                    \$tags)) \$display_name)
(: Service.encoding (-> Service String))
(= (Service.encoding (MkService \$version
                                \$display_name
                                \$encoding
                                \$service_type
                                \$model_ipfs_hash
                                \$mpe_address
                                \$groups
                                \$service_description
                                \$contributors
                                \$media
                                \$tags)) \$encoding)
(: Service.service_type (-> Service String))
(= (Service.service_type (MkService \$version
                                    \$display_name
                                    \$encoding
                                    \$service_type
                                    \$model_ipfs_hash
                                    \$mpe_address
                                    \$groups
                                    \$service_description
                                    \$contributors
                                    \$media
                                    \$tags)) \$service_type)
(: Service.model_ipfs_hash (-> Service String))
(= (Service.model_ipfs_hash (MkService \$version
                                       \$display_name
                                       \$encoding
                                       \$service_type
                                       \$model_ipfs_hash
                                       \$mpe_address
                                       \$groups
                                       \$service_description
                                       \$contributors
                                       \$media
                                       \$tags)) \$model_ipfs_hash)
(: Service.mpe_address (-> Service String))
(= (Service.mpe_address (MkService \$version
                                   \$display_name
                                   \$encoding
                                   \$service_type
                                   \$model_ipfs_hash
                                   \$mpe_address
                                   \$groups
                                   \$service_description
                                   \$contributors
                                   \$media
                                   \$tags)) \$mpe_address)
(: Service.groups (-> Service (List Group)))
(= (Service.groups (MkService \$version
                              \$display_name
                              \$encoding
                              \$service_type
                              \$model_ipfs_hash
                              \$mpe_address
                              \$groups
                              \$service_description
                              \$contributors
                              \$media
                              \$tags)) \$groups)
(: Service.service_description (-> Service ServiceDescription))
(= (Service.service_description (MkService \$version
                                           \$display_name
                                           \$encoding
                                           \$service_type
                                           \$model_ipfs_hash
                                           \$mpe_address
                                           \$groups
                                           \$service_description
                                           \$contributors
                                           \$media
                                           \$tags)) \$service_description)
(: Service.contributors (-> Service (List Contributor)))
(= (Service.contributors (MkService \$version
                                    \$display_name
                                    \$encoding
                                    \$service_type
                                    \$model_ipfs_hash
                                    \$mpe_address
                                    \$groups
                                    \$service_description
                                    \$contributors
                                    \$media
                                    \$tags)) \$contributors)
(: Service.media (-> Service (List Medium)))
(= (Service.media (MkService \$version
                             \$display_name
                             \$encoding
                             \$service_type
                             \$model_ipfs_hash
                             \$mpe_address
                             \$groups
                             \$service_description
                             \$contributors
                             \$media
                             \$tags)) \$media)
(: Service.tags (-> Service (List String)))
(= (Service.tags (MkService \$version
                            \$display_name
                            \$encoding
                            \$service_type
                            \$model_ipfs_hash
                            \$mpe_address
                            \$groups
                            \$service_description
                            \$contributors
                            \$media
                            \$tags)) \$tags)
EOF
}

# Takes the organization id as first argument and outputs knowledge
# about that organization in MeTTa format.
organization_to_metta() {
    local org="$1"
    echo "(: ${org} OrganizationID)"
    echo
    echo ";; Services of ${org}"
    for service in $(snet organization list-services ${org} | tail --lines=+3 | cut -f2 -d" "); do
        service_to_metta ${org} ${service}
    done
}

# Takes the organization id as first argument and service as second
# argument and outputs knowledge about that service in MeTTa format.
service_to_metta() {
    local org="$1"
    local service="$2"

    # Save json metadata of that service in temporary file
    local metadata_file=${org}-${service}-metadata.json
    snet service print-metadata ${org} ${service} > ${metadata_file}

    # Output service data
    cat <<EOF

;; Service declaration of ${org}.${service}"
(: ${org}.${service} (ServiceID ${org}))

;; Service metadata of ${org}.${service}
(= (service ${org}.${service})
   ; Service
   (MkService
       ; version
       $(jq '.version' ${metadata_file})
       ; display_name
       $(jq '.display_name' ${metadata_file})
       ; encoding
       $(jq '.encoding' ${metadata_file})
       ; service_type
       $(jq '.service_type' ${metadata_file})
       ; model_ipfs_hash
       $(jq '.model_ipfs_hash' ${metadata_file})
       ; mpe_address
       $(jq '.mpe_address' ${metadata_file})
       ; groups
       $(groups_to_metta ${metadata_file})
       ; service_description
       $(service_description_to_metta ${metadata_file})
       ; contributors
       $(contributors_to_metta ${metadata_file})
       ; media
       $(media_to_metta ${metadata_file})
       ; tags
       $(tags_to_metta ${metadata_file})
   )
)
EOF
}

# Take a metadata file of the service an output its groups in MeTTa
# format.
groups_to_metta() {
    local metadata_file="$1"
    local groups_length=$(jq '.groups | length' ${metadata_file})
    # NEXT: see https://www.baeldung.com/linux/jq-command-json to deal with array
    echo "Nil"
}

# Take a metadata file of the service and output its service
# description in MeTTa format.
service_description_to_metta() {
    local metadata_file="$1"
    local url="$(jq '.service_description.url' ${metadata_file})"

    # Detect browser to read content of url.  Only chromium and
    # google-chrome are supported because they provide headless
    # javascript rendering (firefox does not support that).
    if [ -z $(command -v chromium) ]
    then if [ -z $(command -v google-chrome) ]
         then echo "chromium or google-chrome is required"
              exit 1
         else browser=google-chrome
         fi
    else browser=chromium
    fi

    # Get textual content of the url
    # local url_content="$($browser --headless --disable-gpu --dump-dom "${url}" | html2text)"
    local url_content="null"

    # Output ServiceDescription constructor to MeTTa
    cat <<EOF
(MkServiceDescription
           ; url
           ${url}
           ; url content
           \""${url_content}"\"
           ; description
           $(jq '.service_description.description' ${metadata_file})
           ; short_description
           $(jq '.service_description.short_description' ${metadata_file}))
EOF
}

contributors_to_metta() {
    local metadata_file="$1"
    # NEXT
    echo "Nil"
}

media_to_metta() {
    local metadata_file="$1"
    # NEXT
    echo "Nil"
}

tags_to_metta() {
    local metadata_file="$1"
    # NEXT
    echo "Nil"
}

########
# Main #
########

# Set the network to mainnet
snet network mainnet

# Write header
cat <<EOF > ${METTA_FILENAME}
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
cat <<EOF >> ${METTA_FILENAME}
;;;;;;;;;;;;;;;;;;;;;;
;; Type Definitions ;;
;;;;;;;;;;;;;;;;;;;;;;

EOF
type_definitions_to_metta >> ${METTA_FILENAME}

# Write organizations
cat <<EOF >> ${METTA_FILENAME}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SingularityNET MarketPlace Data ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
EOF
for org in $(snet organization list | tail --lines=+2); do
    echo "Collect information about ${org}"
    echo >> ${METTA_FILENAME}
    echo ";; Organization: ${org}" >> ${METTA_FILENAME}
    organization_to_metta "${org}" >> ${METTA_FILENAME}
done
echo "Generated ${METTA_FILENAME}"

echo "The following metadata JSON files have been generated as well"
ls *.json

# Example of service metadata
#
# {
#   "version": 1,
#   "display_name": "AI Sight",
#   "encoding": "proto",
#   "service_type": "grpc",
#   "model_ipfs_hash": "QmWEuXDXBfRMedvzbzC52iYYuv4Bgp6w2PTbwcYyKWg1XU",
#   "mpe_address": "0x5e592F9b1d303183d963635f895f0f0C48284f4e",
#   "groups": [
#     {
#       "group_name": "default_group",
#       "pricing": [
#         {
#           "price_model": "fixed_price",
#           "price_in_cogs": 2000000,
#           "default": true
#         }
#       ],
#       "endpoints": [
#         "https://bh.singularitynet.io:7015"
#       ],
#       "group_id": "nZdFbyUlpWfOuTn0WpJCpKtQATrU6gxz6Wn9zAC2mno=",
#       "free_calls": 15,
#       "free_call_signer_address": "0x3Bb9b2499c283cec176e7C707Ecb495B7a961ebf",
#       "daemon_addresses": [
#         "0x92D9f8539D39244Fbe8dEAC771D95cF2A77087CF"
#       ]
#     }
#   ],
#   "service_description": {
#     "url": "https://singnet.github.io/dnn-model-services/users_guide/cntk-image-recon.html",
#     "description": "<div>Images of flowers and dogs can be classified using deep neural network models, generated using Microsoft's Cognitive Toolkit. The service receives an image, and then uses it as an input for a pretrained ResNet152 model.<br></br>There are two pre-trained models available, one trained with a flowers dataset from the Oxford Visual Geometry Group, that includes 102 different categories of flowers common to the UK. The second model was trained using the Columbia Dogs Dataset, which possesses 133 different dog breeds.<br></br>The service makes predictions using computer vision and machine learning techniques, and displays a top 5 prediction list (ordered by confidence) based on the specified dataset (flowers or dogs).</div>",
#     "short_description": "Use neural network models generated by Microsoft's Cognitive Toolkit to classify images of flowers and dogs. Simply upload an image and the service will identify and apply a label."
#   },
#   "contributors": [
#     {
#       "name": "Artur Gontigo",
#       "email_id": "artur@singularitynet.io"
#     }
#   ],
#   "media": [
#     {
#       "order": 1,
#       "url": "QmNkP3qpyisaYTJfRW45e7HGRZ3vrjyjsg7QiABbRiWoFu/hero_cntk_image_recon.jpg",
#       "file_type": "image",
#       "alt_text": "hero_image",
#       "asset_type": "hero_image"
#     },
#     {
#       "order": 2,
#       "url": "QmRWfXQcA9RKSmiHk6AGkgSrZ4kcfMCWzR26zEZqYAmV1G/gallery_item_1_-_img_recognition_example.png",
#       "file_type": "image",
#       "alt_text": "hover_on_the_image_text"
#     },
#     {
#       "order": 3,
#       "url": "QmSmDd9ByNDE693vcsua3BnhfvZaZLHbfWhGvjCEt67Yu9/gallery_item_2_-_golden-retriever.jpg",
#       "file_type": "image",
#       "alt_text": "hover_on_the_image_text"
#     },
#     {
#       "order": 4,
#       "url": "QmXWwqaoHsHuyMgKASfRCrBYQaCD4hfHodf6PTZoiruB6W/gallery_item_3_-_sunflower.jpg",
#       "file_type": "image",
#       "alt_text": "hover_on_the_image_text"
#     }
#   ],
#   "tags": [
#     "cntk",
#     "image",
#     "recognition"
#   ]
# }
