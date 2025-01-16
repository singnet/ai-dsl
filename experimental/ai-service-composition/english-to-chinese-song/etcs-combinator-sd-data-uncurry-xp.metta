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

;; Uncurry ((. f) g) to (. f g)
(: bluebird-uncurry (-> Atom (Maybe Atom)))
(= (bluebird-uncurry $term)
   (case $term
     (((($bluebird $f) $g) (if (== $bluebird .)
                               (Just (. $f $g))
                               Nothing))
      ($else Nothing))))

;; Test bluebird-uncurry
!(assertEqual
  (bluebird-uncurry ((. $f) $g))
  (Just (. $f $g)))
!(assertEqual
  (bluebird-uncurry (((Φ $f) $g) $h))
  Nothing)

;; Uncurry (((Φ f) g) h) to (Φ f g h)
(: phoenix-uncurry (-> Atom (Maybe Atom)))
(= (phoenix-uncurry $term)
   (case $term
     ((((($phoenix $f) $g) $h) (if (== $phoenix Φ)
                                   (Just (Φ $f $g $h))
                                   Nothing))
      ($_ Nothing))))

;; Test bluebird-uncurry
!(assertEqual
  (phoenix-uncurry ((. $f) $g))
  Nothing)
!(assertEqual
  (phoenix-uncurry (((Φ $f) $g) $h))
  (Just (Φ $f $g $h)))

;; Uncurry term, so for instance
;;
;; ((. $f) $g)
;;
;; becomes
;;
;; (. $f $g)
;;
;; Take into account the arity of the operators involved.  For
;; instance
;;
;; (((. $f) $g) $x)
;;
;; becomes
;;
;; ((. $f $g) $x)
;;
;; instead of
;;
;; (. $f $g $x)
;;
;; because . is binary, not trinary.
(: uncurry (-> Atom Atom))
(= (uncurry $term)
   (case (get-metatype $term)
     ((Variable $term)
      (Symbol $term)
      (Grounded $term)
      (Expression
       (if (== $term ())
           ()
           ;; Recursive steps
           (case $term
             ((($f $g) (let* (($νf (uncurry $f))
                              ($νg (uncurry $g)))
                         (if (and (== $νf $f) (== $νg $g))
                             ;; $f and $g are uncurried, try to match
                             ;; them to known uncurring rules
                             (case (bluebird-uncurry $term)
                               (((Just $r) $r)
                                (Nothing
                                 (case (phoenix-uncurry $term)
                                   (((Just $r) $r)
                                    ;; No uncirrying rules applicable,
                                    ;; return unchanged
                                    (Nothing ($f $g))))
                                 )))
                             ;; $f and $g changed, attempt to uncurry
                             ;; their application once more
                             (uncurry ($νf $νg)))))
              ;; Otherwise, return unchanged
              ($else $term))))))))

;; ;; Test uncurry
!(assertEqual
  (uncurry ((. $f) $g))
  (. $f $g))
!(assertEqual
  (uncurry (((Φ $f) $g) $h))
  (Φ $f $g $h))
!(assertEqual
  (uncurry (((Φ (. $f $g)) $j) ((. $h) ((. $i) $j))))
  (Φ (. $f $g) $j (. $h (. $i $j))))
!(assertEqual
  (uncurry (((Φ $f) ((. $g) $j)) ((. $h) ((. $i) $j))))
  (Φ $f (. $g $j) (. $h (. $i $j))))
!(assertEqual
  (uncurry (((Φ $f) ((. $g) $j)) ((. $h) ((. $i) $j))))
  (Φ $f (. $g $j) (. $h (. $i $j))))
!(assertEqual
  (uncurry ((. (((Φ $f) $g) ((. $h) $i))) $j))
  (. (Φ $f $g (. $h $i)) $j))

;;;;;;;;;;;;;;;;;;;;;;
;; Backward chainer ;;
;;;;;;;;;;;;;;;;;;;;;;

;; Uncurried Backward Chainer with dependent types (no lambda
;; abstraction here, combinatory logic is used instead).  Inference
;; rules are directly embedded in the backchainer chainer code.
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

;; ;; Recursive step: bluebird
;; (= (bc $kb (S $k) (: (. $f $g) (-> (: $x $a) $c)))
;;    (let* (;; Recurse on f
;;           ((: $f (-> (: $y $b) $c)) (bc $kb $k (: $f (-> (: $y $b) $c))))
;;           ;; Recurse on g
;;           ((: $g (-> (: $x $a) $b)) (bc $kb $k (: $g (-> (: $x $a) $b))))
;;           ;; Prove that $a, $b and $c are concrete data types
;;           ;; (allocate only 0 depth, should be enough)
;;           ((: $aData (<: $a Data)) (bc $kb Z (: $aData (<: $a Data))))
;;           ((: $bData (<: $b Data)) (bc $kb Z (: $bData (<: $b Data))))
;;           ((: $cData (<: $c Data)) (bc $kb Z (: $cData (<: $c Data)))))
;;      ;; Make sure $a, $b and $c are concrete data types
;;      (if (and (is-closed $aData) (and (is-closed $bData) (is-closed $cData)))
;;          (: (. $f $g) (-> (: $x $a) $c))
;;          (empty))))

;; ;; Recursive step: phoenix
;; (= (bc $kb (S $k) (: (Φ $f $g $h) (-> (: $x $a) $d)))
;;    (let* (;; Recurse on f
;;           ((: $f (-> (: $y $b) (: $z $c) $d))
;;            (bc $kb $k (: $f (-> (: $y $b) (: $z $c) $d))))
;;           ;; Recurse on g
;;           ((: $g (-> (: $x $a) $b)) (bc $kb $k (: $g (-> (: $x $a) $b))))
;;           ;; Recurse on h
;;           ((: $h (-> (: $x $a) $c)) (bc $kb $k (: $h (-> (: $x $a) $c))))
;;           ;; Prove that $a, $b, $c and $d are concrete data types
;;           ;; (allocate only 0 depth, should be enough)
;;           ((: $aData (<: $a Data)) (bc $kb Z (: $aData (<: $a Data))))
;;           ((: $bData (<: $b Data)) (bc $kb Z (: $bData (<: $b Data))))
;;           ((: $cData (<: $c Data)) (bc $kb Z (: $cData (<: $c Data))))
;;           ((: $dData (<: $d Data)) (bc $kb Z (: $dData (<: $d Data)))))
;;      ;; Make sure $a, $b and $c are concrete data types
;;      (if (and (is-closed $aData)
;;               (and (is-closed $bData) (and (is-closed $cData)
;;                                            (is-closed $dData))))
;;          (: (Φ $f $g $h) (-> (: $x $a) $d))
;;          (empty))))

;; Recursive step: bluebird (no Data constraints)
(= (bc $kb (S $k) (: (. $f $g) (-> (: $x $a) $c)))
   (let* (;; Recurse on f
          ((: $f (-> (: $y $b) $c)) (bc $kb $k (: $f (-> (: $y $b) $c))))
          ;; Recurse on g
          ((: $g (-> (: $x $a) $b)) (bc $kb $k (: $g (-> (: $x $a) $b)))))
     (: (. $f $g) (-> (: $x $a) $c))))

;; Recursive step: phoenix (no Data constraints)
(= (bc $kb (S $k) (: (Φ $f $g $h) (-> (: $x $a) $d)))
   (let* (;; Recurse on f
          ((: $f (-> (: $y $b) (: $z $c) $d))
           (bc $kb $k (: $f (-> (: $y $b) (: $z $c) $d))))
          ;; Recurse on g
          ((: $g (-> (: $x $a) $b)) (bc $kb $k (: $g (-> (: $x $a) $b))))
          ;; Recurse on h
          ((: $h (-> (: $x $a) $c)) (bc $kb $k (: $h (-> (: $x $a) $c)))))
         (: (Φ $f $g $h) (-> (: $x $a) $d))))

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

;; Combinators are disabled as they have been moved to the backward
;; chainer

;; ;; Name: Bluebird
;; ;; Description: Sequential composition
;; ;; Type: (b -> c) -> (a -> b) -> a -> c
;; ;; Definition: bluebird f g x = f (g x)
;; ;; Symbol: .
;; ;; Diagram:
;; ;; -a-b-c->
;; !(add-atom &kb (: .
;;                   (-> (: $f (-> (: $y $b) $c))
;;                       (: $g (-> (: $x $a) $b))
;;                       (-> (: $x $a) $c))))

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
;;                   (-> (: $f (-> (: $y $b) (: $z $c) $d))
;;                       (: $g (-> (: $x $a) $b))
;;                       (: $h (-> (: $x $a) $c))
;;                       (-> (: $x $a) $d))))

;;;;;;;;;;;;;;;;;;;;;
;; Reduction rules ;;
;;;;;;;;;;;;;;;;;;;;;

;; Bluebird β-reduction
(= ((. $g $f) $x) ($g ($f $x)))

;; ;; Phoenix β-reduction.
;; ;;
;; ;; That rules is not recommended because it results in a duplication
;; ;; of $x.  It is therefor disabled during AI-service composition
;; ;; synthesis.
;; (= ((Φ $f $g $h) $x) (($f ($g $x)) ($h $x)))

;; These tests allow to prove that the reduction rules are correct in
;; the sense that the reduced term, if applied to arguments, β-reduces
;; to the same term.  Note that in order to pass all combinator
;; β-reduction rules need to be enabled.

;; ;; Test that applying left associative composition reduces is
;; ;; equivalent to applying right associative composition.
;; !(assertEqual
;;   ((. (. $h $g) $f) $x)
;;   ((. $h (. $g $f)) $x))

;; ;; Test that applying (Φ (. $f $g) $j (. $h (. $i $j)))
;; ;; once is equivalent to (Φ $f (. $g $j) (. $h (. $i $j)))
;; !(assertEqual
;;   ((Φ (. $f $g) $j (. $h (. $i $j))) $x)
;;   ((Φ $f (. $g $j) (. $h (. $i $j))) $x))

;; ;; Test that applying (Φ $f (. $g $j) (. $h (. $i $j))) once is
;; ;; equivalent to (. (Φ $f $g (. $h $i)) $j)
;; !(assertEqual
;;   ((Φ $f (. $g $j) (. $h (. $i $j))) $x)
;;   ((. (Φ $f $g (. $h $i)) $j) $x))

;; Right associate composition, meaning
;;
;; h . g . f
;;
;; should be represented as
;;
;; h . (g . f)
;;
;; Thus anything deviating from that representation, such as
;;
;; (h . g) . f
;;
;; or in MeTTa
;;
;; (. (. h g) f)
;;
;; should be rewritten as
;;
;; (. h (. g f))
;;
;; The reason left associativity is choosen as default over right
;; associativity is because in prefix notation the former is easier to
;; read (to me anyway).
(= (. (. $h $g) $f) (. $h (. $g $f)))

;; Move sequential composition from aggregator to branch.
;;
;; (Φ (. f g) j (. h (. i j)))
;;
;; reduces to
;;
;; (Φ f (. g j) (. h (. i j)))
(= (Φ (. $f $g) $j (. $h (. $i $j)))
   (Φ $f (. $g $j) (. $h (. $i $j))))

;; Factorize sequential branches of phoenix.
;;
;; (Φ f (. g i) (. h i))
;;
;; reduces to
;;
;; (. (Φ f g h) i)
(= (Φ $f (. $g $i) (. $h $i))
   (. (Φ $f $g $h) $i))

;; Specialized version of factorize sequential branches of phoenix.
;;
;; (Φ f (. g j) (. h (. i j)))
;;
;; reduces to
;;
;; (. (Φ f g (. h i)) j)
(= (Φ $f (. $g $j) (. $h (. $i $j)))
   (. (Φ $f $g (. $h $i)) $j))

;; ;; (Φ mix (. accomp spleeter) (. vocals spleeter))
;; (. (Φ mix (. accomp spleeter) (. vocals spleeter)) $f)

;; The composition of spleeter with the mixing of accomp
;; and vocals is involutive.
(= (. (Φ mix accomp vocals) spleeter) id)
(= (. spleeter (Φ mix accomp vocals)) id)

;; The composition of (. spleeter f) or (. f spleeter) with the mixing
;; of accomp and vocals is idempotent with respect to f.
(= (. (Φ mix accomp vocals) (. spleeter $f)) $f)
(= (. (. $f spleeter) (Φ mix accomp vocals)) $f)

;; Composing with id is idempotent.  Or id is the identity element of
;; composition.
(= (. id $f) $f)
(= (. $f id) $f)

;; Applying id to x outputs x
(= (id $x) $x)

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

;; Synthesize full AI service composition
!(assertEqual
  (unique
   (capture
    (bc &kb
        (fromNumber 3)
        (: $prg (-> (: $x (SongIn "English")) (SongIn "Chinese"))))))
  (: (. (Φ mix accomp (. translate vocals)) spleeter)
     (-> (: $x (SongIn "English")) (SongIn "Chinese"))))

;; Synthesize full AI service composition with depth 4.  Depth 3 is
;; enough but we want to test how much reduction and Data constraints
;; help to prune the search.
;;
;; At this depth though adding Data constraints still does not help.
;; Indeed we get the same results with or without it.  However,
;; without Data constraints it is about x3 faster, probably cause
;; there is less code to evaluate.
;;
;; Reduction on the other hand tremedously helps.  Indeed, with
;; reduction onle 1 result is returned instead of 80 without reduction
;; (with or without Data constraints).
!(assertEqual
  (unique
   (capture
    (bc &kb
        (fromNumber 4)
        (: $prg (-> (: $x (SongIn "English")) (SongIn "Chinese"))))))
  (: (. (Φ mix accomp (. translate vocals)) spleeter)
     (-> (: $x (SongIn "English")) (SongIn "Chinese"))))

;; Synthesize full AI service composition with depth 5.  Data
;; constraints still makes no difference.  Reduction obviously makes a
;; tremendous difference.
!(assertEqual
  (unique
   (capture
    (bc &kb
        (fromNumber 5)
        (: $prg (-> (: $x (SongIn "English")) (SongIn "Chinese"))))))
  (: (. (Φ mix accomp (. translate vocals)) spleeter)
     (-> (: $x (SongIn "English")) (SongIn "Chinese"))))

;; Synthesize full AI service composition with depth 6.  Data
;; constraints still makes no difference.  Reduction obviously makes a
;; tremendous difference.  Some candidates could not be reduced even
;; though they are probably equivalent to the shortest one given some
;; semantics assumptions.
!(assertEqualToResult
  (unique
   (capture
    (bc &kb
        (fromNumber 6)
        (: $prg (-> (: $x (SongIn "English")) (SongIn "Chinese"))))))
  ((: (. (Φ mix (. accomp (. spleeter (Φ mix accomp (. translate vocals))))
            (. translate vocals)) spleeter)
      (-> (: $x (SongIn "English")) (SongIn "Chinese")))
   (: (. (Φ mix accomp (. vocals (. spleeter (Φ mix accomp (. translate vocals)))))
         spleeter)
      (-> (: $x (SongIn "English")) (SongIn "Chinese")))
   (: (Φ mix (. accomp (. spleeter (. (Φ mix accomp (. translate vocals)) spleeter)))
         (. translate (. vocals spleeter)))
      (-> (: $x (SongIn "English")) (SongIn "Chinese")))
   (: (. (Φ mix accomp (. translate vocals)) spleeter)
      (-> (: $x (SongIn "English")) (SongIn "Chinese")))
   (: (Φ mix (. accomp spleeter)
         (. vocals (. spleeter (. (Φ mix accomp (. translate vocals)) spleeter))))
      (-> (: $x (SongIn "English")) (SongIn "Chinese")))))
