;;;;;;;;;
;; Nat ;;
;;;;;;;;;

;; Define Nat
(: Nat Type)
(: Z Nat)
(: S (-> Nat Nat))

;; Define <=
(: <= (-> $a $a Bool))
(= (<= $x $y) (or (< $x $y) (== $x $y)))

;; Define cast functions between Nat and Number
(: fromNumber (-> Number Nat))
(= (fromNumber $n) (if (<= $n 0) Z (S (fromNumber (- $n 1)))))
(: fromNat (-> Nat Number))
(= (fromNat Z) 0)
(= (fromNat (S $k)) (+ 1 (fromNat $k)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Knowledge and rule base ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Import the knowledge base containing services pertaining to the
;; task of turning an English song into a Chinese song.
!(import! &kb english-to-chinese-song-services.metta)

;; Complete the knowledge base with inference rules
!(add-atom &kb (: .                      ; Composition
                  (-> (-> $b $c)         ; Premise 1
                      (-> (-> $a $b)     ; Premise 2
                          (-> $a $c))))) ; Conclusion

;; ;; K combinator
;; !(add-atom &kb (: AK (-> $a            ; Premise
;;                          (-> $b $a)))) ; Conclusion

;; ;; S combinator
;; !(add-atom &kb (: AS (-> (-> $a (-> $b $c))        ; Premise 1
;;                          (-> (-> $a $b)            ; Premise 2
;;                              (-> $a $c)))))        ; Conclusion

;;;;;;;;;;;;;;;;;;;;;;
;; Backward chainer ;;
;;;;;;;;;;;;;;;;;;;;;;

;; Define backward chainer, curried version.  Takes in input
;;
;; 1. A knowledge and rule base as space.
;;
;; 2. Query of the form (: PROOF THEOREM) where both PROOF and THEOREM
;;    may contain free variables, to be treated as holes.
;;
;; 2. Depth, maximum depth of the proof to synthesize.
;;
;; and returns the same query with the holes filled.  If multiple
;; exists they are all returned as alternate branches of a
;; non-deterministic execution.
(: bc (-> $a                            ; Knowledge and rule base space
          $b                            ; Query with holes
          Nat                           ; Maximum depth
          $b))                          ; Filled query
;; Base case
(= (bc $kb (: $prf $ccln) $_) (match $kb (: $prf $ccln) (: $prf $ccln)))
;; Recursive step
(= (bc $kb (: ($prfabs $prfarg) $ccln) (S $k))
   (let* (((: $prfabs (-> $prms $ccln)) (bc $kb (: $prfabs (-> $prms $ccln)) $k))
          ((: $prfarg $prms) (bc $kb (: $prfarg $prms) $k)))
     (: ($prfabs $prfarg) $ccln)))

;;;;;;;;;;;;;;;;;;;;;
;; Reduction rules ;;
;;;;;;;;;;;;;;;;;;;;;

;; Composition to application
(= (((. $g) $f) $x) ($g ($f $x)))

;; Composition left associate (NEXT check if the name is appropriate)
(= ((. $h) ((. $g) $f)) ((. ((. $h) $g)) $f))

;; Combinators to composition
(= ((AS (AK AS)) AK) .)

;; Combinators to identity
(= ((AS AK) AK) ID)

;; Identity application elimination
(= (ID $x) $x)

;; Identity composition elimination
(= ((. ID) $f) $f)
(= ((. $f) ID) $f)

;; Deconstruct;construct to identity
(= ((. naint.machine-translation.MkOutput) naint.machine-translation.Output.translation) ID)
(= ((. naint.midi2voice-zh.MkAnswer) naint.midi2voice-zh.Answer.output_audio) ID)
(= ((. snet.speech-recognition.MkAudio) snet.speech-recognition.Audio.data) ID)
(= ((. tomidi.MkAudio) tomidi.Audio.data) ID)
(= ((. tomidi.MkMIDI) tomidi.MIDI.data) ID)
(= ((. mixer.MkAudio) mixer.Audio.data) ID)

;; Construct;deconstruct to identity
(= ((. naint.machine-translation.Output.translation) naint.machine-translation.MkOutput) ID)
(= ((. naint.midi2voice-zh.Answer.output_audio) naint.midi2voice-zh.MkAnswer) ID)
(= ((. snet.speech-recognition.Audio.data) snet.speech-recognition.MkAudio) ID)
(= ((. tomidi.Audio.data) tomidi.MkAudio) ID)
(= ((. tomidi.MIDI.data) tomidi.MkMIDI) ID)
(= ((. mixer.Audio.data) mixer.MkAudio) ID)

;;;;;;;;;;
;; Test ;;
;;;;;;;;;;

;; Look for a composition operator
!(bc &kb (: $prg (-> (-> $b $c) (-> (-> $a $b) (-> $a $c)))) (fromNumber 0))

;; Look for a program that takes a source_lang as String, a
;; target_lang as String, a sentences_url as String and returns a
;; naint.machine-translation.Input.
!(bc &kb
     (: $prg (-> String (-> String (-> String naint.machine-translation.Input))))
     (fromNumber 0))

;; Look for a program that takes au audio stream as Bytes, supposed to
;; be English singing, and return an audio stream as Bytes, supposed
;; to be Chinese singing.
!(bc &kb (: $prf (-> Bytes Bytes)) (fromNumber 4))

;; Verify that a program expressing turning English song to Chinese is
;; well typed.
!(bc &kb (: NEXT (-> Bytes Bytes)) (fromNumber 8))

;; NEXT: translate the following to combinatory logic (or something
;; else).
;;
;; NEXT: think of how to deal with parallelization (ToMidi and
;; (ToChinese . ToText) can happen in parallel).
(= (english-song-to-chinese-song $input)
   (let* (($spleeter-output ((snet.sound-spleeter.MkInput "") $input))
          ($english-vocals (snet.sound-spleeter.Output.vocals $spleeter-output))
          ($chinese-lyrics (naint.machine-translation.Output.translation
                            (naint.machine-translation.translate
                             (((naint.machine-translation.MkInput "English") "Chinese")
                              (snet.speech-recognition.Text.text
                               (snet.speech-recognition.s2t
                                (snet.speech-recognition.MkAudio $english-vocals)))))))
          ($midi-notes (tomidi.MIDI.data (tomidi.MkAudio $english-vocals)))
          ($chinese-vocals (naint.midi2voice-zh.Answer.output_audio
                            (naint.midi2voice-zh.singingZH
                             (((naint.midi2voice-zh.MkQuery $chinese-lyrics) $midi-notes) 1.0)))))
     (mixer.Audio.data
      (mixer.mix
       ((mixer.MkMultiAudio (snet.sound-spleeter.Output.accomp $spleeter-output)) $chinese-vocals)))))
