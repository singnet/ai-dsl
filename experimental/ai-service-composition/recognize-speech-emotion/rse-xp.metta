;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Experiment with service composition to create a service that
;; recognizes emotion from speech given two services
;;
;; 1. naint.speech2text-en, that turns speech into text.
;;
;; 2. naint.text-emotions, that recognizes emotion in text.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;
;; List ;;
;;;;;;;;;;

;; Declaration of List data type and constructors
(: List (-> $a Type))
(: Nil (List $a))
(: Cons (-> $a (List $a) (List $a)))

;; Build a list from an expression, containing all the sub-expressions
;; as elements of the list.
(: fromExpression (-> Expression (List $a)))
(= (fromExpression $expr) (if (== $expr ())
                              Nil
                              (let* (($head (car-atom $expr))
                                     ($tail (cdr-atom $expr)))
                                (Cons $head (fromExpression $tail)))))

;; Build an expression from a List, composed of all elements of the
;; list as sub-expressions.
(: fromList (-> (List $a) Expression))
(= (fromList Nil) ())
(= (fromList (Cons $head $tail)) (let $tail-sexps (fromList $tail)
                                   (cons-atom $head $tail-sexps)))

;; Check if an element is in a list (sorted or not)
(: elem (-> $a (List $a) Bool))
(= (elem $x Nil) False)
(= (elem $x (Cons $head $tail)) (if (== $x $head) True (elem $x $tail)))

;; Remove duplicates from a list (sorted or not)
(: uniq_ (-> (List $a) (List $a) (List $a)))
(= (uniq_ $acc Nil) Nil)
(= (uniq_ $acc (Cons $head $tail))
   (if (elem $head $acc)
       (uniq_ $acc $tail)
       (Cons $head (uniq_ (Cons $head $acc) $tail))))
(: uniq (-> (List $a) (List $a)))
(= (uniq $l) (uniq_ Nil $l))

;; Remove all duplicated subexpressions of an expression
(: uniqSExpr (-> Expression Expression))
(= (uniqSExpr $expr) (fromList (uniq (fromExpression $expr))))

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

;; Paste directly the content of rse-services.metta instead of
;; importing it to avoid shenanigan.  Names have been shortened when
;; possible to be more readable.
!(bind! &kb (new-space))

;; ;; Import the knowledge base containing services related to
;; ;; recognizing emotion in speech
;; !(import! &kb rse-services)

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; naint.speech2text-en ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;
;; Audio ;;
;;;;;;;;;;;

;; Define naint.speech2text-en.Audio type
!(add-atom &kb (: speech2text-en.Audio Type))

;; Define naint.speech2text-en.Audio constuctor
!(add-atom &kb (: speech2text-en.MkAudio
                  (-> Bytes ; data
                      speech2text-en.Audio)))

;; Define naint.speech2text-en.Audio access functions

;; Define naint.speech2text-en.Audio.data
!(add-atom &kb (: speech2text-en.Audio.data
                  (-> speech2text-en.Audio
                      Bytes)))

;;;;;;;;;;
;; Text ;;
;;;;;;;;;;

;; Define naint.speech2text-en.Text type
!(add-atom &kb (: speech2text-en.Text Type))

;; Define naint.speech2text-en.Text constuctor
!(add-atom &kb (: speech2text-en.MkText
                  (-> String ; text
                      speech2text-en.Text)))

;; Define naint.speech2text-en.Text access functions

;; Define naint.speech2text-en.Text.text
!(add-atom &kb (: speech2text-en.Text.text
                  (-> speech2text-en.Text
                      String)))

;;;;;;;;;;;;;;
;; Services ;;
;;;;;;;;;;;;;;

;;;;;;;;;
;; ASR ;;
;;;;;;;;;

;; Define naint.speech2text-en.s2t service method
!(add-atom &kb (: speech2text-en.s2t
                  (-> speech2text-en.Audio
                      speech2text-en.Text)))

;;;;;;;;;;;;;;;;;;;;;;;;;
;; naint.text-emotions ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;
;; Input ;;
;;;;;;;;;;;

;; Define naint.text-emotions.Input type
!(add-atom &kb (: text-emotions.Input Type))

;; Define naint.text-emotions.Input constuctor
!(add-atom &kb (: text-emotions.MkInput
                  (-> String ; text
                      text-emotions.Input)))

;; Define naint.text-emotions.Input access functions

;; Define naint.text-emotions.Input.text
!(add-atom &kb (: text-emotions.Input.text
                  (-> text-emotions.Input
                      String)))

;;;;;;;;;;;;
;; Output ;;
;;;;;;;;;;;;

;; Define naint.text-emotions.Output type
!(add-atom &kb (: text-emotions.Output Type))

;; Define naint.text-emotions.Output constuctor
!(add-atom &kb (: text-emotions.MkOutput
                  (-> String ; result
                      text-emotions.Output)))

;; Define naint.text-emotions.Output access functions

;; Define naint.text-emotions.Output.result
!(add-atom &kb (: text-emotions.Output.result
                  (-> text-emotions.Output
                      String)))

;;;;;;;;;;;;;;
;; Services ;;
;;;;;;;;;;;;;;

;;;;;;;;;
;; TER ;;
;;;;;;;;;

;; Define naint.text-emotions.recognize service method
!(add-atom &kb (: text-emotions.recognize
                  (-> text-emotions.Input
                      text-emotions.Output)))

;;;;;;;;;;;;;;;;;
;; Combinators ;;
;;;;;;;;;;;;;;;;;

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
          Nat                           ; Maximum depth
          $b                            ; Query with holes
          $b))                          ; Filled query
;; Base case
(= (bc $kb $_ (: $prf $ccln)) (match $kb (: $prf $ccln) (: $prf $ccln)))
;; Recursive step
(= (bc $kb (S $k) (: ($prfabs $prfarg) $ccln))
   (let* (((: $prfabs (-> $prms $ccln)) (bc $kb $k (: $prfabs (-> $prms $ccln))))
          ((: $prfarg $prms) (bc $kb $k (: $prfarg $prms))))
     (: ($prfabs $prfarg) $ccln)))

;;;;;;;;;;;;;;;;;;;;;
;; Reduction rules ;;
;;;;;;;;;;;;;;;;;;;;;

;; Composition to application
(= (((. $g) $f) $x) ($g ($f $x)))

;; Right associate composition, meaning
;;
;; h . g . f
;;
;; should be represented as
;;
;; h . (g . f)
;;
;; or in MeTTa
;;
;; ((. h) ((. g) f))
;;
;; Thus anything deviating from that representation, such as
;;
;; (h . g) . f
;;
;; or in MeTTa
;;
;; ((. ((. h) g)) f)
;;
;; should be rewritten as
;;
;; ((. h) ((. g) f))
;;
;; The reason left associativity is choosen as default over right
;; associativity is because in prefix notation the former is easier to
;; read (to me anyway).
(= ((. ((. $h) $g)) $f) ((. $h) ((. $g) $f)))

;; Eliminate contiguous composition of constructor and deconstructor.
;; speech2text-en.Audio
(= ((. speech2text-en.Audio.data) ((. speech2text-en.MkAudio) $f)) $f)
(= ((. $f) ((. speech2text-en.Audio.data) speech2text-en.MkAudio)) $f)
(= ((. speech2text-en.MkAudio) ((. speech2text-en.Audio.data) $f)) $f)
(= ((. $f) ((. speech2text-en.MkAudio) speech2text-en.Audio.data)) $f)
;; speech2text-en.Text
(= ((. speech2text-en.Text.text) ((. speech2text-en.MkText) $f)) $f)
(= ((. $f) ((. speech2text-en.Text.text) speech2text-en.MkText)) $f)
(= ((. speech2text-en.MkText) ((. speech2text-en.Text.text) $f)) $f)
(= ((. $f) ((. speech2text-en.MkText) speech2text-en.Text.text)) $f)
;; text-emotions.Input
(= ((. text-emotions.Input.text) ((. text-emotions.MkInput) $f)) $f)
(= ((. $f) ((. text-emotions.Input.text) text-emotions.MkInput)) $f)
(= ((. text-emotions.MkInput) ((. text-emotions.Input.text) $f)) $f)
(= ((. $f) ((. text-emotions.MkInput) text-emotions.Input.text)) $f)
;; text-emotions.Output
(= ((. text-emotions.Output.result) ((. text-emotions.MkOutput) $f)) $f)
(= ((. $f) ((. text-emotions.Output.result) text-emotions.MkOutput)) $f)
(= ((. text-emotions.MkOutput) ((. text-emotions.Output.result) $f)) $f)
(= ((. $f) ((. text-emotions.MkOutput) text-emotions.Output.result)) $f)

;;;;;;;;;;
;; Test ;;
;;;;;;;;;;

;; Look for a composition operator
!(bc &kb (fromNumber 0) (: $prg (-> (-> $b $c) (-> (-> $a $b) (-> $a $c)))))

;; Synthesize a program that takes speech as
;; naint.speech2text-en.Audio and returns text as
;; naint.speech2text-en.Text.
!(bc &kb (fromNumber 0) (: $prg (-> speech2text-en.Audio speech2text-en.Text)))

;; Synthesize a program that takes text as naint.text-emotions.Input
;; and returns emotion as naint.text-emotions.Output.
!(bc &kb (fromNumber 0) (: $prg (-> text-emotions.Input text-emotions.Output)))

;; Synthesize a program that takes speech as Bytes and returns speech
;; as naint.speech2text-en.Audio.
!(bc &kb (fromNumber 0) (: $prg (-> Bytes speech2text-en.Audio)))

;; Synthesize a program that takes text as naint.speech2text-en.Text
;; and returns text as String.
!(bc &kb (fromNumber 0) (: $prg (-> speech2text-en.Text String)))

;; Synthesize a program that takes speech as Bytes and returns text as
;; naint.speech2text-en.Text.
!(bc &kb (fromNumber 2) (: $prg (-> Bytes speech2text-en.Text)))

;; Synthesize a program that takes speech as Bytes and returns text as
;; String.
!(bc &kb (fromNumber 3) (: $prg (-> Bytes String)))

;; Synthesize a program that takes text as String and returns emotion
;; as String.
!(bc &kb (fromNumber 3) (: $prg (-> String String)))

;; Synthesize a program that takes speech as Bytes and returns text or
;; emotion as String.
!(bc &kb (fromNumber 5) (: $prg (-> Bytes String)))

;; Synthesize a program that takes speech as
;; naint.speech2text-en.Audio and returns emotion as
;; naint.text-emotions.Output.
!(unique
  (bc &kb
      (fromNumber 4)
      (: $prg (-> speech2text-en.Audio text-emotions.Output))))
