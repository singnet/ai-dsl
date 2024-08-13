;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Experiment with service composition to create a service that
;; recognizes emotion from speech given two services
;;
;; 1. naint.speech2text-en, that turns speech into text.
;;
;; 2. naint.text-emotions, that recognizes emotion in text.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

;; Import the knowledge base containing services related to
;; recognizing emotion in speech
!(import! &kb recognize-speech-emotion-services.metta)

;; Complete the knowledge base with inference rules
!(add-atom &kb (: .                      ; Composition
                  (-> (-> $b $c)         ; Premise 1
                      (-> (-> $a $b)     ; Premise 2
                          (-> $a $c))))) ; Conclusion

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

;;;;;;;;;;
;; Test ;;
;;;;;;;;;;

;; Look for a composition operator
!(bc &kb (: $prg (-> (-> $b $c) (-> (-> $a $b) (-> $a $c)))) (fromNumber 0))

;; Synthesize a program that takes speech as
;; naint.speech2text-en.Audio and returns text as
;; naint.speech2text-en.Text.
!(bc &kb
     (: $prg (-> naint.speech2text-en.Audio naint.speech2text-en.Text))
     (fromNumber 0))

;; Synthesize a program that takes text as naint.text-emotions.Input
;; and returns emotion as naint.text-emotions.Output.
!(bc &kb
     (: $prg (-> naint.text-emotions.Input naint.text-emotions.Output))
     (fromNumber 0))

;; Synthesize a program that takes speech as Bytes and returns speech
;; as naint.speech2text-en.Audio.
!(bc &kb
     (: $prg (-> Bytes naint.speech2text-en.Audio))
     (fromNumber 0))

;; Synthesize a program that takes text as naint.speech2text-en.Text
;; and returns text as String.
!(bc &kb
     (: $prg (-> naint.speech2text-en.Text String))
     (fromNumber 0))

;; Synthesize a program that takes speech as Bytes and returns text as
;; naint.speech2text-en.Text.
!(bc &kb (: $prg (-> Bytes naint.speech2text-en.Text)) (fromNumber 2))

;; Synthesize a program that takes speech as Bytes and returns text as
;; String.
!(bc &kb (: $prg (-> Bytes String)) (fromNumber 3))

;; Synthesize a program that takes text as String and returns emotion
;; as String.
!(bc &kb (: $prg (-> String String)) (fromNumber 3))

;; Synthesize a program that takes speech as Bytes and returns text or
;; emotion as String.
!(bc &kb (: $prg (-> Bytes String)) (fromNumber 5))

;; Synthesize a program that takes speech as
;; naint.speech2text-en.Audio and returns emotion as
;; naint.text-emotions.Output.
!(bc &kb
     (: $prg (-> naint.speech2text-en.Audio naint.text-emotions.Output))
     (fromNumber 4))
