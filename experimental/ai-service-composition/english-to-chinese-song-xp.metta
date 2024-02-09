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
