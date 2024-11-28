;; Like etcs-combinator-sd-data-uncurry-xp.metta but tested on the
;; whole AI service composition instead of the scaled down one.

;;;;;;;;;;;
;; Maybe ;;
;;;;;;;;;;;

;; Define Maybe type
(: Maybe (-> $a Type))
(: Nothing (Maybe $a))
(: Just (-> $a (Maybe $a)))

;;;;;;;;;;
;; List ;;
;;;;;;;;;;

;; Declaration of List data type and constructors
(: List (-> $a Type))
(: Nil (List $a))
(: Cons (-> $a (List $a) (List $a)))

;; Define List.append (concatenate two lists).
(: List.append (-> (List $a) (List $a) (List $a)))
(= (List.append Nil $ys) $ys)
(= (List.append (Cons $x $xs) $ys) (Cons $x (List.append $xs $ys)))

;;;;;;;;;;
; String ;
;;;;;;;;;;

;; Fold a tuple from right to left
(: foldr (-> (-> $a $b $b) $b $c $d))
(= (foldr $f $i $xs)
   (if (== $xs ())
       $i
       (let* (($h (car-atom $xs))
              ($t (cdr-atom $xs))
              ($ft (foldr $f $i $t)))
         ($f $h $ft))))

;; Concatenate two terms
(: append (-> $a $a $a))
(= (append $lhs $rhs) (foldr cons-atom $rhs $lhs))

;; Concatenate two strings
(: String.append (-> String String String))
(= (String.append $x $y) (let* (($xcs (stringToChars $x))
                                ($ycs (stringToChars $y))
                                ($xycs (append $xcs $ycs)))
                           (charsToString $xycs)))

!(assertEqual (String.append "abc" "def") "abcdef")

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

;;;;;;;;;
;; DOT ;;
;;;;;;;;;

;; DOT Rankdir
(: DOT.Rankdir Type)
(: DOT.Rankdir.BT DOT.Rankdir)                 ; Bottom to top
(: DOT.Rankdir.TB DOT.Rankdir)                 ; Top to bottom
(: DOT.Rankdir.LR DOT.Rankdir)                 ; Left to right
(: DOT.Rankdir.RL DOT.Rankdir)                 ; Right to left

;; DOT Style
(: DOT.Style Type)
(: DOT.Style.Rounded DOT.Style)

;; DOT shape
(: DOT.Shape Type)
(: DOT.Shape.Plain DOT.Shape)
(: DOT.Shape.Box DOT.Shape)

;; DOT attribute
(: DOT.Attribute Type)

;; Constructors
(: DOT.MkLabelAttribute (-> String DOT.Attribute))
(: DOT.MkStyleAttribute (-> DOT.Style DOT.Attribute))
(: DOT.MkShapeAttribute (-> DOT.Shape DOT.Attribute))
(: DOT.MkRankdirAttribute (-> DOT.Rankdir DOT.Attribute))

;; Access functions
(: DOT.Attribute.label (-> DOT.Attribute (Maybe String)))
(= (DOT.Attribute.label $attribute)
   (case $attribute
     (((DOT.MkLabelAttribute $label) (Just $label))
      ($else Nothing))))

(: DOT.Attribute.style (-> DOT.Attribute (Maybe DOT.Style)))
(= (DOT.Attribute.shape $style)
   (case $style
     (((DOT.MkStyleAttribute $style) (Just $style))
      ($else Nothing))))

(: DOT.Attribute.shape (-> DOT.Attribute (Maybe DOT.Shape)))
(= (DOT.Attribute.shape $attribute)
   (case $attribute
     (((DOT.MkShapeAttribute $shape) (Just $shape))
      ($else Nothing))))

(: DOT.Attribute.rankdir (-> DOT.Attribute (Maybe DOT.Rankdir)))
(= (DOT.Attribute.rankdir $attribute)
   (case $attribute
     (((DOT.MkRankdirAttribute $rankdir) (Just $rankdir))
      ($else Nothing))))

;; Test DOT attributes
!(assertEqual
  (get-type (Cons (DOT.MkShapeAttribute DOT.Shape.Box) Nil))
  (List DOT.Attribute))

;; DOT Identifier
(: DOT.Identifier Type)

;; Constructor
(: DOT.MkIdentifier (-> Symbol Number DOT.Identifier))

;; Access functions
(: DOT.Identifier.symbol (-> DOT.Identifier Symbol))
(= (DOT.Identifier.symbol (DOT.MkIdentifier $symbol $index)) $symbol)

(: DOT.Identifier.index (-> DOT.Identifier Number))
(= (DOT.Identifier.index (DOT.MkIdentifier $symbol $index)) $index)

;; DOT node
(: DOT.Node Type)

;; Constructor
(: DOT.MkNode (-> DOT.Identifier        ; Identifier
                  (List DOT.Attribute)  ; Attributes
                  DOT.Node))

;; Access functions
(: DOT.Node.identifier (-> DOT.Node Symbol))
(= (DOT.Node.identifier (DOT.MkNode $identifier $attributes)) $identifier)

(: DOT.Node.attributes (-> DOT.Node (List DOT.Attributes)))
(= (DOT.Node.attributes (DOT.MkNode $identifier $attributes)) $attributes)

;; Data type of DOT edge
(: DOT.Edge Type)

;; Constructor
(: DOT.MkEdge (-> DOT.Node              ; Source
                  DOT.Node              ; Destination
                  (List DOT.Attribute)  ; Attributes
                  DOT.Edge))

;; Access functions
(: DOT.Edge.source (-> DOT.Edge DOT.Node))
(= (DOT.Edge.source (DOT.MkEdge $source $destination $attributes)) $source)

(: DOT.Edge.destination (-> DOT.Edge DOT.Node))
(= (DOT.Edge.destination (DOT.MkEdge $source $destination $attributes)) $destination)

(: DOT.Edge.attributes (-> DOT.Edge (List DOT.Attribute)))
(= (DOT.Node.attributes (DOT.MkEdge $source $destination $attributes)) $attributes)

;; Data type to describe Graphviz DOT data
(: DOT Type)
(: MkDOT (-> (List DOT.Node)                ; List of nodes
             (List DOT.Edge)                ; List of edges
             DOT.Node                       ; Entry node
             DOT.Node                       ; Exit node
             (List DOT.Attribute)           ; List of attributes
             DOT))

;; Test MkDOT
!(assertEqual
  (MkDOT Nil
         Nil
         (DOT.MkNode (DOT.MkIdentifier mix 0)
                     (Cons (DOT.MkShapeAttribute DOT.Shape.Box) Nil))
         (DOT.MkNode (DOT.MkIdentifier mix 0)
                     (Cons (DOT.MkShapeAttribute DOT.Shape.Box) Nil))
         (Cons (DOT.MkRankdirAttribute DOT.Rankdir.BT) Nil))
  (MkDOT Nil
         Nil
         (DOT.MkNode (DOT.MkIdentifier mix 0)
                     (Cons (DOT.MkShapeAttribute DOT.Shape.Box) Nil))
         (DOT.MkNode (DOT.MkIdentifier mix 0)
                     (Cons (DOT.MkShapeAttribute DOT.Shape.Box) Nil))
         (Cons (DOT.MkRankdirAttribute DOT.Rankdir.BT) Nil)))

;; Return the default attributes of a DOT file
(: globalAttributes (-> (List DOT.Attribute)))
(= (globalAttributes) (Cons (DOT.MkRankdirAttribute DOT.Rankdir.BT) Nil))

;; Return the default attributes of a node representing a function
(: functionAttributes (-> (List DOT.Attribute)))
(= (functionAttributes) (Cons (DOT.MkShapeAttribute DOT.Shape.Box) Nil))

;; Build the DOT data structure corresponding to a given term.  That
;; function is crafted around the assumption that the input term is an
;; AI service composition.
(: toDOT (-> Atom DOT))
(= (toDOT $term)
   (let (MkDOT $nodes $edges $entry $exit $attributes) (toDOT_ $term 0)
        ;; Return DOT data plus some hardwired default attributes
        (MkDOT $nodes
               $edges
               $entry
               $exit
               (List.append (globalAttributes) $attributes))))

;; Make empty DOT data structure
(: mkEmptyDOT (-> DOT))
(= (mkEmptyDOT) (MkDOT Nil Nil (MkIdentifier _ 0) (MkIdentifier _ 0) Nil))

;; Like toDOT but it is the recursive definition, not the entry point.
;; The extra index argument is used to generate unique ID.
(: toDOT_ (-> Atom Number DOT))
(= (toDOT_ $term $index)
   (case (get-metatype $term)
     (;; Base case (for now Variable and Grounded are not supported)
      (Symbol (let $node
                  (DOT.MkNode (DOT.MkIdentifier $term $index) (functionAttributes))
                (MkDOT (Cons $node Nil) Nil $node $node Nil)))
      ;; Recursive step
      (Expression (case $term
                    (;; Base case
                     (() (mkEmptyDOT))
                     ;; Recursive steps
                     ;; Bluebird
                     ((. $f $g) NEXT)
                     ;; Phoenix
                     ((Φ $f $g $h) NEXT)
                     ;; Otherwise
                     ($else (mkEmptyDOT)))))
      ($else (mkEmptyDOT)))))

;; Test toDOT
!(assertEqual
  (toDOT mix)
  (MkDOT (Cons (DOT.MkNode (DOT.MkIdentifier mix 0) (functionAttributes)) Nil)
         Nil
         (DOT.MkNode (DOT.MkIdentifier mix 0) (functionAttributes))
         (DOT.MkNode (DOT.MkIdentifier mix 0) (functionAttributes))
         (globalAttributes)))

;; Takes a DOT data structure and output the corresponding string in
;; DOT format.
(: DOT.toString (-> DOT String))

;; NEXT: implement DOT.toString, you may use the following builtin
;; repr: convert Atom to string.

;;;;;;;;;;;;;
;; Uncurry ;;
;;;;;;;;;;;;;

;; Return True iff $term is closed
;; TODO: generalize for n-ary expression
(: is-closed (-> Atom Bool))
(= (is-closed $term)
   (case (, $term (get-metatype $term))
     (((, $_ Variable) False)
      ((, ($abs $arg) Expression) (and (is-closed $abs) (is-closed $arg)))
      ($otherwise True))))

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

;; ;; Recursive step for subtyping transitivity
;; (= (bc $kb (S $k) (: (STTrans $bc $ab) (<: $a $c)))
;;    (let* (;; Recurse on $bc
;;           ((: $bc (<: $b $c)) (bc $kb $k (: $bc (<: $b $c))))
;;           ;; Recurse on $ab
;;           ((: $ab (<: $a $b)) (bc $kb $k (: $ab (<: $a $b))))
;;           ;; Prove that $a, $b and $c are concrete data types
;;           ;; (allocate only 0 depth, should be enough)
;;           ((: $aD (<: $a Data)) (bc $kb Z (: $aD (<: $a Data))))
;;           ((: $bD (<: $b Data)) (bc $kb Z (: $bD (<: $b Data))))
;;           ((: $cD (<: $c Data)) (bc $kb Z (: $cD (<: $c Data)))))
;;      ;; Make sure $a, $b and $c are concrete data types
;;      (if (and (is-closed $aD) (and (is-closed $bD) (is-closed $cD)))
;;          (: (STTrans $bc $ab) (<: $a $c))
;;          (empty))))

;; ;; Recursive step for subtyping coercion.
;; ;;
;; ;; Relationship between subtyping and type assume explicit coercion.
;; ;; That is if a term `t` is of type `S` a subtype of `T`, then
;; ;; `(coerce proof_S<:T t)` is of type `T`, where `proof_S<:T` is a
;; ;; proof that `S` is a subtype of `T`.
;; (= (bc $kb (S $k) (: (coerce $ab $x) $b))
;;    (let* (;; Recurse on $ab
;;           ((: $ab (<: $a $b)) (bc $kb $k (: $ab (<: $a $b))))
;;           ;; Recurse on $x
;;           ((: $x $a) (bc $kb $k (: $x $a)))
;;           ;; Prove that $a and $b are concrete data types
;;           ;; (allocate only 0 depth, should be enough)
;;           ((: $aD (<: $a Data)) (bc $kb Z (: $aD (<: $a Data))))
;;           ((: $bD (<: $b Data)) (bc $kb Z (: $bD (<: $b Data)))))
;;      ;; Make sure $a, $b and $c are concrete data types
;;      (if (and (is-closed $aD) (is-closed $bD))
;;          (: (coerce $ab $x) $b)
;;          (empty))))

;; ;; Recursive step: bluebird
;; (= (bc $kb (S $k) (: (. $f $g) (-> (: $x $a) $c)))
;;    (let* (;; Recurse on f
;;           ((: $f (-> (: $y $b) $c)) (bc $kb $k (: $f (-> (: $y $b) $c))))
;;           ;; Recurse on g
;;           ((: $g (-> (: $x $a) $b)) (bc $kb $k (: $g (-> (: $x $a) $b))))
;;           ;; Prove that $a, $b and $c are concrete data types
;;           ;; (allocate only 0 depth, should be enough)
;;           ((: $aD (<: $a Data)) (bc $kb Z (: $aD (<: $a Data))))
;;           ((: $bD (<: $b Data)) (bc $kb Z (: $bD (<: $b Data))))
;;           ((: $cD (<: $c Data)) (bc $kb Z (: $cD (<: $c Data)))))
;;      ;; Make sure $a, $b and $c are concrete data types
;;      (if (and (is-closed $aD) (and (is-closed $bD) (is-closed $cD)))
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
;;           ((: $aD (<: $a Data)) (bc $kb Z (: $aD (<: $a Data))))
;;           ((: $bD (<: $b Data)) (bc $kb Z (: $bD (<: $b Data))))
;;           ((: $cD (<: $c Data)) (bc $kb Z (: $cD (<: $c Data))))
;;           ((: $dD (<: $d Data)) (bc $kb Z (: $dD (<: $d Data)))))
;;      ;; Make sure $a, $b and $c are concrete data types
;;      (if (and (is-closed $aD)
;;               (and (is-closed $bD) (and (is-closed $cD)
;;                                         (is-closed $dD))))
;;          (: (Φ $f $g $h) (-> (: $x $a) $d))
;;          (empty))))

;; Recursive step for machine-translation.translate.  The point of
;; embedding the machine-translation.translate call in the backward
;; chainer is to be able to infer the correct parameters (in/out
;; languages) for call the service.
(= (bc $kb (S $k) (: (machine-translation.translate $in-nl $out-nl)
                     (-> (: $url (UniformResourceLocatorOfType (TextIn $in-nl)))
                         (TextIn $out-nl))))
   (let* (;; Recurse on $in-nl
          ((: $in-nl NaturalLanguage) (bc $kb $k (: $in-nl NaturalLanguage)))
          ;; Recurse on $out-nl
          ((: $out-nl NaturalLanguage) (bc $kb $k (: $out-nl NaturalLanguage))))
     (: (machine-translation.translate $in-nl $out-nl)
        (-> (: $url (UniformResourceLocatorOfType (TextIn $in-nl)))
            (TextIn $out-nl)))))

;; Recursive step for subtyping transitivity (no data constraint)
(= (bc $kb (S $k) (: (STTrans $bc $ab) (<: $a $c)))
   (let* (;; Recurse on $bc
          ((: $bc (<: $b $c)) (bc $kb $k (: $bc (<: $b $c))))
          ;; Recurse on $ab
          ((: $ab (<: $a $b)) (bc $kb $k (: $ab (<: $a $b)))))
     (: (STTrans $bc $ab) (<: $a $c))))

;; Recursive step for subtyping coercion (no data constraint)
(= (bc $kb (S $k) (: (coerce $ab) (-> (: $x $a) $b)))
   (let ;; Recurse on $ab
       (: $ab (<: $a $b)) (bc $kb $k (: $ab (<: $a $b)))
     (: (coerce $ab) (-> (: $x $a) $b))))

;; Recursive step: bluebird (no data constraints)
(= (bc $kb (S $k) (: (. $f $g) (-> (: $x $a) $c)))
   (let* (;; Recurse on f
          ((: $f (-> (: $y $b) $c)) (bc $kb $k (: $f (-> (: $y $b) $c))))
          ;; Recurse on g
          ((: $g (-> (: $x $a) $b)) (bc $kb $k (: $g (-> (: $x $a) $b)))))
     (: (. $f $g) (-> (: $x $a) $c))))

;; Recursive step: phoenix (no data constraints)
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

;; The ontology tries to be based on existing ontologies when
;; possible.  See the following discussion for a list of ontologies
;;
;; https://github.com/singnet/ai-dsl/discussions/18

;; Language
!(add-atom &kb (: NS (<: NaturalLanguage String)))             ; SUMO

;; Text
!(add-atom &kb (: TS (<: Text String)))
!(add-atom &kb (: TIT (<: (TextIn $l) Text)))

;; URL
!(add-atom &kb (: US (<: UniformResourceLocator String)))      ; SUMO
!(add-atom &kb (: UTU (<: (UniformResourceLocatorOfType $t) UniformResourceLocator)))

;; MIDI
!(add-atom &kb (: MB (<: MusicalInstrumentDigitalInterface Bytes)))

;; Audio
!(add-atom &kb (: AB (<: Audio Bytes)))
!(add-atom &kb (: IA (<: Instrumental Audio)))
!(add-atom &kb (: VA (<: Vocals Audio)))
!(add-atom &kb (: VIV (<: (VocalsIn $l) Vocals)))
!(add-atom &kb (: SIA (<: (SongIn $l) Audio)))

;; Additionally we add an upper type called Data, which all data types
;; are subtypes of.  This can be used as pruning criterion.  In
;; principle we would only need to do that for the most general data
;; types, like String, Number, etc, however, since it is used for
;; pruning, such criterion should compute as fast as possible, so we
;; directly provide the entire transitive closure.
!(add-atom &kb (: BD (<: Bytes Data)))
!(add-atom &kb (: SD (<: String Data)))
!(add-atom &kb (: ND (<: NaturalLanguage Data)))
!(add-atom &kb (: TD (<: Text Data)))
!(add-atom &kb (: TID (<: (TextIn $l) Data)))
!(add-atom &kb (: UD (<: UniformResourceLocator Data)))
!(add-atom &kb (: UTD (<: (UniformResourceLocatorOfType $t) Data)))
!(add-atom &kb (: MD (<: MusicalInstrumentDigitalInterface Data)))
!(add-atom &kb (: AD (<: Audio Data)))
!(add-atom &kb (: ID (<: Instrumental Data)))
!(add-atom &kb (: VD (<: Vocals Data)))
!(add-atom &kb (: VID (<: (VocalsIn $l) Data)))
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

;; For now we paste the content of
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
;; Also, only the useful definitions are kept.  For instance the
;; sound-spleeter.MkDTLOutput constructor is commented because it has
;; no use in the final composition.

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
;; Protobuf file: translate.proto
;; Protobuf syntax: proto3
;; Prefix: naint.machine-translation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Define machine-translation.translate service method
;;
;; Note: this one remains curried because the first two arguments are
;; viewed as parameters (this is a way to work around the rigidity of
;; uncurried combinators).
!(add-atom &kb (: machine-translation.translate
                  (-> (: $in-nl NaturalLanguage)
                      (: $out-nl NaturalLanguage)
                      (-> (: $url (UniformResourceLocatorOfType (TextIn $in-nl)))
                          (TextIn $out-nl)))))

;; We add an extra micro service to turn Text into a URL
!(add-atom &kb (: upload (-> (: $x $a)
                             (UniformResourceLocatorOfType $a))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MeTTa representation, generated by protobuf-metta
;;
;; Protobuf file: singingZH.proto
;; Protobuf syntax: proto3
;; Protobuf package: singingZH
;; Prefix: midi2voice-zh
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Define midi2voice-zh.singingZH service method
!(add-atom &kb (: midi2voice-zh.singingZH
                  (-> (: $text (TextIn "Chinese"))
                      (: $midi MusicalInstrumentDigitalInterface)
                      (VocalsIn "Chinese"))))

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
;;                       (: $voc (VocalsIn $l))
;;                       (: $inst Instrumental)
;;                       (sound-spleeter.DTLOutput $l))))

;; Define sound-spleeter.DTLOutput access functions

;; Define sound-spleeter.DTLOutput.vocals
!(add-atom &kb (: sound-spleeter.DTLOutput.vocals
                  (-> (: $out (sound-spleeter.DTLOutput $l))
                      (VocalsIn $l))))

;; Define sound-spleeter.OutputDTL.accomp
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MeTTa representation, generated by protobuf-metta
;;
;; Protobuf file: asr.proto
;; Protobuf syntax: proto3
;; Protobuf package: asr
;; Prefix: speech-recognition
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Define speech-recognition.s2t service method
!(add-atom &kb (: speech-recognition.s2t
                  (-> (: $audio Audio)
                      (TextIn "English"))))

;; ;; Define speech-recognition.s2t service method
;; !(add-atom &kb (: speech-recognition.s2t
;;                   (-> (: $x (VocalsIn "English"))
;;                       (TextIn "English"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Handwrite missing services, ToMidi and Mixer ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;
;; ToMidi ;;
;;;;;;;;;;;;

;; Method
!(add-atom &kb (: tomidi.a2m
                  (-> (: $audio Audio)
                      MusicalInstrumentDigitalInterface)))

;;;;;;;;;;;
;; Mixer ;;
;;;;;;;;;;;

;; ;; Method
;; !(add-atom &kb (: mixer.mix (-> (: $audio1 Audio)
;;                                 (-> (: $audio2 Audio)
;;                                     Audio))))

;; DTL version
!(add-atom &kb (: mixer.mix (-> (: $inst Instrumental)
                                (: $voc (VocalsIn $l))
                                (SongIn $l))))

;; Acrobatic attempt to specify a property about mixing without
;; overloading the type signature of the mixer
;;
;; (: $mixer Mixer) -> ($mixer (c1 $x) (c2 $y)) and (: $x (VocalsIn $l)) (: $y Instrumental) -> $z === mix ...) -> (: $z (SongIn $l))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Other type definitions ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; English language string
!(add-atom &kb (: "English" NaturalLanguage))

;; Chinese language string
!(add-atom &kb (: "Chinese" NaturalLanguage))

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

;; Sequential coercion
(= (. (coerce $bc) (coerce $ab)) (coerce (STTrans $bc $ab)))

;; Translating from/to the same language reduces to id
(= (machine-translation.translate $l $l) id)

;; Translating back and forth from/to the same languages reduces to
;; id.  Obviously, this is not strictly true, but such combination is
;; useless enough that it gets reduced anyway.
(= (. (machine-translation.translate $l1 $l2)
      (. upload (. (machine-translation.translate $l2 $l1) upload)))
   id)

;;;;;;;;;;
;; Test ;;
;;;;;;;;;;

;; Synthesize composition of
;;
;; (-> (SongIn "English") (sound-spleeter.DTLOutput "English"))
;;
;; which is merely a spleeter call
!(assertEqual
  (bc &kb
      (fromNumber 0)
      (: $prg
         (-> (: $x (SongIn "English")) (sound-spleeter.DTLOutput "English"))))
  (: sound-spleeter.spleeter
     (-> (: $x (SongIn "English")) (sound-spleeter.DTLOutput "English"))))

;; Synthesize sequential composition of
;;
;; (-> Audio (TextIn "English"))
;;
;; which should merely be a call of speech-recognition.
!(assertEqual
  (bc &kb (fromNumber 0) (: $prg (-> (: $x Audio) (TextIn "English"))))
  (: speech-recognition.s2t (-> (: $x Audio) (TextIn "English"))))

;; Prove that (<: (VocalsIn "English") Audio)
!(assertEqual
  (bc &kb (fromNumber 1) (: $prf (<: (VocalsIn "English") Audio)))
  (: (STTrans VA VIV) (<: (VocalsIn "English") Audio)))

;; Synthesize composition of
;;
;; (-> (VocalsIn "English") Audio)
;;
;; which should be a coercion
!(assertEqual
  (unique
   (capture
    (bc &kb (fromNumber 2) (: $prg (-> (: $x (VocalsIn "English")) Audio)))))
  (: (coerce (STTrans VA VIV)) (-> (: $x (VocalsIn "English")) Audio)))

;; Synthesize sequential composition of
;;
;; (-> (VocalsIn "English") (TextIn "English"))
;;
;; which should merely be a call of speech-recognition with proper
;; casting from (VocalsIn "English") to Audio.
!(assertEqual
  (unique
   (capture
    (bc &kb
        (fromNumber 3)
        (: $prg
           (-> (: $x (VocalsIn "English")) (TextIn "English"))))))
  (: (. speech-recognition.s2t (coerce (STTrans VA VIV)))
     (-> (: $x (VocalsIn "English")) (TextIn "English"))))

;; Synthesize sequential composition of
;;
;; (-> Audio (UniformResourceLocatorOfType (TextIn "English")))
;;
;; which should be a sequential composition of speech-recognition and
;; upload.
!(assertEqual
  (bc &kb
      (fromNumber 1)
      (: $prg
         (-> (: $x Audio) (UniformResourceLocatorOfType (TextIn "English")))))
  (: (. upload speech-recognition.s2t)
     (-> (: $x Audio) (UniformResourceLocatorOfType (TextIn "English")))))

;; Synthesize sequential composition of
;;
;; (-> (VocalsIn "English") (UniformResourceLocatorOfType (TextIn "English")))
;;
;; which should be a sequential composition of speech-recognition,
;; upload and proper type coercion.
!(assertEqual
  (bc &kb
      (fromNumber 3)
      (: $prg
         (-> (: $x (VocalsIn "English"))
             (UniformResourceLocatorOfType (TextIn "English")))))
  (: (. upload (. speech-recognition.s2t (coerce (STTrans VA VIV))))
     (-> (: $x (VocalsIn "English"))
         (UniformResourceLocatorOfType (TextIn "English")))))

;; Synthesize composition of
;;
;; (-> (: "English" NaturalLanguage)
;;     (: "Chinese" NaturalLanguage)
;;     (-> (UniformResourceLocatorOfType (TextIn "English"))
;;         (TextIn "Chinese")))
;;
;; which should merely be a call to machine-translation.translate.
!(assertEqual
  (bc &kb
      (fromNumber 0)
      (: $prg
         (-> (: "English" NaturalLanguage)
             (: "Chinese" NaturalLanguage)
             (-> (: $x (UniformResourceLocatorOfType (TextIn "English")))
                 (TextIn "Chinese")))))
  (: machine-translation.translate
     (-> (: "English" NaturalLanguage)
         (: "Chinese" NaturalLanguage)
         (-> (: $x (UniformResourceLocatorOfType (TextIn "English")))
             (TextIn "Chinese")))))

;; Synthesize composition of
;;
;; (-> (UniformResourceLocatorOfType (TextIn "English")) (TextIn "Chinese"))
;;
;; which should merely be a call to machine-translation.translate with
;; proper parameters.
!(assertEqual
  (bc &kb
      (fromNumber 1)
      (: $prg
         (-> (: $x (UniformResourceLocatorOfType (TextIn "English")))
             (TextIn "Chinese"))))
  (: (machine-translation.translate "English" "Chinese")
     (-> (: $x (UniformResourceLocatorOfType (TextIn "English")))
         (TextIn "Chinese"))))

;; Synthesize sequential composition of
;;
;; (-> (TextIn "English") (TextIn "Chinese"))
;;
;; which should be a sequential composition of
;; machine-translation.translate with proper parameters and upload.
!(assertEqual
  (bc &kb
      (fromNumber 2)
      (: $prg
         (-> (: $x (TextIn "English")) (TextIn "Chinese"))))
  (: (. (machine-translation.translate "English" "Chinese") upload)
     (-> (: $x (TextIn "English")) (TextIn "Chinese"))))

;; Synthesize sequential composition of type
;;
;; (-> Audio (TextIn "Chinese"))
;;
;; which should be the composition of speech-recognition.s2t and
;; machine-translation.translate.
!(assertEqual
  (unique
   (capture
    (bc &kb
        (fromNumber 3)
        (: $prg
           (-> (: $x Audio) (TextIn "Chinese"))))))
  (: (. (machine-translation.translate "English" "Chinese")
        (. upload speech-recognition.s2t))
     (-> (: $x Audio) (TextIn "Chinese"))))

;; Synthesize sequential composition of type
;;
;; (-> (VocalsIn "English") (TextIn "Chinese"))
;;
;; which should be the composition of speech-recognition.s2t and
;; machine-translation.translate with the proper type coercions.
!(assertEqual
  (unique
   (capture
    (bc &kb
      (fromNumber 4)
      (: $prg
         (-> (: $x (VocalsIn "English")) (TextIn "Chinese"))))))
  (: (. (machine-translation.translate "English" "Chinese")
        (. upload (. speech-recognition.s2t (coerce (STTrans VA VIV)))))
     (-> (: $x (VocalsIn "English")) (TextIn "Chinese"))))

;; Type check the sequential composition
;;
;; (. sound-spleeter.DTLOutput.accomp sound-spleeter.spleeter)
!(assertEqual
  (bc &kb (fromNumber 1)
      (: (. sound-spleeter.DTLOutput.accomp sound-spleeter.spleeter)
         (-> (: $x (SongIn $l)) Instrumental)))
  (: (. sound-spleeter.DTLOutput.accomp sound-spleeter.spleeter)
     (-> (: $x (SongIn $l)) Instrumental)))

;; Type check the following AI service composition
;;
;; (. (Φ midi2voice-zh.singingZH
;;       (. (machine-translation.translate "English" "Chinese")
;;          (. upload speech-recognition.s2t))
;;       tomidi.a2m)
;;    (coerce SIA))
!(assertEqual
  (bc &kb (fromNumber 4)
      (: (. (Φ midi2voice-zh.singingZH
               (. (machine-translation.translate "English" "Chinese")
                  (. upload speech-recognition.s2t))
               tomidi.a2m)
            (coerce SIA))
         (-> (: $x (SongIn $l)) (VocalsIn "Chinese"))))
  (: (. (Φ midi2voice-zh.singingZH
           (. (machine-translation.translate "English" "Chinese")
              (. upload speech-recognition.s2t))
           tomidi.a2m)
        (coerce SIA))
     (-> (: $x (SongIn $l)) (VocalsIn "Chinese"))))

;; ;; Synthesize all AI service composition going from (SongIn "English")
;; ;; to (SongIn "Chinese")
;; ;; !(assertEqual  ; Re-enable on assert contain is supported
;; !(bc &kb (fromNumber 6)
;;      (: $prg
;;         (-> (: $x (SongIn "English")) (SongIn "Chinese"))))
;; ;; (: (. (Φ mixer.mix sound-spleeter.DTLOutput.accomp
;; ;;          (. (Φ midi2voice-zh.singingZH
;; ;;                (. (machine-translation.translate "English" "Chinese")
;; ;;                   (. upload speech-recognition.s2t))
;; ;;                tomidi.a2m)
;; ;;             (. (coerce IA) sound-spleeter.DTLOutput.accomp)))
;; ;;       sound-spleeter.spleeter)
;; ;;    (-> (: $x (SongIn "English")) (SongIn "Chinese")))
