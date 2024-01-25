;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Services involved in creating a composite service to turn English
;; singing into Chinese singing.
;;
;; The service specifications are obtained from the output of
;;
;; snet-marketplace-metta/gen-snet-marketplace-metta.sh \
;;   naint.machine-translation \
;;   naint.midi2voice-zh \
;;   snet.sound-spleeter \
;;   snet.speech-recognition
;;
;; then curated to retain only the information about the type
;; signatures of service calls.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; naint.machine-translation ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;
;; Input ;;
;;;;;;;;;;;

;; Define naint.machine-translation.Input type
(: naint.machine-translation.Input Type)

;; Define naint.machine-translation.Input constuctor
(: naint.machine-translation.MkInput
   (->
    String ; source_lang
    String ; target_lang
    String ; sentences_url
    naint.machine-translation.Input))

;; Define naint.machine-translation.Input access functions

;; Define naint.machine-translation.Input.source_lang
(: naint.machine-translation.Input.source_lang (-> naint.machine-translation.Input String))
(= (naint.machine-translation.Input.source_lang
    (naint.machine-translation.MkInput
     $source_lang
     $target_lang
     $sentences_url)) $source_lang)

;; Define naint.machine-translation.Input.target_lang
(: naint.machine-translation.Input.target_lang (-> naint.machine-translation.Input String))
(= (naint.machine-translation.Input.target_lang
    (naint.machine-translation.MkInput
     $source_lang
     $target_lang
     $sentences_url)) $target_lang)

;; Define naint.machine-translation.Input.sentences_url
(: naint.machine-translation.Input.sentences_url (-> naint.machine-translation.Input String))
(= (naint.machine-translation.Input.sentences_url
    (naint.machine-translation.MkInput
     $source_lang
     $target_lang
     $sentences_url)) $sentences_url)

;;;;;;;;;;;;
;; Output ;;
;;;;;;;;;;;;

;; Define naint.machine-translation.Output type
(: naint.machine-translation.Output Type)

;; Define naint.machine-translation.Output constuctor
(: naint.machine-translation.MkOutput
   (->
    String ; translation
    naint.machine-translation.Output))

;; Define naint.machine-translation.Output access functions

;; Define naint.machine-translation.Output.translation
(: naint.machine-translation.Output.translation (-> naint.machine-translation.Output String))
(= (naint.machine-translation.Output.translation
    (naint.machine-translation.MkOutput
     $translation)) $translation)

;;;;;;;;;;;;;;
;; Services ;;
;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;
;; RomanceTranslator ;;
;;;;;;;;;;;;;;;;;;;;;;;

;; Define naint.machine-translation.translate service method
(: naint.machine-translation.translate (-> naint.machine-translation.Input naint.machine-translation.Output))

;;;;;;;;;;;;;;;;;;;;;;;;;
;; naint.midi2voice-zh ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;
;; Query ;;
;;;;;;;;;;;

;; Define naint.midi2voice-zh.Query type
(: naint.midi2voice-zh.Query Type)

;; Define naint.midi2voice-zh.Query constuctor
(: naint.midi2voice-zh.MkQuery
   (->
    String ; text
    Bytes ; midi_file
    Float ; normalize
    naint.midi2voice-zh.Query))

;; Define naint.midi2voice-zh.Query access functions

;; Define naint.midi2voice-zh.Query.text
(: naint.midi2voice-zh.Query.text (-> naint.midi2voice-zh.Query String))
(= (naint.midi2voice-zh.Query.text
    (naint.midi2voice-zh.MkQuery
     $text
     $midi_file
     $normalize)) $text)

;; Define naint.midi2voice-zh.Query.midi_file
(: naint.midi2voice-zh.Query.midi_file (-> naint.midi2voice-zh.Query Bytes))
(= (naint.midi2voice-zh.Query.midi_file
    (naint.midi2voice-zh.MkQuery
     $text
     $midi_file
     $normalize)) $midi_file)

;; Define naint.midi2voice-zh.Query.normalize
(: naint.midi2voice-zh.Query.normalize (-> naint.midi2voice-zh.Query Float))
(= (naint.midi2voice-zh.Query.normalize
    (naint.midi2voice-zh.MkQuery
     $text
     $midi_file
     $normalize)) $normalize)

;;;;;;;;;;;;
;; Answer ;;
;;;;;;;;;;;;

;; Define naint.midi2voice-zh.Answer type
(: naint.midi2voice-zh.Answer Type)

;; Define naint.midi2voice-zh.Answer constuctor
(: naint.midi2voice-zh.MkAnswer
   (->
    Bytes ; output_audio
    naint.midi2voice-zh.Answer))

;; Define naint.midi2voice-zh.Answer access functions

;; Define naint.midi2voice-zh.Answer.output_audio
(: naint.midi2voice-zh.Answer.output_audio (-> naint.midi2voice-zh.Answer Bytes))
(= (naint.midi2voice-zh.Answer.output_audio
    (naint.midi2voice-zh.MkAnswer
     $output_audio)) $output_audio)

;;;;;;;;;;;;;;
;; Services ;;
;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;
;; singingZH ;;
;;;;;;;;;;;;;;;

;; Define naint.midi2voice-zh.singingZH service method
(: naint.midi2voice-zh.singingZH (-> naint.midi2voice-zh.Query naint.midi2voice-zh.Answer))

;;;;;;;;;;;;;;;;;;;;;;;;;
;; snet.sound-spleeter ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;
;; Input ;;
;;;;;;;;;;;

;; Define snet.sound-spleeter.Input type
(: snet.sound-spleeter.Input Type)

;; Define snet.sound-spleeter.Input constuctor
(: snet.sound-spleeter.MkInput
   (->
    String ; audio_url
    Bytes ; audio
    snet.sound-spleeter.Input))

;; Define snet.sound-spleeter.Input access functions

;; Define snet.sound-spleeter.Input.audio_url
(: snet.sound-spleeter.Input.audio_url (-> snet.sound-spleeter.Input String))
(= (snet.sound-spleeter.Input.audio_url
    (snet.sound-spleeter.MkInput
     $audio_url
     $audio)) $audio_url)

;; Define snet.sound-spleeter.Input.audio
(: snet.sound-spleeter.Input.audio (-> snet.sound-spleeter.Input Bytes))
(= (snet.sound-spleeter.Input.audio
    (snet.sound-spleeter.MkInput
     $audio_url
     $audio)) $audio)

;;;;;;;;;;;;
;; Output ;;
;;;;;;;;;;;;

;; Define snet.sound-spleeter.Output type
(: snet.sound-spleeter.Output Type)

;; Define snet.sound-spleeter.Output constuctor
(: snet.sound-spleeter.MkOutput
   (->
    Bytes ; vocals
    Bytes ; accomp
    snet.sound-spleeter.Output))

;; Define snet.sound-spleeter.Output access functions

;; Define snet.sound-spleeter.Output.vocals
(: snet.sound-spleeter.Output.vocals (-> snet.sound-spleeter.Output Bytes))
(= (snet.sound-spleeter.Output.vocals
    (snet.sound-spleeter.MkOutput
     $vocals
     $accomp)) $vocals)

;; Define snet.sound-spleeter.Output.accomp
(: snet.sound-spleeter.Output.accomp (-> snet.sound-spleeter.Output Bytes))
(= (snet.sound-spleeter.Output.accomp
    (snet.sound-spleeter.MkOutput
     $vocals
     $accomp)) $accomp)

;;;;;;;;;;;;;;
;; Services ;;
;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;
;; SoundSpleeter ;;
;;;;;;;;;;;;;;;;;;;

;; Define snet.sound-spleeter.spleeter service method
(: snet.sound-spleeter.spleeter (-> snet.sound-spleeter.Input snet.sound-spleeter.Output))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; snet.speech-recognition ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;
;; Audio ;;
;;;;;;;;;;;

;; Define snet.speech-recognition.Audio type
(: snet.speech-recognition.Audio Type)

;; Define snet.speech-recognition.Audio constuctor
(: snet.speech-recognition.MkAudio
   (->
    Bytes ; data
    snet.speech-recognition.Audio))

;; Define snet.speech-recognition.Audio access functions

;; Define snet.speech-recognition.Audio.data
(: snet.speech-recognition.Audio.data (-> snet.speech-recognition.Audio Bytes))
(= (snet.speech-recognition.Audio.data
    (snet.speech-recognition.MkAudio
     $data)) $data)

;;;;;;;;;;
;; Text ;;
;;;;;;;;;;

;; Define snet.speech-recognition.Text type
(: snet.speech-recognition.Text Type)

;; Define snet.speech-recognition.Text constuctor
(: snet.speech-recognition.MkText
   (->
    String ; text
    snet.speech-recognition.Text))

;; Define snet.speech-recognition.Text access functions

;; Define snet.speech-recognition.Text.text
(: snet.speech-recognition.Text.text (-> snet.speech-recognition.Text String))
(= (snet.speech-recognition.Text.text
    (snet.speech-recognition.MkText
     $text)) $text)

;;;;;;;;;;;;;;
;; Services ;;
;;;;;;;;;;;;;;

;;;;;;;;;
;; ASR ;;
;;;;;;;;;

;; Define snet.speech-recognition.s2t service method
(: snet.speech-recognition.s2t (-> snet.speech-recognition.Audio snet.speech-recognition.Text))
