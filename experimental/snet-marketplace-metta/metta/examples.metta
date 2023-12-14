;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Examples of how the information of the SNET Marketplace dump in MeTTa ;;
;; format can be used.                                                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Import SNET Marketplace dump
!(import! &self snet_marketplace_2023-10-12T11:13:25+00:00.metta)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Test organization access functions ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Get the whole Organization data of the snet organization
!(organization snet)

;; Get the URL of the snet organization
!(Description.url (Organization.description (organization snet)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Test service access functions ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Get the whole Service data of the cntk-image-recon service of the
;; snet organization
!(service snet.cntk-image-recon)

;; Get the version of the cntk-image-recon service of the snet
;; organization
!(Service.version (service snet.cntk-image-recon))

;; Get the URL of the description of the cntk-image-recon service of
;; the snet organization
!(ServiceDescription.url (Service.service_description (service snet.cntk-image-recon)))

;; Get the first tag of the cntk-image-recon service of the snet
;; organization
!(head (Service.tags (service snet.cntk-image-recon)))
