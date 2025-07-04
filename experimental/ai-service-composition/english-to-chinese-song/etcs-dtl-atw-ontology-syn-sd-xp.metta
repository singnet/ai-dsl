;;;;;;;;;;;
;; Utils ;;
;;;;;;;;;;;

;; Run the code if the condition is true, otherwise prune the branch
(: when (-> Bool $a $a))
(= (when $c $x) (if $c $x (empty)))

;; Return True iff $term is closed
(: is-closed (-> Atom Bool))
(= (is-closed $term)
   (case (get-metatype $term)
     ((Variable False)
      (Symbol True)
      (Grounded True)
      (Expression (if (== $term ())
                      True
                      (let* (($head (car-atom $term))
                             ($tail (cdr-atom $term)))
                        (and (is-closed $head) (is-closed $tail))))))))

;; Return True iff Symbol
(: is-symbol (-> Atom Bool))
(= (is-symbol $term) (== Symbol (get-metatype $term)))

;; Return True iff Grounded
(: is-grounded (-> Atom Bool))
(= (is-grounded $term) (== Grounded (get-metatype $term)))

;; Return True iff Variable
(: is-variable (-> Atom Bool))
(= (is-variable $term) (== Variable (get-metatype $term)))

;; Return True iff Expression
(: is-expression (-> Atom Bool))
(= (is-expression $term) (== Expression (get-metatype $term)))

;; Return True iff the term is an arrow type
(: is-arrow-type (-> Atom Bool))
(= (is-arrow-type $term) (case (get-metatype $term)
                           ((Symbol False)
                            (Grounded False)
                            (Variable False)
                            (Expression (if-decons-expr $term
                                                        $head
                                                        $tail
                                                        (== $head ->)
                                                        False)))))

;; Test is-arrow-type
!(assertEqual
  (is-arrow-type A)
  False)
!(assertEqual
  (is-arrow-type (A B))
  False)
!(assertEqual
  (is-arrow-type (-> A B))
  True)

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

;;;;;;;;;;
;; List ;;
;;;;;;;;;;

;; Declaration of List data type and constructors
(: List (-> $a Type))
(: Nil (List $a))
(: Cons (-> $a (List $a) (List $a)))

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

!(bind! &kb (new-space))

;;;;;;;;;;;;;;;
;; Subtyping ;;
;;;;;;;;;;;;;;;

;; Notations:
;;
;; 1. Variables in upper case, like `$T`, tend to correspond to types.
;; 2. Variables in lower case, like `$t`, tend to correspond to terms.
;; 3. In the rule names:
;; 3.1. ST stands for SubTyping,
;; 3.2. Refl for Reflexive,
;; 3.3. Trans for transitive,
;; 3.4. Cov for contravariant.

;; ;; Subtyping is relexive
;; !(add-atom &kb (: STRefl (<: $T $T)))

;; ;; Subtyping is transitive
;; !(add-atom &kb (: STTrans (-> (: $prf1 (<: $S $T))
;;                               (-> (: $prf2 (<: $T $U))
;;                                   (<: $S $U)))))

;; ;; Subtyping of function types is contravariant over inputs and
;; ;; covariant over outputs.
;; !(add-atom &kb (: STConv (-> (: $prf1 (<: $T1 $S1))
;;                              (-> (: $prf2 (<: $S2 $T2))
;;                                  (<: (-> $S1 $S2) (-> $T1 $T2))))))

;; ;; Relationship between subtyping and type assume explicit coercion.
;; ;; That is if a term `t` is of type `S` a subtype of `T`, then
;; ;; `(coerce proof_S<:T t)` is of type `T`, where `proof_S<:T` is a
;; ;; proof that `S` is a subtype of `T`.
;; !(add-atom &kb (: coerce (-> (: $prf (<: $S $T))
;;                              (-> (: $s $S)
;;                                  $T))))

;;;;;;;;;;;;;;
;; Ontology ;;
;;;;;;;;;;;;;;

;; ;; The ontology tries to be based on existing ontologies when
;; ;; possible.  See the following discussion for a list of ontologies
;; ;;
;; ;; https://github.com/singnet/ai-dsl/discussions/18

;; ;; Language
;; !(add-atom &kb (: NS (<: NaturalLanguage String)))             ; SUMO

;; ;; Text
;; !(add-atom &kb (: TS (<: Text String)))
;; !(add-atom &kb (: TIT (<: (TextIn $l) Text)))

;; ;; URL
;; !(add-atom &kb (: US (<: UniformResourceLocator String)))      ; SUMO
;; !(add-atom &kb (: UTU (<: (UniformResourceLocatorOfType $t) UniformResourceLocator)))

;; ;; MIDI
;; !(add-atom &kb (: MB (<: MusicalInstrumentDigitalInterface Bytes)))

;; ;; Audio
;; !(add-atom &kb (: AB (<: Audio Bytes)))
;; !(add-atom &kb (: IA (<: Instrumental Audio)))
;; !(add-atom &kb (: VA (<: Vocals Audio)))
;; !(add-atom &kb (: VIV (<: (VocalsIn $l) Vocals)))
;; !(add-atom &kb (: SIA (<: (SongIn $l) Audio)))

;; The following is partly obtained from crawling the actual
;; SingularityNET market place, partly made up to simplify the
;; composition.

;; TODO: for now we paste the content of
;; english-song-to-chinese-song-services.metta here because the import
;; operation imports the stdlib as well and let stdlib functions being
;; used as rules and axioms by the backward chainer.
;;
;; Also, for the sake of simplicity the names have been shorten by
;; removing the organization.  For instance
;;
;; naint.machine-translation.Input
;;
;; becomes
;;
;; machine-translation.Input

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Services involved in creating a composite service to turn English
;; singing into Chinese singing.
;;
;; The service specifications are obtained from the output of
;;
;; ./gen-snet-marketplace-metta.sh naint.machine-translation naint.midi2voice-zh snet.sound-spleeter snet.speech-recognition
;;
;; then curated to retain only the information about the type
;; signatures of service calls.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MeTTa representation, generated by protobuf-metta
;;
;; Protobuf file: sound_spleeter.proto
;; Protobuf syntax: proto3
;; Prefix: snet.sound-spleeter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;
;; Message Types ;;
;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;
;; Output ;;
;;;;;;;;;;;;

;; ;; Define sound-spleeter.Output constuctor
;; !(add-atom &kb (: sound-spleeter.MkOutput
;;                   (-> (: $voc Vocals)
;;                       (-> (: $inst Instrumental)
;;                           sound-spleeter.Output))))

;; ;; Define sound-spleeter.Output access functions

;; ;; Define sound-spleeter.Output.vocals
;; !(add-atom &kb (: sound-spleeter.Output.vocals
;;                   (-> (: $out sound-spleeter.Output)
;;                       Vocals)))

;; ;; Define sound-spleeter.Output.accomp
;; !(add-atom &kb (: sound-spleeter.Output.accomp
;;                   (-> (: $out sound-spleeter.Output)
;;                       Instrumental)))

;; DTL version of Output

;; ;; Define sound-spleeter.DTLOutput constuctor
;; !(add-atom &kb (: sound-spleeter.MkDTLOutput
;;                   (-> (: $l NaturalLanguage)
;;                       (-> (: $voc (VocalsIn $l))
;;                           (-> (: $inst Instrumental)
;;                               (sound-spleeter.DTLOutput $l))))))

;; Define sound-spleeter.DTLOutput access functions

;; Define sound-spleeter.DTLOutput.vocals
!(add-atom &kb (: sound-spleeter.DTLOutput.vocals
                  (-> (: $out (sound-spleeter.DTLOutput $l))
                      (VocalsIn $l))))

;; Define sound-spleeter.DTLOutput.accomp
!(add-atom &kb (: sound-spleeter.DTLOutput.accomp
                  (-> (: $out (sound-spleeter.DTLOutput $l))
                      Instrumental)))

;;;;;;;;;;;;;;
;; Services ;;
;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;
;; SoundSpleeter ;;
;;;;;;;;;;;;;;;;;;;

;; ;; Define sound-spleeter.spleeter service method
;; !(add-atom &kb (: sound-spleeter.spleeter
;;                   (-> (: $audio Audio)
;;                       ;; We reuse the spleeter Output type to hold
;;                       ;; a pair of Audio
;;                       sound-spleeter.Output)))

;; Define DTL version of sound-spleeter.spleeter
!(add-atom &kb (: sound-spleeter.spleeter
                  (-> (: $song (SongIn $l))
                      ;; We reuse the spleeter Output type to hold
                      ;; a pair of Audio
                      (sound-spleeter.DTLOutput $l))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; English vocals to Chinese vocals ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; This made-up service, takes vocals in English and directly
;; translate then into Chinsese, preserving melody and tempo.

;; Method
!(add-atom &kb (: vocals-translator.translate
                  (-> (: $en-vocals (VocalsIn "English"))
                      (VocalsIn "Chinese"))))

;;;;;;;;;;;
;; Mixer ;;
;;;;;;;;;;;

;; ;; Method
;; !(add-atom &kb (: mixer.mix (-> (: $audio1 Audio)
;;                                 (-> (: $audio2 Audio)
;;                                     Audio))))

;; DTL version
!(add-atom &kb (: mixer.mix (-> (: $inst Instrumental)
                                (-> (: $voc (VocalsIn $l))
                                    (SongIn $l)))))

;; Acrobatic attempt to specify a property about mixing without
;; overloading the type signature of the mixer
;;
;; (: $mixer Mixer) -> ($mixer (c1 $x) (c2 $y)) and (: $x (VocalsIn $l)) (: $y Instrumental) -> $z === mix ...) -> (: $z (SongIn $l))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Other type definitions ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;; English language string
;; !(add-atom &kb (: "English" NaturalLanguage))

;; ;; Chinese language string
;; !(add-atom &kb (: "Chinese" NaturalLanguage))

;;;;;;;;;;;;;;;;;;;;;;
;; Backward chainer ;;
;;;;;;;;;;;;;;;;;;;;;;

;; The following code is copied from NEXT.

;; Curried Backward Chainer with lambda abstraction and dependent
;; types.  A lambda abstraction is represented by
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
;;   In addition, each premise must be an inline typing relationship,
;;   to represent dependent types.  It should be noted that such
;;   typing relationship must be provided even if the witness is not
;;   present in the rest of the definition.  For instance <PREMISE1>
;;   would have the format
;;
;;   (: <TERM1> <TYPE1>)
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
;; remove-type-annotation (resp. add-type-annotation).
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

;; Proof application
(= (bc $kb $env $idx (S $k) (: ($prfabs $prfarg) $thrm))
   (let* (((: $prfabs (-> (: $prfarg $prms) $thrm))
           (bc $kb $env $idx $k (: $prfabs (-> (: $prfarg $prms) $thrm))))
          ((: $prfarg $prms)
           (bc $kb $env $idx $k (: $prfarg $prms))))
     (: ($prfabs $prfarg) $thrm)))
;; Proof abstraction
(= (bc $kb $env $idx (S $k) (: (λ (: $idx $prms) $prfbdy) (-> (: $prfarg $prms) $thrm)))
   (let (: $prfbdy $thrm)
     (bc $kb (Cons (: $idx $prms) $env) (s $idx) $k (: $prfbdy $thrm))
     (when (not (is-arrow-type $prms))
       (: (λ (: $idx $prms) $prfbdy) (-> (: $prfarg $prms) $thrm)))))

;;;;;;;;;;;;;;;
;; Reduction ;;
;;;;;;;;;;;;;;;

;; Reduction rules to simplify proofs and reduce redundancy

;; TODO: these rules should be proven first.  Then they could
;; automatically be inserted.

;; ;; Involution of symmetry
;; (= (Sym (Sym $f)) $f)

;; Identity function
(= ((λ $x $x) $y) $y)

;; Constant function
(= ((λ (s z) z) $x) z)

;; ;; Application function.  This is incorrect because $x is supposed not
;; ;; to contain (s z) and we have no way to guaranty that via pattern
;; ;; matching.  This incorrectness is probably tolerable because such
;; ;; situation may not arise here.
;; (= ((λ (s z) ((s z) $x)) $y) ($y $x))

;; ;; Lambda application
;; (= ((λ $x $y) $z) (let $x $z $y))

;;;;;;;;;;;;;;;;;;;;;
;; Remove/add type ;;
;;;;;;;;;;;;;;;;;;;;;

;; Remove type annotations from a query.
;;
;; For instance
;;
;; (remove-type-annotation (: ((ModusPonens (: ab (→ A B))) (: a A)) B))
;;
;; outputs
;;
;; ((ModusPonens ab) a)
;; (: remove-type-annotation (-> $a $a))
(= (remove-type-annotation $term)
   (case (get-metatype $term)
     ((Symbol $term)
      (Grounded $term)
      (Variable $term)
      (Expression (case $term
                    ;; Only covers up to trinary expression because
                    ;; for now the bc is not supposed to generate
                    ;; n-ary expression where n is greater 3.
                    ((() ())
                     (($x) ((remove-type-annotation $x)))
                     (($x $y) ((remove-type-annotation $x) (remove-type-annotation $y)))
                     (($x $y $z) (if (== $x :)
                                     (remove-type-annotation $y)
                                     ((remove-type-annotation $x)
                                      (remove-type-annotation $y)
                                      (remove-type-annotation $z))))
                     ($_ $_)))))))

;; Add type missing annotation to be compatible with bc query format.
;; Whatever is missing is only added as variables, not inferred, for
;; that one may use the bc.  Note that the first annotation must be
;; provided manually
;;
;; For instance
;;
;; (add-type-annotation ((ModusPonens ab) a))
;;
;; only outputs
;;
;; ((ModusPonens (: ab $t#1)) (: a $t#2))
;;
;; not
;;
;; (: ((ModusPonens (: ab $t#1)) (: a $t#2)) $t#3)
;;
;; That is because add-type-annotation can only detect application, that is a
;; term of the form (<ABS> <ARG>) to add the type annotation to <ARG>.
;;
;; NEXT: must keep track of the existing type to remain consistant.
(: add-type-annotation (-> $a $a))
(= (add-type-annotation $term)
   (case (get-metatype $term)
     ((Symbol $term)
      (Grounded $term)
      (Variable $term)
      (Expression (case $term
                    ((() ())
                     (($x) ($x))
                     (($x $y) (if (== $x s)
                                  ;; Treat De Bruijn index atomically
                                  $term
                                  ;; Add type annotation to argument of application
                                  (let $νx (add-type-annotation $x) ($νx (: (add-type-annotation $y) $t)))))
                     (($x $y $z) (if (== $x :)
                                     ;; Already a type annotation, recurse only on $y
                                     (: (add-type-annotation $y) $z)
                                     (if (== $x λ)
                                         ;; Recurse only on body of lambda abstraction
                                         (λ $y (add-type-annotation $z))
                                         $term)))
                     ($_ $_)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;
;; MeTTa to λ-calculus ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;; The following code is borrowed from calculi-converter.metta in the
;; chaining repository.

;; Convert metta to lambda calculus with De Bruijn indices.  It takes
;; in arguments
;;
;; 1. De Bruijn index to use for the next abstraction
;;
;; 2. MeTTa term.  Built-in operators such as let must be previously
;;    converted into LET to avoid spontaneous reduction.  NEXT: maybe
;;    we actually don't.
(: mt2lc (-> DeBruijn Atom Atom))
(= (mt2lc $idx $term)
   (case (get-metatype $term)
     ((Symbol $term)
      (Grounded $term)
      (Variable $term)
      (Expression (case $term
                    (;; Empty
                     (() ())
                     ;; LET
                     ((LET $x $y $f) (let* (($x $idx)
                                            ($νf (mt2lc (s $idx) $f))
                                            ($νy (mt2lc $idx $y)))
                                       ((λ $x $νf) $νy)))
                     ;; Application
                     (($f $x) ((mt2lc $idx $f) (mt2lc $idx $x)))
                     ;; Other
                     ($term $term)))))))

;;;;;;;;;;
;; Test ;;
;;;;;;;;;;

;; The following MeTTa program represents the AI service composition
;; for the English to Chinese song translation using the made-up
;; vocals-translator service.
;;
;; (= (english-song-to-chinese-song $input)
;;    (let $spleeter-output (sound-spleeter.spleeter $input)
;;      ((mixer.mix
;;        (sound-spleeter.DTLOutput.accomp $spleeter-output))
;;       (vocals-translator.translate (sound-spleeter.DTLOutput.vocals $spleeter-output)))))

;; The following lambda term has been obtained by converting MeTTa to
;; lambda-calculus as follow
;;
;; !(mt2lc (s z)
;;         (LET $spleeter-output (sound-spleeter.spleeter $input)
;;           ((mixer.mix
;;             (sound-spleeter.DTLOutput.accomp $spleeter-output))
;;            (vocals-translator.translate (sound-spleeter.DTLOutput.vocals $spleeter-output)))))
;;
;; ((λ (s z)
;;    ((mixer.mix
;;      (sound-spleeter.DTLOutput.accomp (s z)))
;;     (vocals-translator.translate (sound-spleeter.DTLOutput.vocals (s z)))))
;;  (sound-spleeter.spleeter $input))
;;
;; and wrapping $input into a lambda abstraction using z as its
;; corresponding De Bruijn index, which gives us
;;
;; (λ z
;;   ((λ (s z)
;;      ((mixer.mix
;;        (sound-spleeter.DTLOutput.accomp (s z)))
;;       (vocals-translator.translate (sound-spleeter.DTLOutput.vocals (s z)))))
;;    (sound-spleeter.spleeter z)))

;; The we add type annotations, as it required by the backward
;; chainer, by calling add-type-annotation as follows
;;
;; !(add-type-annotation
;;   (λ z
;;     ((λ (s z)
;;        ((mixer.mix
;;          (sound-spleeter.DTLOutput.accomp (s z)))
;;         (vocals-translator.translate (sound-spleeter.DTLOutput.vocals (s z)))))
;;      (sound-spleeter.spleeter z))))
;;
;; which gives us
;;
;; (λ z
;;   ((λ (s z)
;;      ((mixer.mix
;;        (: (sound-spleeter.DTLOutput.accomp (: (s z) $a)) $b))
;;       (: (vocals-translator.translate (: (sound-spleeter.DTLOutput.vocals (: (s z) $c)) $d)) $e)))
;;    (: (sound-spleeter.spleeter (: z $f)) $g)))
;;
;; Note: after a subsequent revision of this experiment, type
;; annotation is only placed on the lambda variables.

;; ;; ;; Synthesize part of the English to Chinese singing AI service
;; ;; ;; composition, given the totally of its template with two holes,
;; ;; ;;
;; ;; ;; 1. $accomp
;; ;; ;; 2. $vocals
;; ;; ;; !(assertEqual
;;   !(bc &kb Nil z (fromNumber 6)
;;       (: (λ (: z $t1)
;;            ((λ (: (s z) $t2)
;;               ((mixer.mix $accomp) $vocals))
;;             (sound-spleeter.spleeter $input)))
;;          (-> (: $s (SongIn "English")) (SongIn "Chinese"))))
;; ;; (: (λ (: z (SongIn "English"))
;; ;;      ((λ (: (s z) (sound-spleeter.DTLOutput "English"))
;; ;;         ((mixer.mix (sound-spleeter.DTLOutput.accomp (s z)))
;; ;;          (vocals-translator.translate (sound-spleeter.DTLOutput.vocals (s z)))))
;; ;;       (sound-spleeter.spleeter z)))
;; ;;    (-> (: $s (SongIn "English")) (SongIn "Chinese"))))

;; ;; ;; Synthesize part of the English to Chinese singing AI service
;; ;; ;; composition, given the totally of its template with three holes,
;; ;; ;;
;; ;; ;; 1. $accomp
;; ;; ;; 2. $vocals
;; ;; ;; 3. $spleeter
;; ;; ;; !(assertEqual
;;   !(bc &kb Nil z (fromNumber 6)
;;        (: (λ (: z $t1) ((λ (: (s z) $t2) ((mixer.mix $accomp) $vocals)) $spleeter))
;;           (-> (: $s (SongIn "English")) (SongIn "Chinese"))))
;; ;; (: (λ (: z (SongIn "English"))
;; ;;      ((λ (: (s z) (sound-spleeter.DTLOutput "English"))
;; ;;         ((mixer.mix (sound-spleeter.DTLOutput.accomp (s z)))
;; ;;          (vocals-translator.translate (sound-spleeter.DTLOutput.vocals (s z)))))
;; ;;       (sound-spleeter.spleeter z)))
;; ;;    (-> (: $s (SongIn "English")) (SongIn "Chinese"))))

;; ;; Synthesize part of the English to Chinese singing AI service
;; ;; composition, given the totally of its template with four holes,
;; ;;
;; ;; 1. $accomp
;; ;; 2. $vocals
;; ;; 3. $spleeter
;; ;; 4. $mix
;; ;; !(assertEqual
;;   !(bc &kb Nil z (fromNumber 6)
;;        (: (λ (: z $t1) ((λ (: (s z) $t2) (($mix $accomp) $vocals)) $spleeter))
;;           (-> (: $s (SongIn "English")) (SongIn "Chinese"))))
;; ;; (: (λ (: z (SongIn "English"))
;; ;;      ((λ (: (s z) (sound-spleeter.DTLOutput "English"))
;; ;;         ((mixer.mix (sound-spleeter.DTLOutput.accomp (s z)))
;; ;;          (vocals-translator.translate (sound-spleeter.DTLOutput.vocals (s z)))))
;; ;;       (sound-spleeter.spleeter z)))
;; ;;    (-> (: $s (SongIn "English")) (SongIn "Chinese"))))

;; ;; Synthesize part of the English to Chinese singing AI service
;; ;; composition, given the totally of its template with two holes,
;; ;;
;; ;; 1. $mav
;; ;; 2. $spleeter
;; ;; !(assertEqual
;;   !(bc &kb Nil z (fromNumber 6)
;;        (: (λ (: z $t1) ((λ (: (s z) $t2) $mav) $spleeter))
;;           (-> (: $s (SongIn "English")) (SongIn "Chinese"))))
;; ;; ;; (: (λ (: z (SongIn "English"))
;; ;; ;;      ((λ (: (s z) (sound-spleeter.DTLOutput "English"))
;; ;; ;;         ((mixer.mix (sound-spleeter.DTLOutput.accomp (s z)))
;; ;; ;;          (vocals-translator.translate (sound-spleeter.DTLOutput.vocals (s z)))))
;; ;; ;;       (sound-spleeter.spleeter z)))
;; ;; ;;    (-> (: $s (SongIn "English")) (SongIn "Chinese"))))

;; ;; Synthesize part of the English to Chinese singing AI service
;; ;; composition, given the totally of its template with one hole,
;; ;;
;; ;; 1. $body, ideally replacing
;; ;;
;; ;;      ((λ (s z)
;; ;;         ((mixer.mix
;; ;;           (: (sound-spleeter.DTLOutput.accomp (: (s z) (sound-spleeter.DTLOutput "English"))) Instrumental))
;; ;;          (: (vocals-translator.translate (: (sound-spleeter.DTLOutput.vocals (: (s z) (sound-spleeter.DTLOutput "English"))) (VocalsIn "English"))) (VocalsIn "Chinese"))))
;; ;;       (: (sound-spleeter.spleeter (: z (SongIn "English"))) (sound-spleeter.DTLOutput "English")))
;; ;;
;; ;; !(assertEqual
;;   !(bc &kb Nil z (fromNumber 6)
;;        (: (λ (: z $t) $bdy)
;;           (-> (: $s (SongIn "English")) (SongIn "Chinese"))))
;; ;; ;; ;; (: (λ (: z (SongIn "English"))
;; ;; ;; ;;      ((λ (: (s z) (sound-spleeter.DTLOutput "English"))
;; ;; ;; ;;         ((mixer.mix (sound-spleeter.DTLOutput.accomp (s z)))
;; ;; ;; ;;          (vocals-translator.translate (sound-spleeter.DTLOutput.vocals (s z)))))
;; ;; ;; ;;       (sound-spleeter.spleeter z)))
;; ;; ;; ;;    (-> (: $s (SongIn "English")) (SongIn "Chinese"))))

;; Synthesize part of the English to Chinese singing AI service
;; composition from scratch.
;;
;; !(assertEqual
  !(bc &kb Nil z (fromNumber 6) (: $prg (-> (: $s (SongIn "English")) (SongIn "Chinese"))))
;; ;; ;; ;; (: (λ (: z (SongIn "English"))
;; ;; ;; ;;      ((λ (: (s z) (sound-spleeter.DTLOutput "English"))
;; ;; ;; ;;         ((mixer.mix (sound-spleeter.DTLOutput.accomp (s z)))
;; ;; ;; ;;          (vocals-translator.translate (sound-spleeter.DTLOutput.vocals (s z)))))
;; ;; ;; ;;       (sound-spleeter.spleeter z)))
;; ;; ;; ;;    (-> (: $s (SongIn "English")) (SongIn "Chinese"))))
