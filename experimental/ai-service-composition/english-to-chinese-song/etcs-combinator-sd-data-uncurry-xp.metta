;; Like etcs-combinator-sd-data-xp.metta but the backward chainer is
;; uncurried and directly contains the constraint that function
;; domains and codomains much be concrete data types.  Another way to
;; put it is that combinators are limited to first order functions
;; only, in their applications.
;;
;; Combinators are obtained from the Data.Aviary.Birds Haskell package
;; https://hackage.haskell.org/package/data-aviary-0.4.0/docs/Data-Aviary-Birds.html

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

;;;;;;;;;;;;;;;;;;;;
;; Util functions ;;
;;;;;;;;;;;;;;;;;;;;

;; Return True iff $term is closed
;; TODO: generalize for n-ary expression
(: is-closed (-> Atom Bool))
(= (is-closed $term)
   (case (, $term (get-metatype $term))
     (((, $_ Variable) False)
      ((, ($abs $arg) Expression) (and (is-closed $abs) (is-closed $arg)))
      ($otherwise True))))

;;;;;;;;;;;;;;;;;;;;;;
;; Backward chainer ;;
;;;;;;;;;;;;;;;;;;;;;;

;; Curried Backward Chainer with dependent types (no lambda
;; abstraction here, combinatory logic is used instead).
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
;; * Maximum depth: maximum depth of the generated proof tree.
;;
;; * Query: a metta term of the form (: <PROOF> <THEOREM>) where
;;   <PROOF> and <THEOREM> may contain free variables that may be
;;   filled by the backward chainer.
;;
;; A result is the query with its variables grounded, fully or
;; partially.  If multiple results are possible, they are returned as
;; a superposition.
(: bc (-> $a                            ; Knowledge base space
          Nat                           ; Maximum depth
          $b                            ; Query
          $b))                          ; Result

;; Base cases: match the knowledge base
(= (bc $kb $_ (: $prf $thrm))
   (match $kb (: $prf $thrm) (: $prf $thrm)))

;; Recursive step: bluebird
(= (bc $kb (S $k) (: (. $f $g) (-> (: $x $a) $c)))
   (let* (;; Recurse on f
          ((: $f (-> (: $y $b) $c)) (bc $kb $k (: $f (-> (: $y $b) $c))))
          ;; Recurse on g
          ((: $g (-> (: $x $a) $b)) (bc $kb $k (: $g (-> (: $x $a) $b))))
          ;; Prove that $a, $b and $c are concrete data types
          ;; (allocate only 0 depth, should be enough)
          ((: $aData (<: $a Data)) (bc $kb Z (: $aData (<: $a Data))))
          ((: $bData (<: $b Data)) (bc $kb Z (: $bData (<: $b Data))))
          ((: $cData (<: $c Data)) (bc $kb Z (: $cData (<: $c Data)))))
     ;; Make sure $a, $b and $c are concrete data types
     (if (and (is-closed $aData) (and (is-closed $bData) (is-closed $cData)))
         (: (. $f $g) (-> (: $x $a) $c))
         (empty))))

;; Recursive step: phoenix
(= (bc $kb (S $k) (: (Φ $f $g $h) (-> (: $x $a) $d)))
   (let* (;; Recurse on f
          ((: $f (-> (: $y $b) (: $z $c) $d))
           (bc $kb $k (: $f (-> (: $y $b) (: $z $c) $d))))
          ;; Recurse on g
          ((: $g (-> (: $x $a) $b)) (bc $kb $k (: $g (-> (: $x $a) $b))))
          ;; Recurse on h
          ((: $h (-> (: $x $a) $c)) (bc $kb $k (: $h (-> (: $x $a) $c))))
          ;; Prove that $a, $b, $c and $d are concrete data types
          ;; (allocate only 0 depth, should be enough)
          ((: $aData (<: $a Data)) (bc $kb Z (: $aData (<: $a Data))))
          ((: $bData (<: $b Data)) (bc $kb Z (: $bData (<: $b Data))))
          ((: $cData (<: $c Data)) (bc $kb Z (: $cData (<: $c Data))))
          ((: $dData (<: $d Data)) (bc $kb Z (: $dData (<: $d Data)))))
     ;; Make sure $a, $b and $c are concrete data types
     (if (and (is-closed $aData)
              (and (is-closed $bData) (and (is-closed $cData)
                                           (is-closed $dData))))
         (: (Φ $f $g $h) (-> (: $x $a) $d))
         (empty))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Knowledge and rule base ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!(bind! &kb (new-space))

;;;;;;;;;;;;;;
;; Ontology ;;
;;;;;;;;;;;;;;

;; The ontology is simply composed of an upper type Data which all
;; other data types are subtype of.
!(add-atom &kb (: SOD (<: (sound-spleeter.DTLOutput $l) Data)))
!(add-atom &kb (: VID (<: (VocalsIn $l) Data)))
!(add-atom &kb (: IND (<: Instrumental Data)))
!(add-atom &kb (: SID (<: (SongIn $l) Data)))

;;;;;;;;;;;;;;
;; Services ;;
;;;;;;;;;;;;;;

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
;; sound-spleeter.DTLOutput.vocals
;;
;; becomes
;;
;; vocals
;;
;; Finally constructors and destructors are avoided when possible.

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

;; Define sound-spleeter.DTLOutput access functions

;; Define sound-spleeter.DTLOutput.vocals
!(add-atom &kb (: vocals
                  (-> (: $out (sound-spleeter.DTLOutput $l))
                      (VocalsIn $l))))

;; Define sound-spleeter.DTLOutput.accomp
!(add-atom &kb (: accomp
                  (-> (: $out (sound-spleeter.DTLOutput $l))
                      Instrumental)))

;;;;;;;;;;;;;;
;; Services ;;
;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;
;; SoundSpleeter ;;
;;;;;;;;;;;;;;;;;;;

;; Define DTL version of sound-spleeter.spleeter
!(add-atom &kb (: spleeter
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
!(add-atom &kb (: translate
                  (-> (: $en-vocals (VocalsIn "English"))
                      (VocalsIn "Chinese"))))

;;;;;;;;;;;
;; Mixer ;;
;;;;;;;;;;;

;; DTL version
!(add-atom &kb (: mix
                  (-> (: $inst Instrumental)
                      (: $voc (VocalsIn $l))
                      (SongIn $l))))

;;;;;;;;;;;;;;;;;
;; Combinators ;;
;;;;;;;;;;;;;;;;;

;; Combinators have been moved to the backward chainer

;; ;; Name: Bluebird
;; ;; Description: Sequential composition
;; ;; Type: (b -> c) -> (a -> b) -> a -> c
;; ;; Definition: bluebird f g x = f (g x)
;; ;; Symbol: .
;; ;; Diagram:
;; ;; -a-b-c->
;; !(add-atom &kb (: .
;;                   (-> (: $aD (<: $a Data))
;;                       (-> (: $bD (<: $b Data))
;;                           (-> (: $cD (<: $c Data))
;;                               (-> (: $f (-> (: $y $b) $c))
;;                                   (-> (: $g (-> (: $x $a) $b))
;;                                       (-> (: $x $a) $c))))))))

;; ;; Name: Phoenix
;; ;; Description: Split then join
;; ;; Type: (b -> c -> d) -> (a -> b) -> (a -> c) -> a -> d
;; ;; Definition: phoenix f g h x = f (g x) (h x)
;; ;; Symbol: Φ (LaTeX: \Phi, Math Emacs: \upPhi)
;; ;; Diagram:
;; ;;    b
;; ;;   / \
;; ;; -a   d->
;; ;;   \ /
;; ;;    c
;; !(add-atom &kb (: Φ
;;                   (-> (: $aD (<: $a Data))
;;                       (-> (: $bD (<: $b Data))
;;                           (-> (: $cD (<: $c Data))
;;                               (-> (: $dD (<: $c Data))
;;                                   (-> (: $f (-> (: $y $b) (-> (: $z $c) $d)))
;;                                       (-> (: $g (-> (: $x $a) $b))
;;                                           (-> (: $h (-> (: $x $a) $c))
;;                                               (-> (: $x $a) $d))))))))))

;;;;;;;;;;;;;;;;;;;;;
;; Reduction rules ;;
;;;;;;;;;;;;;;;;;;;;;

;; NEXT: re-enable reduction rules (see etcs-combinator-sd-data-xp.metta)

;;;;;;;;;;
;; Test ;;
;;;;;;;;;;

;; The following MeTTa program represents the AI service composition
;; for the English to Chinese song translation using the made-up
;; vocals-translator service.
;;
;; (= (english-song-to-chinese-song $input)
;;    (let $spleeter-output (spleeter $input)
;;      ((mix (accomp $spleeter-output))
;;       (translate (vocals $spleeter-output)))))
;;
;; It should be equivalent to the following combinatory logic program
;;
;; (. (Φ mix accomp (. translate vocals)) spleeter)

;; ;; Find all subtypes of Data
;; ;; TODO: re-enable once alpha equivalence is supported
;; !(assertEqualToResult
;;   (bc &kb (fromNumber 0) (: $prf (<: $s Data)))
;;   ((: IND (<: Instrumental Data))
;;    (: SID (<: (SongIn $l) Data))
;;    (: VID (<: (VocalsIn $l) Data))
;;    (: SOD (<: (sound-spleeter.DTLOutput $l) Data))))

;; Infer the type of (. translate vocals)
!(assertEqual
  (bc &kb (fromNumber 1) (: (. translate vocals) (-> (: $x $a) $b)))
  (: (. translate vocals) (-> (: $x (sound-spleeter.DTLOutput "English"))
                              (VocalsIn "Chinese"))))

;; Synthesize (. translate vocals)
!(assertEqual
  (bc &kb (fromNumber 1) (: $prg (-> (: $x (sound-spleeter.DTLOutput "English"))
                                     (VocalsIn "Chinese"))))
  (: (. translate vocals)
     (-> (: $x (sound-spleeter.DTLOutput "English")) (VocalsIn "Chinese"))))

;; Infer type of (Φ mix accomp (. translate vocals))
!(assertEqual
  (bc &kb
      (fromNumber 2)
      (: (Φ mix accomp (. translate vocals)) (-> (: $x $a) $b)))
  (: (Φ mix accomp (. translate vocals))
     (-> (: $x (sound-spleeter.DTLOutput "English")) (SongIn "Chinese"))))

;; Type check (. (Φ mix accomp (. translate vocals)) spleeter)
!(assertEqual
  (bc &kb
      (fromNumber 3)
      (: (. (Φ mix accomp (. translate vocals)) spleeter)
         (-> (: $x (SongIn "English")) (SongIn "Chinese"))))
  (: (. (Φ mix accomp (. translate vocals)) spleeter)
     (-> (: $x (SongIn "English")) (SongIn "Chinese"))))

;; NEXT: try depth of 4 or so to test the Data idea

;; Synthesize full AI service composition
!(bc &kb
     (fromNumber 3)
     (: $prg (-> (: $x (SongIn "English")) (SongIn "Chinese"))))
