;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Services involved in creating a composite service to recognize
;; emotion from speech.
;;
;; The service specifications are obtained from the output of
;;
;; snet-marketplace-metta/gen-snet-marketplace-metta.sh \
;;   naint.speech2text-en \
;;   naint.text-emotions
;;
;; then curated to retain only the information about the type
;; signatures of service calls.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; naint.speech2text-en ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;
;; Audio ;;
;;;;;;;;;;;

;; Define naint.speech2text-en.Audio type
(: naint.speech2text-en.Audio Type)

;; Define naint.speech2text-en.Audio constuctor
(: naint.speech2text-en.MkAudio
   (->
    Bytes ; data
    naint.speech2text-en.Audio))

;; Define naint.speech2text-en.Audio access functions

;; Define naint.speech2text-en.Audio.data
(: naint.speech2text-en.Audio.data (-> naint.speech2text-en.Audio Bytes))

;;;;;;;;;;
;; Text ;;
;;;;;;;;;;

;; Define naint.speech2text-en.Text type
(: naint.speech2text-en.Text Type)

;; Define naint.speech2text-en.Text constuctor
(: naint.speech2text-en.MkText
   (->
    String ; text
    naint.speech2text-en.Text))

;; Define naint.speech2text-en.Text access functions

;; Define naint.speech2text-en.Text.text
(: naint.speech2text-en.Text.text (-> naint.speech2text-en.Text String))

;;;;;;;;;;;;;;
;; Services ;;
;;;;;;;;;;;;;;

;;;;;;;;;
;; ASR ;;
;;;;;;;;;

;; Define naint.speech2text-en.s2t service method
(: naint.speech2text-en.s2t (-> naint.speech2text-en.Audio naint.speech2text-en.Text))

;;;;;;;;;;;;;;;;;;;;;;;;;
;; naint.text-emotions ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;
;; Input ;;
;;;;;;;;;;;

;; Define naint.text-emotions.Input type
(: naint.text-emotions.Input Type)

;; Define naint.text-emotions.Input constuctor
(: naint.text-emotions.MkInput
   (->
    String ; text
    naint.text-emotions.Input))

;; Define naint.text-emotions.Input access functions

;; Define naint.text-emotions.Input.text
(: naint.text-emotions.Input.text (-> naint.text-emotions.Input String))

;;;;;;;;;;;;
;; Output ;;
;;;;;;;;;;;;

;; Define naint.text-emotions.Output type
(: naint.text-emotions.Output Type)

;; Define naint.text-emotions.Output constuctor
(: naint.text-emotions.MkOutput
   (->
    String ; result
    naint.text-emotions.Output))

;; Define naint.text-emotions.Output access functions

;; Define naint.text-emotions.Output.result
(: naint.text-emotions.Output.result (-> naint.text-emotions.Output String))

;;;;;;;;;;;;;;
;; Services ;;
;;;;;;;;;;;;;;

;;;;;;;;;
;; TER ;;
;;;;;;;;;

;; Define naint.text-emotions.recognize service method
(: naint.text-emotions.recognize (-> naint.text-emotions.Input naint.text-emotions.Output))
