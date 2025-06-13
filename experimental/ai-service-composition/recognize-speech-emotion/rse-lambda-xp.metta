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

;;;;;;;;;
;; Nat ;;
;;;;;;;;;

;; Define Nat
(: Nat Type)
(: Z Nat)
(: S (-> Nat Nat))

;; Define cast functions between Nat and Number
(: fromNumber (-> Number Nat))
(= (fromNumber $n) (if (<= $n 0) Z (S (fromNumber (- $n 1)))))
(: fromNat (-> Nat Number))
(= (fromNat Z) 0)
(= (fromNat (S $k)) (+ 1 (fromNat $k)))

;;;;;;;;;;;;;;;;;;;;;
;; De Bruijn Index ;;
;;;;;;;;;;;;;;;;;;;;;

;; Define DeBruijn type
(: DeBruijn Type)

;; Define DeBruijn constructors
(: z DeBruijn)                        ; Zero
(: s (-> DeBruijn DeBruijn))          ; Successor

;;;;;;;;;;;;;;;;;;;;;
;; Match over list ;;
;;;;;;;;;;;;;;;;;;;;;

;; Similar to match but takes a list of terms instead of a space.
(: match' (-> (List Atom) $a $a $a))
(= (match' Nil $pattern $rewrite) (empty))
(= (match' (Cons $head $tail) $pattern $rewrite) (let $pattern $head $rewrite))
(= (match' (Cons $head $tail) $pattern $rewrite) (match' $tail $pattern $rewrite))

;; Test match' on empty list
!(assertEqualToResult
  (match' Nil ($x $y) ($y $x))
  ())

;; Test match' on singleton
!(assertEqual
  (match' (Cons (A B) Nil) ($x $y) ($y $x))
  (B A))

;; Test match' on pair
!(assertEqualToResult
  (match' (Cons (A B) (Cons (C D) Nil)) ($x $y) ($y $x))
  ((B A)
   (D C)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Knowledge and rule base ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Paste directly the content of rse-services.metta instead of
;; importing it to avoid shenanigan.  Names have been shortened when
;; possible to be more readable.
!(bind! &kb (new-space))

;; Do not import, instead the service definitions are pasted directly
;; further below.
;;
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

;;;;;;;;;;;;;;;;;;;;;;
;; Backward chainer ;;
;;;;;;;;;;;;;;;;;;;;;;

;; Curried Backward Chainer with lambda abstraction.  A lambda
;; abstraction is represented by
;;
;; (λ <INDEX> <BODY>)
;;
;; where <INDEX> is a De Bruijn index as define above, such as z or
;; (s z), and <BODY> is a term possibly containing <INDEX>.  Note
;; that the use of De Bruijn index in lambda abstraction is somewhat
;; unconventional here.  It differs from what is described in
;; https://en.wikipedia.org/wiki/De_Bruijn_index in three ways:
;;
;; 1. The index is explicitely attached to a λ by being its first
;;    argument.  For instance the lambda term λx.x, which would
;;    traditionally be represented by λ1 using De Bruijn index, would
;;    be represented here by the MeTTa term (λ z z).
;;
;; 2. As seen in the example above the index here starts at 0,
;;    represented by z, instead of 1.
;;
;; 3. The index increases as the lambda abstraction gets deeper.  For
;;    instance λx.λy.x, which would traditionally be represented by
;;    λλ2 using De Bruijn index, is represented here by the MeTTa term
;;    (λ z (λ (s z) z).
;;
;; This differences are due to the way the proof abstraction recursive
;; step is defined in the bc, as well as the need for having non
;; overlapping pattern matching between the two recursive steps.
;; Specifically, if λ had only one argument, then (λ <BODY>) would
;; overlap with (<ABS> <ARG>).  Having λ take 2 arguments instead of 1
;; has the disadvantage of making lambda abstraction not as compact.
;; On the flip side, the benefit is that the scope of an index is
;; easier to track.
;;
;; The arguments of the backward chainer are:
;;
;; * Knowledge base: pointer to a space containing axioms and rules in
;;   the format (: <NAME> <RULE>).  Note that rules are explicitely
;;   curried, meaning that a rule with two premises is represented by
;;
;;   (: <NAME> (-> <PREMISE1> (-> <PREMISE2> <CONCLUSION>)))
;;
;; * Environment: a list of typing relationship between De Bruijn
;;   index and type, such as
;;
;;   (Cons (: z String) (Cons (: (s z) Number) Nil))
;;
;; * De Bruijn Index: De Bruijn Index to use if a lambda abstraction
;;   is introduced.
;;
;; * Maximum depth: maximum depth of the generated proof tree.
;;
;; * Query: a metta term of the form (: <PROOF> <THEOREM>) where
;;   <PROOF> and <THEOREM> may contain free variables that may be
;;   filled by the backward chainer.  Note that for arguments of
;;   applications must be type annotated (unknowns types are of course
;;   allowed).  For instance the following query
;;
;;   (: (ModusPonens ab) $thrm)
;;
;;   would not work, instead one needs to provide
;;
;;   (: (ModusPonens (: ab $lemma)) $thrm)
;;
;; A result is the query with its variables grounded, fully or
;; partially.  If multiple results are possible, they are returned as
;; a superposition.
;;
;; As explained, the proof arguments must be type annotated.  Without
;; such type annotation, lambda abstraction sometimes leads to
;; incorrect results.  It is suspected to come from the fact that
;; otherwise the proof application recursive step loses bindings about
;; the premise.  Having annotated proof is however a good thing, to
;; display a proof tree and to have an indepth view into the proof.
;; In order to remove (resp. add) type annotation one can use
;; remove-type (resp. add-type).
(: bc (-> $a                            ; Knowledge base space
          $b                            ; Environment
          DeBruijn                      ; De Bruijn Index
          Nat                           ; Maximum depth
          $c                            ; Query
          $c))                          ; Result

;; Base cases

;; Match the knowledge base
(= (bc $kb $env $idx $_ (: $prf $thrm))
   (match $kb (: $prf $thrm) (: $prf $thrm)))
;; Match the environment
(= (bc $kb $env $idx $_ (: $prf $thrm))
   (match' $env (: $prf $thrm) (: $prf $thrm)))

;; Recursive steps

;; ;; Proof application
;; (= (bc $kb $env $idx (S $k) (: ($prfabs (: $prfarg $prms)) $thrm))
;;    (let* (((: $prfabs (-> $prms $thrm))
;;            (bc $kb $env $idx $k (: $prfabs (-> $prms $thrm))))
;;           ((: $prfarg $prms)
;;            (bc $kb $env $idx $k (: $prfarg $prms))))
;;      (: ($prfabs (: $prfarg $prms)) $thrm)))
;; ;; Proof abstraction
;; (= (bc $kb $env $idx (S $k) (: (λ $idx $prfbdy) (-> $prms $thrm)))
;;    (let (: $prfbdy $thrm)
;;      (bc $kb (Cons (: $idx $prms) $env) (s $idx) $k (: $prfbdy $thrm))
;;      (: (λ $idx $prfbdy) (-> $prms $thrm))))
;; Proof application
(= (bc $kb $env $idx (S $k) (: ($prfabs $prgarg) $thrm))
   (let* (((: $prfabs (-> $prms $thrm))
           (bc $kb $env $idx $k (: $prfabs (-> $prms $thrm))))
          ((: $prfarg $prms)
           (bc $kb $env $idx $k (: $prfarg $prms))))
     (: ($prfabs $prfarg) $thrm)))
;; Proof abstraction
(= (bc $kb $env $idx (S $k) (: (λ (: $idx $prms) $prfbdy) (-> $prms $thrm)))
   (let (: $prfbdy $thrm)
     (bc $kb (Cons (: $idx $prms) $env) (s $idx) $k (: $prfbdy $thrm))
     (: (λ (: $idx $prms) $prfbdy) (-> $prms $thrm))))

;;;;;;;;;;;;;;;;;;;;;
;; Reduction rules ;;
;;;;;;;;;;;;;;;;;;;;;

;; NEXT: add some reduction rules

;; ;; Composition to application
;; (= (((. $g) $f) $x) ($g ($f $x)))

;; ;; Right associate composition, meaning
;; ;;
;; ;; h . g . f
;; ;;
;; ;; should be represented as
;; ;;
;; ;; h . (g . f)
;; ;;
;; ;; or in MeTTa
;; ;;
;; ;; ((. h) ((. g) f))
;; ;;
;; ;; Thus anything deviating from that representation, such as
;; ;;
;; ;; (h . g) . f
;; ;;
;; ;; or in MeTTa
;; ;;
;; ;; ((. ((. h) g)) f)
;; ;;
;; ;; should be rewritten as
;; ;;
;; ;; ((. h) ((. g) f))
;; ;;
;; ;; The reason left associativity is choosen as default over right
;; ;; associativity is because in prefix notation the former is easier to
;; ;; read (to me anyway).
;; (= ((. ((. $h) $g)) $f) ((. $h) ((. $g) $f)))

;; ;; Eliminate contiguous composition of constructor and deconstructor.
;; ;; speech2text-en.Audio
;; (= ((. speech2text-en.Audio.data) ((. speech2text-en.MkAudio) $f)) $f)
;; (= ((. $f) ((. speech2text-en.Audio.data) speech2text-en.MkAudio)) $f)
;; (= ((. speech2text-en.MkAudio) ((. speech2text-en.Audio.data) $f)) $f)
;; (= ((. $f) ((. speech2text-en.MkAudio) speech2text-en.Audio.data)) $f)
;; ;; speech2text-en.Text
;; (= ((. speech2text-en.Text.text) ((. speech2text-en.MkText) $f)) $f)
;; (= ((. $f) ((. speech2text-en.Text.text) speech2text-en.MkText)) $f)
;; (= ((. speech2text-en.MkText) ((. speech2text-en.Text.text) $f)) $f)
;; (= ((. $f) ((. speech2text-en.MkText) speech2text-en.Text.text)) $f)
;; ;; text-emotions.Input
;; (= ((. text-emotions.Input.text) ((. text-emotions.MkInput) $f)) $f)
;; (= ((. $f) ((. text-emotions.Input.text) text-emotions.MkInput)) $f)
;; (= ((. text-emotions.MkInput) ((. text-emotions.Input.text) $f)) $f)
;; (= ((. $f) ((. text-emotions.MkInput) text-emotions.Input.text)) $f)
;; ;; text-emotions.Output
;; (= ((. text-emotions.Output.result) ((. text-emotions.MkOutput) $f)) $f)
;; (= ((. $f) ((. text-emotions.Output.result) text-emotions.MkOutput)) $f)
;; (= ((. text-emotions.MkOutput) ((. text-emotions.Output.result) $f)) $f)
;; (= ((. $f) ((. text-emotions.MkOutput) text-emotions.Output.result)) $f)

;;;;;;;;;;
;; Test ;;
;;;;;;;;;;

;; ;; Synthesize a program that takes speech as
;; ;; naint.speech2text-en.Audio and returns text as
;; ;; naint.speech2text-en.Text.
;; !(bc &kb Nil z (fromNumber 0) (: $prg (-> speech2text-en.Audio speech2text-en.Text)))

;; ;; Synthesize a program that takes text as naint.text-emotions.Input
;; ;; and returns emotion as naint.text-emotions.Output.
;; !(bc &kb Nil z (fromNumber 0) (: $prg (-> text-emotions.Input text-emotions.Output)))

;; ;; Synthesize a program that takes speech as Bytes and returns speech
;; ;; as naint.speech2text-en.Audio.
;; !(bc &kb Nil z (fromNumber 0) (: $prg (-> Bytes speech2text-en.Audio)))

;; ;; Synthesize a program that takes text as naint.speech2text-en.Text
;; ;; and returns text as String.
;; !(bc &kb Nil z (fromNumber 0) (: $prg (-> speech2text-en.Text String)))

;; ;; Synthesize a program that takes speech as Bytes and returns text as
;; ;; naint.speech2text-en.Text.
;; !(bc &kb Nil z (fromNumber 3) (: $prg (-> Bytes speech2text-en.Text)))

;; ;; Synthesize a program that takes speech as Bytes and returns text as
;; ;; String.
;; !(bc &kb Nil z (fromNumber 4) (: $prg (-> Bytes String)))

;; NEXT: identify stuff to reduce (or look at english to chinese lambda experiment)

;; [(: (λ (: z Bytes) (speech2text-en.Text.text (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) Type) speech2text-en.Text.text) speech2text-en.Audio) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) (-> Bytes speech2text-en.Audio)) speech2text-en.Text.text) speech2text-en.MkAudio) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) (-> speech2text-en.Audio Bytes)) speech2text-en.Text.text) speech2text-en.Audio.data) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) Type) speech2text-en.Text.text) speech2text-en.Text) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) (-> String speech2text-en.Text)) speech2text-en.Text.text) speech2text-en.MkText) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) (-> speech2text-en.Text String)) speech2text-en.Text.text) speech2text-en.Text.text) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) (-> speech2text-en.Audio speech2text-en.Text)) speech2text-en.Text.text) speech2text-en.s2t) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) Type) speech2text-en.Text.text) text-emotions.Input) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) (-> String text-emotions.Input)) speech2text-en.Text.text) text-emotions.MkInput) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) (-> text-emotions.Input String)) speech2text-en.Text.text) text-emotions.Input.text) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) Type) speech2text-en.Text.text) text-emotions.Output) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) (-> String text-emotions.Output)) speech2text-en.Text.text) text-emotions.MkOutput) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) (-> text-emotions.Output String)) speech2text-en.Text.text) text-emotions.Output.result) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) (-> text-emotions.Input text-emotions.Output)) speech2text-en.Text.text) text-emotions.recognize) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) Bytes) speech2text-en.Text.text) z) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) speech2text-en.Audio) speech2text-en.Text.text) (speech2text-en.MkAudio z)) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) (-> $255105508 Type)) speech2text-en.Text.text) (λ (: (s z) $255105508) speech2text-en.Audio)) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) (-> $255105508 (-> Bytes speech2text-en.Audio))) speech2text-en.Text.text) (λ (: (s z) $255105508) speech2text-en.MkAudio)) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) (-> $255105508 (-> speech2text-en.Audio Bytes))) speech2text-en.Text.text) (λ (: (s z) $255105508) speech2text-en.Audio.data)) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) (-> $255105508 Type)) speech2text-en.Text.text) (λ (: (s z) $255105508) speech2text-en.Text)) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) (-> $255105508 (-> String speech2text-en.Text))) speech2text-en.Text.text) (λ (: (s z) $255105508) speech2text-en.MkText)) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) (-> $255105508 (-> speech2text-en.Text String))) speech2text-en.Text.text) (λ (: (s z) $255105508) speech2text-en.Text.text)) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) (-> $255105508 (-> speech2text-en.Audio speech2text-en.Text))) speech2text-en.Text.text) (λ (: (s z) $255105508) speech2text-en.s2t)) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) (-> $255105508 Type)) speech2text-en.Text.text) (λ (: (s z) $255105508) text-emotions.Input)) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) (-> $255105508 (-> String text-emotions.Input))) speech2text-en.Text.text) (λ (: (s z) $255105508) text-emotions.MkInput)) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) (-> $255105508 (-> text-emotions.Input String))) speech2text-en.Text.text) (λ (: (s z) $255105508) text-emotions.Input.text)) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) (-> $255105508 Type)) speech2text-en.Text.text) (λ (: (s z) $255105508) text-emotions.Output)) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) (-> $255105508 (-> String text-emotions.Output))) speech2text-en.Text.text) (λ (: (s z) $255105508) text-emotions.MkOutput)) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) (-> $255105508 (-> text-emotions.Output String))) speech2text-en.Text.text) (λ (: (s z) $255105508) text-emotions.Output.result)) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) (-> $255105508 (-> text-emotions.Input text-emotions.Output))) speech2text-en.Text.text) (λ (: (s z) $255105508) text-emotions.recognize)) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) (-> $255105508 $255105508)) speech2text-en.Text.text) (λ (: (s z) $255105508) (s z))) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) (-> $255105508 Bytes)) speech2text-en.Text.text) (λ (: (s z) $255105508) z)) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) (((λ (: (s z) (-> speech2text-en.Text String)) (s z)) speech2text-en.Text.text) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))
;;  (: (λ (: z Bytes) ((λ (: (s z) speech2text-en.Text) (speech2text-en.Text.text (s z))) (speech2text-en.s2t (speech2text-en.MkAudio z)))) (-> Bytes String))]

;; ;; Synthesize a program that takes text as String and returns emotion
;; ;; as String.
;; !(bc &kb Nil z (fromNumber 4) (: $prg (-> String String)))

;; ;; Synthesize a program that takes speech as Bytes and returns text or
;; ;; emotion as String.
;; !(bc &kb Nil z (fromNumber 5) (: $prg (-> Bytes String)))

;; Synthesize a program that takes speech as
;; naint.speech2text-en.Audio and returns emotion as
;; naint.text-emotions.Output.
!(unique
  (bc &kb Nil z
      (fromNumber 5)
      (: $prg (-> speech2text-en.Audio text-emotions.Output))))

;; NEXT: identify reduction rules

;; Depth = 4
;; [(: (λ (: z speech2text-en.Audio) (text-emotions.MkOutput (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) Type) text-emotions.MkOutput) speech2text-en.Audio) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) (-> Bytes speech2text-en.Audio)) text-emotions.MkOutput) speech2text-en.MkAudio) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) (-> speech2text-en.Audio Bytes)) text-emotions.MkOutput) speech2text-en.Audio.data) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) Type) text-emotions.MkOutput) speech2text-en.Text) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) (-> String speech2text-en.Text)) text-emotions.MkOutput) speech2text-en.MkText) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) (-> speech2text-en.Text String)) text-emotions.MkOutput) speech2text-en.Text.text) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) (-> speech2text-en.Audio speech2text-en.Text)) text-emotions.MkOutput) speech2text-en.s2t) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) Type) text-emotions.MkOutput) text-emotions.Input) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) (-> String text-emotions.Input)) text-emotions.MkOutput) text-emotions.MkInput) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) (-> text-emotions.Input String)) text-emotions.MkOutput) text-emotions.Input.text) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) Type) text-emotions.MkOutput) text-emotions.Output) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) (-> String text-emotions.Output)) text-emotions.MkOutput) text-emotions.MkOutput) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) (-> text-emotions.Output String)) text-emotions.MkOutput) text-emotions.Output.result) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) (-> text-emotions.Input text-emotions.Output)) text-emotions.MkOutput) text-emotions.recognize)o (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) speech2text-en.Audio) text-emotions.MkOutput) z) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) Bytes) text-emotions.MkOutput) (speech2text-en.Audio.data z)) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) speech2text-en.Text) text-emotions.MkOutput) (speech2text-en.s2t z)) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) (-> $232385588 Type)) text-emotions.MkOutput) (λ (: (s z) $232385588) speech2text-en.Audio)) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) (-> $232385588 (-> Bytes speech2text-en.Audio))) text-emotions.MkOutput) (λ (: (s z) $232385588) speech2text-en.MkAudio)) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) (-> $232385588 (-> speech2text-en.Audio Bytes))) text-emotions.MkOutput) (λ (: (s z) $232385588) speech2text-en.Audio.data)) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) (-> $232385588 Type)) text-emotions.MkOutput) (λ (: (s z) $232385588) speech2text-en.Text)) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) (-> $232385588 (-> String speech2text-en.Text))) text-emotions.MkOutput) (λ (: (s z) $232385588) speech2text-en.MkText)) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) (-> $232385588 (-> speech2text-en.Text String))) text-emotions.MkOutput) (λ (: (s z) $232385588) speech2text-en.Text.text)) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) (-> $232385588 (-> speech2text-en.Audio speech2text-en.Text))) text-emotions.MkOutput) (λ (: (s z) $232385588) speech2text-en.s2t)) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) (-> $232385588 Type)) text-emotions.MkOutput) (λ (: (s z) $232385588) text-emotions.Input)) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) (-> $232385588 (-> String text-emotions.Input))) text-emotions.MkOutput) (λ (: (s z) $232385588) text-emotions.MkInput)) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) (-> $232385588 (-> text-emotions.Input String))) text-emotions.MkOutput) (λ (: (s z) $232385588) text-emotions.Input.text)) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) (-> $232385588 Type)) text-emotions.MkOutput) (λ (: (s z) $232385588) text-emotions.Output)) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) (-> $232385588 (-> String text-emotions.Output))) text-emotions.MkOutput) (λ (: (s z) $232385588) text-emotions.MkOutput)) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) (-> $232385588 (-> text-emotions.Output String))) text-emotions.MkOutput) (λ (: (s z) $232385588) text-emotions.Output.result)) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) (-> $232385588 (-> text-emotions.Input text-emotions.Output))) text-emotions.MkOutput) (λ (: (s z) $232385588) text-emotions.recognize)) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) (-> $232385588 $232385588)) text-emotions.MkOutput) (λ (: (s z) $232385588) (s z))) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) (-> $232385588 speech2text-en.Audio)) text-emotions.MkOutput) (λ (: (s z) $232385588) z)) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) (((λ (: (s z) (-> String text-emotions.Output)) (s z)) text-emotions.MkOutput) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))
;;  (: (λ (: z speech2text-en.Audio) ((λ (: (s z) String) (text-emotions.MkOutput (s z))) (speech2text-en.Text.text (speech2text-en.s2t z)))) (-> speech2text-en.Audio text-emotions.Output))]
