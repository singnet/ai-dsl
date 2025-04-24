;; Like etcs-combinator-sd-data-uncurry-xp.metta but tested on the
;; whole AI service composition instead of the scaled down one.

;;;;;;;;;;;
;; Utils ;;
;;;;;;;;;;;

;; Run the code if the condition is true, otherwise prune the branch
(: when (-> Bool $a $a))
(= (when $c $x) (if $c $x (empty)))

;; Return the total length of a term, corresponding roughly to the
;; number of symbols in the term.
(: termLength (-> Atom Number))
(= (termLength $term) (case (get-metatype $term)
                        ((Expression (if (== $term ())
                                         0
                                         (let* (($head (car-atom $term))
                                                ($tail (cdr-atom $term)))
                                           (+ (termLength $head)
                                              (termLength $tail)))))
                         ($else 1))))

;; Test termLength
!(assertEqual
  (termLength (A B (C D)))
  4)

;; Compare two terms by their lengths
(: termLengthLT (-> Atom Atom Bool))
(= (termLengthLT $x $y) (< (termLength $x) (termLength $y)))

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

;; Construct list from tuple
(: toList (-> Expression (List $a)))
(= (toList $expr) (if (== $expr ())
                      Nil
                      (let* (($head (car-atom $expr))
                             ($tail (cdr-atom $expr)))
                        (Cons $head (toList $tail)))))

;; Test toList
!(assertEqual
  (toList (A (A B) (A B (C D))))
  (Cons A (Cons (A B) (Cons (A B (C D)) Nil))))

;; Fold a List from right to left
(: List.foldr (-> (-> $a $b $b) $b (List $a) $b))
(= (List.foldr $f $i Nil) $i)
(= (List.foldr $f $i (Cons $h $t)) ($f $h (List.foldr $f $i $t)))

;; Fold a List from left to right
(: List.foldl (-> (-> $b $a $b) $b (List $a) $b))
(= (List.foldl $f $i Nil) $i)
(= (List.foldl $f $i (Cons $h $t)) (List.foldl $f ($f $i $h) $t))

;; Define List.append (concatenate two lists).
(: List.append (-> (List $a) (List $a) (List $a)))
(= (List.append $xs $ys) (List.foldr Cons $ys $xs))

;; Test List.append
!(assertEqual
  (List.append (Cons a (Cons b Nil)) (Cons c (Cons d Nil)))
  (Cons a (Cons b (Cons c (Cons d Nil)))))

;; Overload List.append to support more than 2 arguments
(: List.append3 (-> (List $a) (List $a) (List $a) (List $a)))
(= (List.append3 $x $y $z) (List.append $x (List.append $y $z)))
(: List.append4 (-> (List $a) (List $a) (List $a) (List $a) (List $a)))
(= (List.append4 $x $y $z $w) (List.append $x (List.append3 $y $z $w)))
(: List.append5 (-> (List $a) (List $a) (List $a) (List $a) (List $a) (List $a)))
(= (List.append5 $x $y $z $w $s) (List.append $x (List.append4 $y $z $w $s)))

;; Define List.map (produce a new list by applying unary function to
;; all elements of a list).
(: List.map (-> (-> $a $b) (List $a) (List $b)))
(= (List.map $f Nil) Nil)
(= (List.map $f (Cons $head $tail)) (Cons ($f $head) (List.map $f $tail)))

;; Insert an element to a presumably sorted list according to a given
;; order (less than).  The result remains sorted.
(: List.insertWith (-> (-> $a $a Bool) $a (List $a) (List $a)))
(= (List.insertWith $lt $x Nil) (Cons $x Nil))
(= (List.insertWith $lt $x (Cons $head $tail))
   (if ($lt $x $head)
       (Cons $x (Cons $head $tail))
       (Cons $head (List.insertWith $lt $x $tail))))

;; Sort a list according to a given a less than order.
(: List.sortWith (-> (-> $a $a Bool) (List $a) (List $a)))
(= (List.sortWith $lt Nil) Nil)
(= (List.sortWith $lt (Cons $head $tail))
   (List.insertWith $lt $head (List.sortWith $lt $tail)))

;; Test sortWith
!(assertEqual
  (List.sortWith termLengthLT Nil)
  Nil)
!(assertEqual
  (List.sortWith termLengthLT (Cons A Nil))
  (Cons A Nil))
!(assertEqual
  (List.sortWith termLengthLT (Cons (A B) (Cons A Nil)))
  (Cons A (Cons (A B) Nil)))
!(assertEqual
  (List.sortWith termLengthLT (Cons (A B) (Cons A (Cons (A B (C D)) (Cons () Nil)))))
  (Cons () (Cons A (Cons (A B) (Cons (A B (C D)) Nil)))))

;; Returns the pre predix of a list of a given length.
(: List.take (-> Number (List $a) (List $a)))
(= (List.take $n Nil) Nil)
(= (List.take $n (Cons $head $tail)) (if (< 0 $n)
                                         (Cons $head (List.take (- $n 1) $tail))
                                         Nil))

;; Test List.take
!(assertEqual
  (List.take 2 (Cons A (Cons B (Cons C Nil))))
  (Cons A (Cons B Nil)))

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

;; Concatenate two strings (implemented in my own branch)
(: String.append (-> String String String))
(= (String.append $x $y) (call-fn! string_concat $x $y)) ; Only MeTTaLog
;; (= (String.append $x $y) ((py-dot $x __add__ (-> String String String)) $y))
;; (= (String.append $x $y) (charsToString (append (stringToChars $x) (stringToChars $y))))

;; Test String.append
!(assertEqual (String.append "abc" "def") "abcdef")
!(assertEqual (String.append "\"" "\"") "\"\"")

;; Overload String.append to support more than 2 arguments
(: String.append3 (-> String String String String))
(= (String.append3 $x $y $z) (String.append $x (String.append $y $z)))
(: String.append4 (-> String String String String String))
(= (String.append4 $x $y $z $w) (String.append $x (String.append3 $y $z $w)))
(: String.append5 (-> String String String String String String))
(= (String.append5 $x $y $z $w $s) (String.append $x (String.append4 $y $z $w $s)))

;; Join a list of string by a separator
(: String.join (-> String (List String) String))
(= (String.join $separator Nil) "")
(= (String.join $separator (Cons $head $tail))
   (case $tail
     ((Nil $head)
      ($else (String.append3 $head $separator (String.join $separator $tail))))))

;; Test String.join
!(assertEqual (String.join ", " (Cons "x=42" (Cons "y=24" Nil))) "x=42, y=24")

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
(: DOT.Shape.None DOT.Shape)
(: DOT.Shape.Parallelogram DOT.Shape)

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
(= (DOT.Attribute.style $style)
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

;; Constructors.  The Symbol based identifier constructor takes an
;; extra index argument to be treated as unique in the flowchart where
;; it appears (because if it appears with different arguments it is
;; should be treated as different).  The Grounded based identifier
;; constructor does not need such extra index because it used for
;; constants only, which should be unique since they take no argument.
(: DOT.MkSymbolIdentifier (-> Symbol Number DOT.Identifier))
(: DOT.MkGroundedIdentifier (-> Grounded DOT.Identifier))

;; DOT node
(: DOT.Node Type)

;; Constructor
(: DOT.MkNode (-> DOT.Identifier        ; Identifier
                  (List DOT.Attribute)  ; Attributes
                  DOT.Node))

;; Access functions
(: DOT.Node.identifier (-> DOT.Node DOT.Identifier))
(= (DOT.Node.identifier (DOT.MkNode $identifier $attributes)) $identifier)

(: DOT.Node.attributes (-> DOT.Node (List DOT.Attribute)))
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
(= (DOT.Edge.attributes (DOT.MkEdge $source $destination $attributes)) $attributes)

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
         (DOT.MkNode (DOT.MkSymbolIdentifier mix 0)
                     (Cons (DOT.MkShapeAttribute DOT.Shape.Box) Nil))
         (DOT.MkNode (DOT.MkSymbolIdentifier mix 0)
                     (Cons (DOT.MkShapeAttribute DOT.Shape.Box) Nil))
         (Cons (DOT.MkRankdirAttribute DOT.Rankdir.BT) Nil))
  (MkDOT Nil
         Nil
         (DOT.MkNode (DOT.MkSymbolIdentifier mix 0)
                     (Cons (DOT.MkShapeAttribute DOT.Shape.Box) Nil))
         (DOT.MkNode (DOT.MkSymbolIdentifier mix 0)
                     (Cons (DOT.MkShapeAttribute DOT.Shape.Box) Nil))
         (Cons (DOT.MkRankdirAttribute DOT.Rankdir.BT) Nil)))

;; Return the default attributes of a DOT file
(: globalAttributes (-> (List DOT.Attribute)))
(= (globalAttributes) (Cons (DOT.MkRankdirAttribute DOT.Rankdir.BT) Nil))

;; Return the default attributes of a node representing a function
(: functionAttributes (-> (List DOT.Attribute)))
(= (functionAttributes) (Cons (DOT.MkShapeAttribute DOT.Shape.Box) Nil))

;; Return the default attributes of a node representing a constant
(: constantAttributes (-> (List DOT.Attribute)))
(= (constantAttributes) (Cons (DOT.MkShapeAttribute DOT.Shape.Box)
                              (Cons (DOT.MkStyleAttribute DOT.Style.Rounded)
                                    Nil)))

;; Return the default attributes of a none node, typically used as
;; input and output
(: noneAttributes (-> (List DOT.Attribute)))
(= (noneAttributes)
   (Cons (DOT.MkLabelAttribute "\"\"")
         (Cons (DOT.MkShapeAttribute DOT.Shape.None)
               Nil)))

;; Return the default attibutes of the input node
(: inputAttributes (-> (List DOT.Attribute)))
(= (inputAttributes) (Cons (DOT.MkLabelAttribute "In")
                           (Cons (DOT.MkShapeAttribute DOT.Shape.Parallelogram)
                                 Nil)))

;; Return the default attibutes of the output node
(: outputAttributes (-> (List DOT.Attribute)))
(= (outputAttributes) (Cons (DOT.MkLabelAttribute "Out")
                            (Cons (DOT.MkShapeAttribute DOT.Shape.Parallelogram)
                                  Nil)))

;; Build default input node
(: inputNode (-> DOT.Node))
(= (inputNode)
   (DOT.MkNode (DOT.MkSymbolIdentifier __IN__ 0) (noneAttributes)))

;; Build default output node
(: outputNode (-> DOT.Node))
(= (outputNode)
   (DOT.MkNode (DOT.MkSymbolIdentifier __OUT__ 0) (noneAttributes)))

;; Return the default attributes of a node representing a phoenix
(: phoenixAttributes (-> (List DOT.Attribute)))
(= (phoenixAttributes) (Cons (DOT.MkLabelAttribute "\"Φ\"")
                             (Cons (DOT.MkShapeAttribute DOT.Shape.Plain) Nil)))


;; Return the default attributes of an edge providing the term to use
;; as edge label.  Typically that term may represent a type.
(: edgeAttributes (-> Atom (List DOT.Attribute)))
(= (edgeAttributes $term)
   (Cons (DOT.MkLabelAttribute (let $rt (repr $term) (repr $rt))) Nil))

;; Build the DOT data structure corresponding to a given term.  That
;; function is crafted around the assumption that the input term is an
;; AI service composition, which, from overall standpoint, corresponds
;; to a unary function.
(: toDOT (-> Atom DOT))
(= (toDOT $term)
   (let* (;; Construct external input and output nodes
          ($ext_in (inputNode))
          ($ext_out (outputNode))
          ;; Call toDOT_ on term, with external input and output nodes
          ((MkDOT $nodes $edges $entry $exit $attributes)
           (toDOT_ (Just $ext_in) (Just $ext_out) $term))
          ;; Add external nodes to node collection
          ($νnodes (Cons $ext_in (Cons $ext_out $nodes))))
          ;; Return genereated DOT data plus hardcoded global
          ;; attributes
     (MkDOT $νnodes
            $edges
            $ext_in
            $ext_out
            (List.append (globalAttributes) $attributes))))

;; Make empty DOT data structure
(: mkEmptyDOT (-> DOT))
(= (mkEmptyDOT)
   (MkDOT Nil Nil (MkGroundedIdentifier "") (MkGroundedIdentifier "") Nil))

;; Output the string representing the label corresponding to an
;; identifier in DOT format
(: DOT.Identifier.toLabelString (-> DOT.Identifier String))
(= (DOT.Identifier.toLabelString (DOT.MkSymbolIdentifier $symbol $index))
   (let $sr (repr $symbol) (repr $sr)))
(= (DOT.Identifier.toLabelString (DOT.MkGroundedIdentifier $grounded))
   (let $gr (repr $grounded) (repr $gr)))

;; Output the label attribute corresponding to an identifier
(: DOT.Identifier.toLabelAttribute (-> DOT.Identifier DOT.Attribute))
(= (DOT.Identifier.toLabelAttribute $identifier)
   (DOT.MkLabelAttribute (DOT.Identifier.toLabelString $identifier)))

;; Test DOT.Identifier.toLabelAttribute
!(assertEqual
  (DOT.Identifier.toLabelAttribute (DOT.MkSymbolIdentifier mix 0))
  (DOT.MkLabelAttribute "\"mix\""))
!(assertEqual
  (DOT.Identifier.toLabelAttribute (DOT.MkGroundedIdentifier 42))
  (DOT.MkLabelAttribute "\"42\""))
!(assertEqual
  (DOT.Identifier.toLabelAttribute (DOT.MkGroundedIdentifier "Hello World!"))
  (DOT.MkLabelAttribute "\"\\\"Hello World!\\\"\""))

;; Randomly sample an index, to be (almost) sure that every node has a
;; unique ID.
(: random-index (-> Number))
(= (random-index) (random-int &rng 0 1000000))

;; Test random-index
!(set-random-seed &rng 0)
!(assertEqual
  (random-index)
  823576)

;; Create edges between optionally provided entry and exit nodes and
;; internal entry and exit nodes
(: externalToInteralEdges (-> (Maybe DOT.Node)      ; Optional external entry node
                              (Maybe DOT.Node)      ; Optional external exit node
                              Atom                  ; Internal entry node
                              Atom                  ; Internal exit node
                              (List DOT.Attribute)  ; Attributes of entry edge
                              (List DOT.Attribute)  ; Attributes of exit edge
                              (List DOT.Edge)))
(= (externalToInteralEdges (Just $ext_entry)
                           (Just $ext_exit)
                           $int_entry
                           $int_exit
                           $entry_attrs
                           $exit_attrs)
   (Cons (DOT.MkEdge $ext_entry $int_entry $entry_attrs)
         (Cons (DOT.MkEdge $int_exit $ext_exit $exit_attrs)
               Nil)))
(= (externalToInteralEdges (Just $ext_entry)
                           Nothing
                           $int_entry
                           $int_exit
                           $entry_attrs
                           $exit_attrs)
   (Cons (DOT.MkEdge $ext_entry $int_entry $entry_attrs)
         Nil))
(= (externalToInteralEdges Nothing
                           (Just $ext_exit)
                           $int_entry
                           $int_exit
                           $entry_attrs
                           $exit_attrs)
   (Cons (DOT.MkEdge $int_exit $ext_exit $exit_attrs)
         Nil))
(= (externalToInteralEdges Nothing
                           Nothing
                           $int_entry
                           $int_exit
                           $entry_attrs
                           $exit_attrs)
    Nil)

;; Like toDOT but it is the recursive definition, not the entry point.
;; It also adds two extra arguments, optional entry and exit nodes
;; external the graph to be produced.  The returned graph will
;; possibly contain links between the external nodes, if these are
;; provided, and the internal entry and exit nodes of the given term.
;; It will not contain the external nodes, these will need to be added
;; by the called if needed.
;;
;; TODO: it should actually take a list of entry nodes, corresponding
;; to the arity of the function corresponding to the term.  But to
;; determine that arity we need the type.
(: toDOT_ (-> (Maybe DOT.Node)          ; Optional external entry node
              (Maybe DOT.Node)          ; Optional external exit node
              Atom                      ; Term to convert to DOT
              DOT))
(= (toDOT_ $ext_entry $ext_exit $term)
   (case (get-metatype $term)
     (;; Base cases
      (Symbol
       (let* (($id (DOT.MkSymbolIdentifier $term (random-index)))
              ($attrs (Cons (DOT.Identifier.toLabelAttribute $id)
                            (functionAttributes)))
              ($node (DOT.MkNode $id $attrs))
              ($nodes (Cons $node Nil))
              ($edges (externalToInteralEdges $ext_entry
                                              $ext_exit
                                              $node
                                              $node
                                              Nil
                                              Nil)))
         (MkDOT $nodes $edges $node $node Nil)))
      (Grounded
       (let* (($id (if (== $term coerce) ; We need to add this
                                         ; conditional because
                                         ; MeTTaLog types coerce as
                                         ; Grounded instead of Symbol
                       (DOT.MkSymbolIdentifier $term (random-index))
                       (DOT.MkGroundedIdentifier $term)))
              ($attrs (Cons (DOT.Identifier.toLabelAttribute $id)
                            (if (== $term coerce) ; We need to add
                                                  ; this conditional
                                                  ; because MeTTaLog
                                                  ; types coerce as
                                                  ; Grounded instead
                                                  ; of Symbol
                                (functionAttributes)
                                (constantAttributes))))
              ($node (DOT.MkNode $id $attrs))
              ($nodes (Cons $node Nil))
              ($edges (externalToInteralEdges $ext_entry
                                              $ext_exit
                                              $node
                                              $node
                                              Nil
                                              Nil)))
         (MkDOT $nodes $edges $node $node Nil)))
      ;; NEXT: support variables
      ;; (Variable
      ;;  (let* (($id (DOT.MkGroundedIdentifier $term))
      ;;         ($attrs (Cons (DOT.Identifier.toLabelAttribute $id)
      ;;                       (variableAttributes)))
      ;;         ($node (DOT.MkNode $id $attrs)))
      ;;    (MkDOT (Cons $node Nil) Nil $node $node Nil)))
      ;; Recursive step
      (Expression
       (case $term
         (;; Base case
          ;; Empty expression
          (() (mkEmptyDOT))
          ;; Recursive steps
          ;; Type annotation
          ((: $f $ty)
           (let
               ;; Recursive call on $f.  Do not pass external nodes as
               ;; arguments of toDOT_ as they are treated further below.
               (MkDOT $fnodes $fedges $fentry $fexit $fattrs)
               (toDOT_ Nothing Nothing $f)
             (case (get-metatype $ty)
               ((Expression
                 (case $ty
                   (;; Unary arrow type
                    ((-> $inty $outy)
                     (let* (;; Convert input and output types to edge attributes
                            ;; TODO: if $ext_entry is a phoenix, then
                            ;; do not add $inty as label
                            ($inty_attr (edgeAttributes $inty))
                            ($outy_attr (edgeAttributes $outy))
                            ;; Create edges between external and internal nodes
                            ($ext_edges (externalToInteralEdges $ext_entry
                                                                $ext_exit
                                                                $fentry
                                                                $fexit
                                                                $inty_attr
                                                                $outy_attr))
                            ;; Append external and internal edges
                            ($edges (List.append $ext_edges $fedges)))
                       ;; Return DOT object.  The entry and exit nodes
                       ;; are still those of $f, replacing them by the
                       ;; external nodes is up to the caller.
                       (MkDOT $fnodes $edges $fentry $fexit $fattrs)))
                    ;; Binary arrow type
                    ((-> $inty1 $inty2 $outy)
                     (let* (;; Convert output type to edge attributes
                            ($outy_attr (edgeAttributes $outy))
                            ;; Create edge from internal to extern exit
                            ;; nodes.  The external entry nodes are
                            ;; ignored because toDOT does not generally
                            ;; support nary arity functions, only those
                            ;; used inside a phoenix, and for that it
                            ;; will never be given the entry nodes
                            ;; anyway.
                            ($ext_edges (externalToInteralEdges Nothing
                                                                $ext_exit
                                                                $fentry
                                                                $fexit
                                                                Nil
                                                                $outy_attr))
                            ;; Concatenate external and internal edges
                            ($edges (List.append $ext_edges $fedges)))
                       ;; Return DOT object.  The entry and exit nodes
                       ;; are still those of $f, replacing them by the
                       ;; external nodes is up to the caller.
                       (MkDOT $fnodes $edges $fentry $fexit $fattrs)))
                    ;; TODO: support nary arrow types
                    ;; Non-arrow type
                    ($else
                     (let* (;; Convert type to output edge attributes
                            ($ty_attr (edgeAttributes $ty))
                            ;; Create edge from internal exit to
                            ;; external exit nodes.
                            ($ext_edges (externalToInteralEdges Nothing
                                                                $ext_exit
                                                                $fentry
                                                                $fexit
                                                                Nil
                                                                $ty_attr))
                            ;; Append external and internal edges
                            ($edges (List.append $ext_edges $fedges)))
                       ;; Return DOT object.  The entry and exit nodes
                       ;; are still those of $f, replacing them by the
                       ;; external nodes is up to the caller.
                       (MkDOT $fnodes $edges $fentry $fexit $fattrs))))))
                ($else       ; Symbol, Grounded, Variable
                 (let* (;; Convert type to output edge attributes
                        ($ty_attr (edgeAttributes $ty))
                        ;; Create edge from internal exit to
                        ;; external exit nodes.
                        ($ext_edges (externalToInteralEdges Nothing
                                                            $ext_exit
                                                            $fentry
                                                            $fexit
                                                            Nil
                                                            $ty_attr))
                        ;; Append external and internal edges
                        ($edges (List.append $ext_edges $fedges)))
                   ;; Return DOT object.  The entry and exit nodes
                   ;; are still those of $f, replacing them by the
                   ;; external nodes is up to the caller.
                   (MkDOT $fnodes $edges $fentry $fexit $fattrs)))))))
          ;; Bluebird
          ((. $f $g) (let* (;; Recursive call on $g, passing the
                            ;; external entry node.
                            ((MkDOT $gnodes $gedges $gentry $gexit $gattrs)
                             (toDOT_ $ext_entry Nothing $g))
                            ;; Recursive call on $f, passing both the
                            ;; exit node of g and the external exit node.
                            ((MkDOT $fnodes $fedges $fentry $fexit $fattrs)
                             (toDOT_ (Just $gexit) $ext_exit $f))
                            ;; Concatenate nodes of $f and $g
                            ($nodes (List.append $fnodes $gnodes))
                            ;; Concatenate edges of $f and $g and in between
                            ($edges (List.append $fedges $gedges))
                            ;; Concatenate attributes of $f and $g
                            ($attrs (List.append $fattrs $gattrs)))
                       (MkDOT $nodes $edges $gentry $fexit $attrs)))
          ;; Phoenix
          ((Φ $f $g $h) (let* (;; Recursive call on $f, passing the
                               ;; external exit node
                               ((MkDOT $fnodes $fedges $fentry $fexit $fattrs)
                                (toDOT_ Nothing $ext_exit $f))
                               ;; Create phoenix node
                               ($Φid (DOT.MkSymbolIdentifier Φ (random-index)))
                               ($Φ (DOT.MkNode $Φid (phoenixAttributes)))
                               ;; Create edge from external entry to $Φ
                               ($ext_edges (externalToInteralEdges $ext_entry
                                                                   Nothing
                                                                   $Φ
                                                                   $Φ
                                                                   Nil
                                                                   Nil))
                               ;; Recursive call on $g, passing both
                               ;; the internal entry node of $f and $Φ
                               ((MkDOT $gnodes $gedges $gentry $gexit $gattrs)
                                (toDOT_ (Just $Φ) (Just $fentry) $g))
                               ;; Recursive call on $h, passing both
                               ;; the internal entry node of $f and $Φ
                               ((MkDOT $hnodes $hedges $hentry $hexit $hattrs)
                                (toDOT_ (Just $Φ) (Just $fentry) $h))
                               ;; Concatenate all nodes
                               ($nodes (Cons $Φ
                                             (List.append3 $fnodes $gnodes $hnodes)))
                               ;; Concatenate all edges
                               ($edges (List.append4 $ext_edges
                                                     $fedges
                                                     $gedges
                                                     $hedges))
                               ;; Concatenate all attributes
                               ($attrs (List.append3 $fattrs $gattrs $hattrs)))
                          (MkDOT $nodes $edges $Φ $fexit $attrs)))
          ;; Unary application
          (($f $x) (let* (;; Recursive call on $f
                          ((MkDOT $fnodes $fedges $fentry $fexit $fattrs)
                           (toDOT_ $ext_entry $ext_exit $f))
                          ;; Recusive call on $x, passing $fentry as
                          ;; external exit node.  We assume that $x is
                          ;; non-arrow typed.
                          ((MkDOT $xnodes $xedges $xentry $xexit $xattrs)
                           (toDOT_ Nothing (Just $fentry) $x))
                          ;; Append all nodes
                          ($nodes (List.append $fnodes $xnodes))
                          ;; Append all edges
                          ($edges (List.append $fedges $xedges))
                          ;; Append all attributes
                          ($attrs (List.append $fattrs $xattrs)))
                     (MkDOT $nodes $edges $fentry $fexit $attrs)))
          ;; Binary application
          (($f $x $y) (let* (;; Recursive call on $f
                             ((MkDOT $fnodes $fedges $fentry $fexit $fattrs)
                              (toDOT_ $ext_entry $ext_exit $f))
                             ;; Recusive call on $x, passing $fentry
                             ;; as external exit node.  We assume that
                             ;; $x is non-arrow typed.
                             ((MkDOT $xnodes $xedges $xentry $xexit $xattrs)
                              (toDOT_ Nothing (Just $fentry) $x))
                             ;; Recusive call on $y, passing $fentry
                             ;; as external exit node.  We assume that
                             ;; $y is non-arrow typed.
                             ((MkDOT $ynodes $yedges $yentry $yexit $yattrs)
                              (toDOT_ Nothing (Just $fentry) $y))
                             ;; Append all nodes
                             ($nodes (List.append3 $fnodes $xnodes $ynodes))
                             ;; Append all edges
                             ($edges (List.append3 $fedges $xedges $yedges))
                             ;; Append all attributes
                             ($attrs (List.append3 $fattrs $xattrs $yattrs)))
                        (MkDOT $nodes $edges $fentry $fexit $attrs)))
          ;; Trinary application (TODO)
          (($f $x $y $z) (mkEmptyDOT))
          ;; Otherwise
          ($else (mkEmptyDOT)))))
      ;; Otherwise
      ($else (mkEmptyDOT)))))

;; Test toDOT
!(set-random-seed &rng 0)
!(assertEqual
  (toDOT mix)
  ;; ;; Using HE random generator
  ;; (MkDOT (Cons (DOT.MkNode (DOT.MkSymbolIdentifier __IN__ 0) (Cons (DOT.MkLabelAttribute "\"\"") (Cons (DOT.MkShapeAttribute DOT.Shape.None) Nil))) (Cons (DOT.MkNode (DOT.MkSymbolIdentifier __OUT__ 0) (Cons (DOT.MkLabelAttribute "\"\"") (Cons (DOT.MkShapeAttribute DOT.Shape.None) Nil))) (Cons (DOT.MkNode (DOT.MkSymbolIdentifier mix 731113) (Cons (DOT.MkLabelAttribute "\"mix\"") (Cons (DOT.MkShapeAttribute DOT.Shape.Box) Nil))) Nil))) (Cons (DOT.MkEdge (DOT.MkNode (DOT.MkSymbolIdentifier __IN__ 0) (Cons (DOT.MkLabelAttribute "\"\"") (Cons (DOT.MkShapeAttribute DOT.Shape.None) Nil))) (DOT.MkNode (DOT.MkSymbolIdentifier mix 731113) (Cons (DOT.MkLabelAttribute "\"mix\"") (Cons (DOT.MkShapeAttribute DOT.Shape.Box) Nil))) Nil) (Cons (DOT.MkEdge (DOT.MkNode (DOT.MkSymbolIdentifier mix 731113) (Cons (DOT.MkLabelAttribute "\"mix\"") (Cons (DOT.MkShapeAttribute DOT.Shape.Box) Nil))) (DOT.MkNode (DOT.MkSymbolIdentifier __OUT__ 0) (Cons (DOT.MkLabelAttribute "\"\"") (Cons (DOT.MkShapeAttribute DOT.Shape.None) Nil))) Nil) Nil)) (DOT.MkNode (DOT.MkSymbolIdentifier __IN__ 0) (Cons (DOT.MkLabelAttribute "\"\"") (Cons (DOT.MkShapeAttribute DOT.Shape.None) Nil))) (DOT.MkNode (DOT.MkSymbolIdentifier __OUT__ 0) (Cons (DOT.MkLabelAttribute "\"\"") (Cons (DOT.MkShapeAttribute DOT.Shape.None) Nil))) (Cons (DOT.MkRankdirAttribute DOT.Rankdir.BT) Nil)))
  ;; Using MeTTaLog random generator
  (MkDOT (Cons (DOT.MkNode (DOT.MkSymbolIdentifier __IN__ 0) (Cons (DOT.MkLabelAttribute "\"\"") (Cons (DOT.MkShapeAttribute DOT.Shape.None) Nil))) (Cons (DOT.MkNode (DOT.MkSymbolIdentifier __OUT__ 0) (Cons (DOT.MkLabelAttribute "\"\"") (Cons (DOT.MkShapeAttribute DOT.Shape.None) Nil))) (Cons (DOT.MkNode (DOT.MkSymbolIdentifier mix 823576) (Cons (DOT.MkLabelAttribute "\"mix\"") (Cons (DOT.MkShapeAttribute DOT.Shape.Box) Nil))) Nil))) (Cons (DOT.MkEdge (DOT.MkNode (DOT.MkSymbolIdentifier __IN__ 0) (Cons (DOT.MkLabelAttribute "\"\"") (Cons (DOT.MkShapeAttribute DOT.Shape.None) Nil))) (DOT.MkNode (DOT.MkSymbolIdentifier mix 823576) (Cons (DOT.MkLabelAttribute "\"mix\"") (Cons (DOT.MkShapeAttribute DOT.Shape.Box) Nil))) Nil) (Cons (DOT.MkEdge (DOT.MkNode (DOT.MkSymbolIdentifier mix 823576) (Cons (DOT.MkLabelAttribute "\"mix\"") (Cons (DOT.MkShapeAttribute DOT.Shape.Box) Nil))) (DOT.MkNode (DOT.MkSymbolIdentifier __OUT__ 0) (Cons (DOT.MkLabelAttribute "\"\"") (Cons (DOT.MkShapeAttribute DOT.Shape.None) Nil))) Nil) Nil)) (DOT.MkNode (DOT.MkSymbolIdentifier __IN__ 0) (Cons (DOT.MkLabelAttribute "\"\"") (Cons (DOT.MkShapeAttribute DOT.Shape.None) Nil))) (DOT.MkNode (DOT.MkSymbolIdentifier __OUT__ 0) (Cons (DOT.MkLabelAttribute "\"\"") (Cons (DOT.MkShapeAttribute DOT.Shape.None) Nil))) (Cons (DOT.MkRankdirAttribute DOT.Rankdir.BT) Nil)))
!(set-random-seed &rng 0)
!(assertEqual
  (toDOT (: f (-> A B)))
  ;; ;; Using HE random generator
  ;; (MkDOT (Cons (DOT.MkNode (DOT.MkSymbolIdentifier __IN__ 0) (Cons (DOT.MkLabelAttribute "\"\"") (Cons (DOT.MkShapeAttribute DOT.Shape.None) Nil))) (Cons (DOT.MkNode (DOT.MkSymbolIdentifier __OUT__ 0) (Cons (DOT.MkLabelAttribute "\"\"") (Cons (DOT.MkShapeAttribute DOT.Shape.None) Nil))) (Cons (DOT.MkNode (DOT.MkSymbolIdentifier f 731113) (Cons (DOT.MkLabelAttribute "\"f\"") (Cons (DOT.MkShapeAttribute DOT.Shape.Box) Nil))) Nil))) (Cons (DOT.MkEdge (DOT.MkNode (DOT.MkSymbolIdentifier __IN__ 0) (Cons (DOT.MkLabelAttribute "\"\"") (Cons (DOT.MkShapeAttribute DOT.Shape.None) Nil))) (DOT.MkNode (DOT.MkSymbolIdentifier f 731113) (Cons (DOT.MkLabelAttribute "\"f\"") (Cons (DOT.MkShapeAttribute DOT.Shape.Box) Nil))) (Cons (DOT.MkLabelAttribute "\"A\"") Nil)) (Cons (DOT.MkEdge (DOT.MkNode (DOT.MkSymbolIdentifier f 731113) (Cons (DOT.MkLabelAttribute "\"f\"") (Cons (DOT.MkShapeAttribute DOT.Shape.Box) Nil))) (DOT.MkNode (DOT.MkSymbolIdentifier __OUT__ 0) (Cons (DOT.MkLabelAttribute "\"\"") (Cons (DOT.MkShapeAttribute DOT.Shape.None) Nil))) (Cons (DOT.MkLabelAttribute "\"B\"") Nil)) Nil)) (DOT.MkNode (DOT.MkSymbolIdentifier __IN__ 0) (Cons (DOT.MkLabelAttribute "\"\"") (Cons (DOT.MkShapeAttribute DOT.Shape.None) Nil))) (DOT.MkNode (DOT.MkSymbolIdentifier __OUT__ 0) (Cons (DOT.MkLabelAttribute "\"\"") (Cons (DOT.MkShapeAttribute DOT.Shape.None) Nil))) (Cons (DOT.MkRankdirAttribute DOT.Rankdir.BT) Nil)))
  ;; Using MeTTaLog random generator
  (MkDOT (Cons (DOT.MkNode (DOT.MkSymbolIdentifier __IN__ 0) (Cons (DOT.MkLabelAttribute "\"\"") (Cons (DOT.MkShapeAttribute DOT.Shape.None) Nil))) (Cons (DOT.MkNode (DOT.MkSymbolIdentifier __OUT__ 0) (Cons (DOT.MkLabelAttribute "\"\"") (Cons (DOT.MkShapeAttribute DOT.Shape.None) Nil))) (Cons (DOT.MkNode (DOT.MkSymbolIdentifier f 823576) (Cons (DOT.MkLabelAttribute "\"f\"") (Cons (DOT.MkShapeAttribute DOT.Shape.Box) Nil))) Nil))) (Cons (DOT.MkEdge (DOT.MkNode (DOT.MkSymbolIdentifier __IN__ 0) (Cons (DOT.MkLabelAttribute "\"\"") (Cons (DOT.MkShapeAttribute DOT.Shape.None) Nil))) (DOT.MkNode (DOT.MkSymbolIdentifier f 823576) (Cons (DOT.MkLabelAttribute "\"f\"") (Cons (DOT.MkShapeAttribute DOT.Shape.Box) Nil))) (Cons (DOT.MkLabelAttribute "\"A\"") Nil)) (Cons (DOT.MkEdge (DOT.MkNode (DOT.MkSymbolIdentifier f 823576) (Cons (DOT.MkLabelAttribute "\"f\"") (Cons (DOT.MkShapeAttribute DOT.Shape.Box) Nil))) (DOT.MkNode (DOT.MkSymbolIdentifier __OUT__ 0) (Cons (DOT.MkLabelAttribute "\"\"") (Cons (DOT.MkShapeAttribute DOT.Shape.None) Nil))) (Cons (DOT.MkLabelAttribute "\"B\"") Nil)) Nil)) (DOT.MkNode (DOT.MkSymbolIdentifier __IN__ 0) (Cons (DOT.MkLabelAttribute "\"\"") (Cons (DOT.MkShapeAttribute DOT.Shape.None) Nil))) (DOT.MkNode (DOT.MkSymbolIdentifier __OUT__ 0) (Cons (DOT.MkLabelAttribute "\"\"") (Cons (DOT.MkShapeAttribute DOT.Shape.None) Nil))) (Cons (DOT.MkRankdirAttribute DOT.Rankdir.BT) Nil)))
;; TODO: re-enable as needed  (don't forget to reset the random seed at every test)
;; !(toDOT (STTrans VA VIV))
;; !(toDOT (: (STTrans VA VIV) (<: (VocalsIn "English") Audio)))
;; !(toDOT (: (STTrans (: VA (<: Vocals Audio))
;;                     (: VIV (<: (VocalsIn "English") Vocals)))
;;            (<: (VocalsIn "English") Audio)))
;; !(toDOT (. upload speech-recognition.s2t))
;; !(toDOT (: (coerce (: (STTrans (: VA (<: Vocals Audio))
;;                                (: VIV (<: (VocalsIn "English") Vocals)))
;;                       (<: (VocalsIn "English") Audio)))
;;            (-> (: $x (VocalsIn "English")) Audio)))
;; !(toDOT (: (. (: speech-recognition.s2t (-> (: $y Audio) (TextIn "English")))
;;               (: (coerce (: (STTrans (: VA (<: Vocals Audio))
;;                                      (: VIV (<: (VocalsIn "English") Vocals)))
;;                             (<: (VocalsIn "English") Audio)))
;;                  (-> (: $x (VocalsIn "English")) Audio)))
;;            (-> (: $x (VocalsIn "English")) (TextIn "English"))))
;; !(toDOT (Φ f g h))
;; !(toDOT
;;   (: (Φ (: midi2voice-zh.singingZH
;;            (-> (: $y (TextIn "Chinese"))
;;                (: $z MusicalInstrumentDigitalInterface)
;;                (VocalsIn "Chinese")))
;;         g
;;         h)
;;      (-> (: $u Audio) (VocalsIn "Chinese"))))
;; !(toDOT
;;   (: (Φ (: f (-> B C D))
;;         (: g (-> A B))
;;         h)
;;      (-> (: $u Audio) (VocalsIn "Chinese"))))
;; !(toDOT
;;   (: (Φ (: midi2voice-zh.singingZH
;;            (-> (: $y (TextIn "Chinese"))
;;                (: $z MusicalInstrumentDigitalInterface)
;;                (VocalsIn "Chinese")))
;;         (: g (-> A B))
;;         h)
;;      (-> (: $u Audio) (VocalsIn "Chinese"))))
;; !(toDOT
;;   (: (Φ (: midi2voice-zh.singingZH
;;            (-> (: $y (TextIn "Chinese"))
;;                (: $z MusicalInstrumentDigitalInterface)
;;                (VocalsIn "Chinese")))
;;         g
;;         (: tomidi.a2m (-> (: $u Audio) MusicalInstrumentDigitalInterface)))
;;      (-> (: $u Audio) (VocalsIn "Chinese"))))
;; !(toDOT
;;   (: (Φ (: midi2voice-zh.singingZH
;;            (-> (: $y (TextIn "Chinese"))
;;                (: $z MusicalInstrumentDigitalInterface)
;;                (VocalsIn "Chinese")))
;;         (: g (-> A B))
;;         (: tomidi.a2m (-> (: $u Audio) MusicalInstrumentDigitalInterface)))
;;      (-> (: $u Audio) (VocalsIn "Chinese"))))
;; !(toDOT (machine-translation.translate "English" "Chinese"))
;; !(toDOT (machine-translation.translate (: "English" NaturalLanguage)
;;                                        (: "Chinese" NaturalLanguage)))
;; !(toDOT
;;   (: (machine-translation.translate
;;       (: "English" NaturalLanguage)
;;       (: "Chinese" NaturalLanguage))
;;      (-> (: $w (UniformResourceLocatorOfType (TextIn "English")))
;;          (TextIn "Chinese"))))
;; !(toDOT
;;   (: (. (: (machine-translation.translate
;;             (: "English" NaturalLanguage)
;;             (: "Chinese" NaturalLanguage))
;;            (-> (: $w (UniformResourceLocatorOfType (TextIn "English")))
;;                (TextIn "Chinese")))
;;         g)
;;      (-> (: $u Audio) (TextIn "Chinese"))))
;; !(toDOT
;;   (: (. (: (machine-translation.translate
;;             (: "English" NaturalLanguage)
;;             (: "Chinese" NaturalLanguage))
;;            (-> (: $w (UniformResourceLocatorOfType (TextIn "English")))
;;                (TextIn "Chinese")))
;;         (: (. (: upload
;;                  (-> (: $t (TextIn "English"))
;;                      (UniformResourceLocatorOfType (TextIn "English"))))
;;               (: speech-recognition.s2t
;;                  (-> (: $u Audio) (TextIn "English"))))
;;            (-> (: $u Audio)
;;                (UniformResourceLocatorOfType (TextIn "English")))))
;;      (-> (: $u Audio) (TextIn "Chinese"))))
;; !(toDOT
;;   (: (Φ f
;;         (: (. (: (machine-translation.translate
;;                   (: "English" NaturalLanguage)
;;                   (: "Chinese" NaturalLanguage))
;;                  (-> (: $w (UniformResourceLocatorOfType (TextIn "English")))
;;                      (TextIn "Chinese")))
;;               (: (. (: upload
;;                        (-> (: $t (TextIn "English"))
;;                            (UniformResourceLocatorOfType (TextIn "English"))))
;;                     (: speech-recognition.s2t
;;                        (-> (: $u Audio) (TextIn "English"))))
;;                  (-> (: $u Audio)
;;                      (UniformResourceLocatorOfType (TextIn "English")))))
;;            (-> (: $u Audio) (TextIn "Chinese")))
;;         h)
;;      (-> (: $u Audio) (VocalsIn "Chinese"))))
;; !(toDOT
;;   (: (Φ (: midi2voice-zh.singingZH
;;            (-> (: $y (TextIn "Chinese"))
;;                (: $z MusicalInstrumentDigitalInterface)
;;                (VocalsIn "Chinese")))
;;         (: (. (: (machine-translation.translate
;;                   (: "English" NaturalLanguage)
;;                   (: "Chinese" NaturalLanguage))
;;                  (-> (: $w (UniformResourceLocatorOfType (TextIn "English")))
;;                      (TextIn "Chinese")))
;;               (: (. (: upload
;;                        (-> (: $t (TextIn "English"))
;;                            (UniformResourceLocatorOfType (TextIn "English"))))
;;                     (: speech-recognition.s2t
;;                        (-> (: $u Audio) (TextIn "English"))))
;;                  (-> (: $u Audio)
;;                      (UniformResourceLocatorOfType (TextIn "English")))))
;;            (-> (: $u Audio) (TextIn "Chinese")))
;;         (: tomidi.a2m (-> (: $u Audio) MusicalInstrumentDigitalInterface)))
;;      (-> (: $u Audio) (VocalsIn "Chinese"))))
;; !(toDOT
;;   (: (. (: (Φ (: midi2voice-zh.singingZH
;;                  (-> (: $y (TextIn "Chinese"))
;;                      (: $z MusicalInstrumentDigitalInterface)
;;                      (VocalsIn "Chinese")))
;;               (: (. (: (machine-translation.translate
;;                         (: "English" NaturalLanguage)
;;                         (: "Chinese" NaturalLanguage))
;;                        (-> (: $w (UniformResourceLocatorOfType (TextIn "English")))
;;                            (TextIn "Chinese")))
;;                     (: (. (: upload
;;                              (-> (: $t (TextIn "English"))
;;                                  (UniformResourceLocatorOfType (TextIn "English"))))
;;                           (: speech-recognition.s2t
;;                              (-> (: $u Audio) (TextIn "English"))))
;;                        (-> (: $u Audio)
;;                            (UniformResourceLocatorOfType (TextIn "English")))))
;;                  (-> (: $u Audio) (TextIn "Chinese")))
;;               (: tomidi.a2m (-> (: $u Audio) MusicalInstrumentDigitalInterface)))
;;            (-> (: $u Audio) (VocalsIn "Chinese")))
;;         (: (coerce (: SIA (<: (SongIn $l) Audio)))
;;            (-> (: $x (SongIn $l)) Audio)))
;;      (-> (: $x (SongIn $l)) (VocalsIn "Chinese"))))
;; !(toDOT
;;   (: (. (: (Φ (: mixer.mix $a)
;;               (: sound-spleeter.DTLOutput.accomp $b)
;;               (: (. (: (Φ (: midi2voice-zh.singingZH $c)
;;                           (: (. (: (machine-translation.translate (: "English" $d)
;;                                                                   (: "Chinese" $e))
;;                                    $f)
;;                                 (: (. (: upload $g)
;;                                       (: speech-recognition.s2t $h))
;;                                    $i))
;;                              $j)
;;                           (: tomidi.a2m $k))
;;                        $l)
;;                     (: (. (: (coerce (: (STTrans (: VA $m) (: VIV $n)) $o))
;;                              $p)
;;                           (: sound-spleeter.DTLOutput.vocals $q))
;;                        $r))
;;                  $s))
;;            $t)
;;         (: sound-spleeter.spleeter $u))
;;      (-> (: $x (SongIn "English")) (SongIn "Chinese"))))

;; Output the string representing a style in DOT format
(: DOT.Style.toString (-> DOT.Style String))
(= (DOT.Style.toString DOT.Style.Rounded) "rounded")

;; Output the string representing a shape in DOT format
(: DOT.Shape.toString (-> DOT.Shape String))
(= (DOT.Shape.toString DOT.Shape.Plain) "plain")
(= (DOT.Shape.toString DOT.Shape.Box) "box")
(= (DOT.Shape.toString DOT.Shape.None) "none")
(= (DOT.Shape.toString DOT.Shape.Parallelogram) "parallelogram")

;; Output the string representing a rankdir in DOT format
(: DOT.Rankdir.toString (-> DOT.Rankdir String))
(= (DOT.Rankdir.toString DOT.Rankdir.BT) "BT")
(= (DOT.Rankdir.toString DOT.Rankdir.TB) "TB")
(= (DOT.Rankdir.toString DOT.Rankdir.LR) "LR")
(= (DOT.Rankdir.toString DOT.Rankdir.RL) "RL")

;; Output the string representing an attribute in DOT format
(: DOT.Attribute.toString (-> DOT.Attribute String))
(= (DOT.Attribute.toString (DOT.MkLabelAttribute $label))
   (String.append "label=" $label))
(= (DOT.Attribute.toString (DOT.MkStyleAttribute $style))
   (String.append "style=" (DOT.Style.toString $style)))
(= (DOT.Attribute.toString (DOT.MkShapeAttribute $shape))
   (String.append "shape=" (DOT.Shape.toString $shape)))
(= (DOT.Attribute.toString (DOT.MkRankdirAttribute $rankdir))
   (String.append "rankdir=" (DOT.Rankdir.toString $rankdir)))

;; test DOT.Attribute.toString
!(assertEqual
  (DOT.Attribute.toString (DOT.MkLabelAttribute "mix"))
  "label=mix")
!(assertEqual
  (DOT.Attribute.toString (DOT.MkStyleAttribute DOT.Style.Rounded))
  "style=rounded")
!(assertEqual
  (DOT.Attribute.toString (DOT.MkShapeAttribute DOT.Shape.Box))
  "shape=box")
!(assertEqual
  (DOT.Attribute.toString (DOT.MkRankdirAttribute DOT.Rankdir.BT))
  "rankdir=BT")

;; Output the string representing a list of attributes in DOT format
(: DOT.Attributes.toOneLinerString (-> (List DOT.Attribute) String))
(= (DOT.Attributes.toOneLinerString $attributes)
   (let $joined_attributes
       (String.join ", " (List.map DOT.Attribute.toString $attributes))
     (String.append3 "[" $joined_attributes "]")))

;; Test DOT.Attributes.toOneLinerString
!(assertEqual
  (DOT.Attributes.toOneLinerString
   (Cons (DOT.MkLabelAttribute "mix")
         (Cons (DOT.MkStyleAttribute DOT.Style.Rounded)
               (Cons (DOT.MkShapeAttribute DOT.Shape.Box) Nil))))
  "[label=mix, style=rounded, shape=box]")

;; Output the string representing an identifier in DOT format
(: DOT.Identifier.toString (-> DOT.Identifier String))
(= (DOT.Identifier.toString (DOT.MkSymbolIdentifier $symbol $index))
   (let $sir (String.append (repr $symbol) (repr $index)) (repr $sir)))
(= (DOT.Identifier.toString (DOT.MkGroundedIdentifier $grounded))
   (repr $grounded))

;; Test DOT.Identifier.toString
!(assertEqual
  (DOT.Identifier.toString (DOT.MkSymbolIdentifier mix 0))
  "\"mix0\"")
!(assertEqual
  (DOT.Identifier.toString (DOT.MkGroundedIdentifier "Hello World!"))
  "\"Hello World!\"")

;; Output the string representing a node in DOT format.
(: DOT.Node.toString (-> DOT.Node String))
(= (DOT.Node.toString (DOT.MkNode $identifier $attributes))
   (let* (($id_repr (DOT.Identifier.toString $identifier))
          ($attr_repr (DOT.Attributes.toOneLinerString $attributes)))
     (String.append3 $id_repr " " $attr_repr)))

;; Test DOT.Node.toString
!(assertEqual
  (DOT.Node.toString (DOT.MkNode (DOT.MkSymbolIdentifier mix 0) Nil))
  "\"mix0\" []")
!(assertEqual
  (DOT.Node.toString (DOT.MkNode (DOT.MkGroundedIdentifier "Hello World!") Nil))
  "\"Hello World!\" []")
!(assertEqual
  (DOT.Node.toString (DOT.MkNode (DOT.MkSymbolIdentifier mix 0)
                                 (Cons (DOT.MkShapeAttribute DOT.Shape.Box) Nil)))
  "\"mix0\" [shape=box]")

;; Output the string representing an edge in DOT format.
(: DOT.Edge.toString (-> DOT.Edge String))
(= (DOT.Edge.toString (DOT.MkEdge $source $destination $attributes))
   (let* (($src_repr (DOT.Identifier.toString (DOT.Node.identifier $source)))
          ($dst_repr (DOT.Identifier.toString (DOT.Node.identifier $destination)))
          ($edge_repr (String.append3 $src_repr " -> " $dst_repr))
          ($attrs_repr (DOT.Attributes.toOneLinerString $attributes)))
     (String.append3 $edge_repr " " $attrs_repr)))

;; Test DOT.Edge.toString
!(assertEqual
  (DOT.Edge.toString (DOT.MkEdge (DOT.MkNode (DOT.MkSymbolIdentifier src 0) Nil)
                                 (DOT.MkNode (DOT.MkSymbolIdentifier dst 0) Nil)
                                 Nil))
  "\"src0\" -> \"dst0\" []")

;; Takes a DOT data structure and outputs the corresponding string in
;; DOT format.
(: DOT.toString (-> DOT String))
(= (DOT.toString (MkDOT $nodes $edges $entry $exit $attrs))
   (let* (($nodes_repr (String.join "\n" (List.map DOT.Node.toString $nodes)))
          ($edges_repr (String.join "\n" (List.map DOT.Edge.toString $edges)))
          ($attrs_repr (String.join "\n" (List.map DOT.Attribute.toString $attrs)))
          ($nodes_repr_nl (String.append $nodes_repr "\n\n"))
          ($attrs_repr_nl (String.append $attrs_repr "\n\n")))
     (String.append5 "digraph Flowchart {\n"
                     $attrs_repr_nl $nodes_repr_nl $edges_repr "\n}")))

;; Test DOT.toString
!(set-random-seed &rng 0)
!(assertEqual
  (DOT.toString (toDOT mix))
  ;; ;; Using HE random generator
  ;; "digraph Flowchart {\nrankdir=BT\n\n\"__IN__0\" [label=\"\", shape=none]\n\"__OUT__0\" [label=\"\", shape=none]\n\"mix731113\" [label=\"mix\", shape=box]\n\n\"__IN__0\" -> \"mix731113\" []\n\"mix731113\" -> \"__OUT__0\" []\n}")
  ;; Using MeTTaLog random generator
  "digraph Flowchart {\nrankdir=BT\n\n\"__IN__0\" [label=\"\", shape=none]\n\"__OUT__0\" [label=\"\", shape=none]\n\"mix823576\" [label=\"mix\", shape=box]\n\n\"__IN__0\" -> \"mix823576\" []\n\"mix823576\" -> \"__OUT__0\" []\n}")
!(set-random-seed &rng 0)
!(assertEqual
  (DOT.toString (toDOT (. f g)))
  ;; ;; Using HE random generator
  ;; "digraph Flowchart {\nrankdir=BT\n\n\"__IN__0\" [label=\"\", shape=none]\n\"__OUT__0\" [label=\"\", shape=none]\n\"f773460\" [label=\"f\", shape=box]\n\"g731113\" [label=\"g\", shape=box]\n\n\"g731113\" -> \"f773460\" []\n\"f773460\" -> \"__OUT__0\" []\n\"__IN__0\" -> \"g731113\" []\n}")
  ;; Using MeTTaLog random generator
  "digraph Flowchart {\nrankdir=BT\n\n\"__IN__0\" [label=\"\", shape=none]\n\"__OUT__0\" [label=\"\", shape=none]\n\"f616257\" [label=\"f\", shape=box]\n\"g823576\" [label=\"g\", shape=box]\n\n\"g823576\" -> \"f616257\" []\n\"f616257\" -> \"__OUT__0\" []\n\"__IN__0\" -> \"g823576\" []\n}")
;; TODO: re-enable as needed (don't forget to reset the random seed at every test)
;; !(assertEqual
;;   (DOT.toString (toDOT (Φ f g h)))
;;   "digraph Flowchart {\nrankdir=BT\n\n\"Φ1000\" [label=\"Φ\", shape=plain]\n\"f1\" [label=\"f\", shape=box]\n\"g10\" [label=\"g\", shape=box]\n\"h100\" [label=\"h\", shape=box]\n\n\"Φ1000\" -> \"g10\" []\n\"Φ1000\" -> \"h100\" []\n\"g10\" -> \"f1\" []\n\"h100\" -> \"f1\" []\n}")
;; !(assertEqual
;;   (DOT.toString (toDOT (f "Hello World!")))
;;   "digraph Flowchart {\nrankdir=BT\n\n\"f1\" [label=\"f\", shape=box]\n\"Hello World!\" [label=\"\\\"Hello World!\\\"\", shape=box, style=rounded]\n\n\"Hello World!\" -> \"f1\" []\n}")
;; !(assertEqual
;;   (DOT.toString (toDOT (f "Hello" "World!")))
;;   "digraph Flowchart {\nrankdir=BT\n\n\"f1\" [label=\"f\", shape=box]\n\"Hello\" [label=\"\\\"Hello\\\"\", shape=box, style=rounded]\n\"World!\" [label=\"\\\"World!\\\"\", shape=box, style=rounded]\n\n\"Hello\" -> \"f1\" []\n\"World!\" -> \"f1\" []\n}")
;; !(assertEqual
;;   (DOT.toString (toDOT (: f (-> (: $x (SongIn "English")) (SongIn "Chinese")))))
;;   "digraph Flowchart {\nrankdir=BT\n\n\"__IN__0\" [label=\"\", shape=none]\n\"__OUT__0\" [label=\"\", shape=none]\n\"f1\" [label=\"f\", shape=box]\n\n\"__IN__0\" -> \"f1\" [label=\"(: $10000 (SongIn \\\"English\\\"))\"]\n\"f1\" -> \"__OUT__0\" [label=\"(SongIn \\\"Chinese\\\")\"]\n}")

;; Print a MeTTa term in DOT format
(= (DOT.println! $term)
   (println! (DOT.toString (toDOT $term))))

;; ;; Test DOT.println!
;; !(DOT.println! mix)
;; !(DOT.println! (: f (-> A B)))
;; !(DOT.println! (STTrans VA VIV))
;; !(DOT.println! (: (STTrans VA VIV) (<: (VocalsIn "English") Audio)))
;; !(DOT.println! (: (STTrans (: VA (<: Vocals Audio))
;;                            (: VIV (<: (VocalsIn "English") Vocals)))
;;                   (<: (VocalsIn "English") Audio)))
;; !(DOT.println! (. upload speech-recognition.s2t))
;; !(DOT.println! (: (coerce (: (STTrans (: VA (<: Vocals Audio))
;;                                       (: VIV (<: (VocalsIn "English") Vocals)))
;;                              (<: (VocalsIn "English") Audio)))
;;                   (-> (: $x (VocalsIn "English")) Audio)))
;; !(DOT.println! (: (. (: speech-recognition.s2t (-> (: $y Audio) (TextIn "English")))
;;                      (: (coerce (: (STTrans (: VA (<: Vocals Audio))
;;                                             (: VIV (<: (VocalsIn "English") Vocals)))
;;                                    (<: (VocalsIn "English") Audio)))
;;                         (-> (: $x (VocalsIn "English")) Audio)))
;;                   (-> (: $x (VocalsIn "English")) (TextIn "English"))))
;; !(DOT.println!
;;   (: (. (: upload (-> (: $y (TextIn "English"))
;;                       (UniformResourceLocatorOfType (TextIn "English"))))
;;         (: (. (: speech-recognition.s2t (-> (: $z Audio) (TextIn "English")))
;;               (: (coerce (: (STTrans (: VA (<: Vocals Audio))
;;                                      (: VIV (<: (VocalsIn "English") Vocals)))
;;                             (<: (VocalsIn "English") Audio)))
;;                  (-> (: $x (VocalsIn "English")) Audio)))
;;            (-> (: $x (VocalsIn "English")) (TextIn "English"))))
;;      (-> (: $x (VocalsIn "English"))
;;          (UniformResourceLocatorOfType (TextIn "English")))))
;; !(DOT.println! (Φ f g h))
;; !(DOT.println! (: (Φ f g h) (-> A D)))
;; !(DOT.println! (: (Φ (: f (-> B C D)) (: g (-> A B)) (: h (-> A C))) (-> A D)))
;; !(DOT.println!
;;   (: (. (: (Φ (: midi2voice-zh.singingZH
;;                  (-> (: $y (TextIn "Chinese"))
;;                      (: $z MusicalInstrumentDigitalInterface)
;;                      (VocalsIn "Chinese")))
;;               (: (. (: (machine-translation.translate
;;                         (: "English" NaturalLanguage)
;;                         (: "Chinese" NaturalLanguage))
;;                        (-> (: $w (UniformResourceLocatorOfType (TextIn "English")))
;;                            (TextIn "Chinese")))
;;                     (: (. (: upload
;;                              (-> (: $t (TextIn "English"))
;;                                  (UniformResourceLocatorOfType (TextIn "English"))))
;;                           (: speech-recognition.s2t
;;                              (-> (: $u Audio) (TextIn "English"))))
;;                        (-> (: $u Audio)
;;                            (UniformResourceLocatorOfType (TextIn "English")))))
;;                  (-> (: $u Audio) (TextIn "Chinese")))
;;               (: tomidi.a2m (-> (: $u Audio) MusicalInstrumentDigitalInterface)))
;;            (-> (: $u Audio) (VocalsIn "Chinese")))
;;         (: (coerce (: SIA (<: (SongIn $l) Audio)))
;;            (-> (: $x (SongIn $l)) Audio)))
;;      (-> (: $x (SongIn $l)) (VocalsIn "Chinese"))))

;;;;;;;;;;;;;
;; Uncurry ;;
;;;;;;;;;;;;;

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

;; Test uncurry
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

;; Check is a given type is a subtype of Data.  Use the backward
;; chainer for type checking but only allow a depth of 0 in order to
;; have maximum efficiency.
(: isData (-> Type Bool))
(= (isData $a)
   True)                                ; Disabled for now because it
                                        ; does not result in pruning,
                                        ; and only slows down for no
                                        ; reason.
   ;; (let (: $prf (<: $a Data)) (limit 1 (bc &kb Z (: $prf (<: $a Data))))
   ;;      (is-closed $prf)))

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

;; Recursive step for subtyping transitivity
(= (bc $kb (S $k) (: (STTrans $bc $ab) (<: $a $c)))
   (let* (;; Recurse on $bc
          ((: $bc (<: $b $c)) (bc $kb $k (: $bc (<: $b $c))))
          ;; Recurse on $ab
          ((: $ab (<: $a $b)) (bc $kb $k (: $ab (<: $a $b)))))
     ;; Make sure $a, $b and $c are subtypes of Data
     (when (and (isData $a) (and (isData $b) (isData $c)))
       (: (STTrans $bc $ab) (<: $a $c)))))

;; Recursive step for subtyping coercion.
(= (bc $kb (S $k) (: (coerce $ab) (-> (: $x $a) $b)))
   (let ;; Recurse on $ab
       (: $ab (<: $a $b)) (bc $kb $k (: $ab (<: $a $b)))
     ;; Make sure $a, $b and $c are subtypes of Data
     (when (and (isData $a) (isData $b))
       (: (coerce $ab) (-> (: $x $a) $b)))))

;; Recursive step: bluebird
(= (bc $kb (S $k) (: (. $f $g) (-> (: $x $a) $c)))
   (let* (;; Recurse on f
          ((: $f (-> (: $y $b) $c)) (bc $kb $k (: $f (-> (: $y $b) $c))))
          ;; Recurse on g
          ((: $g (-> (: $x $a) $b)) (bc $kb $k (: $g (-> (: $x $a) $b)))))
     ;; Make sure $a, $b and $c are subtypes of Data
     (when (and (isData $a) (and (isData $b) (isData $c)))
       (: (. $f $g) (-> (: $x $a) $c)))))

;; Recursive step: phoenix
(= (bc $kb (S $k) (: (Φ $f $g $h) (-> (: $x $a) $d)))
   (let* (;; Recurse on f
          ((: $f (-> (: $y $b) (: $z $c) $d))
           (bc $kb $k (: $f (-> (: $y $b) (: $z $c) $d))))
          ;; Recurse on g
          ((: $g (-> (: $x $a) $b)) (bc $kb $k (: $g (-> (: $x $a) $b))))
          ;; Recurse on h
          ((: $h (-> (: $x $a) $c)) (bc $kb $k (: $h (-> (: $x $a) $c)))))
     ;; Make sure $a, $b, $c and $d are subtypes of Data
     (when (and (isData $a) (and (isData $b) (and (isData $c) (isData $d))))
       (: (Φ $f $g $h) (-> (: $x $a) $d)))))

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Backward Chainer with Type Annotation ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Like bc but infer a fully type annotated program.  For instance
;; instead of inferring
;;
;; (: (ϕ f g h) (-> T1 T2))
;;
;; it will infer
;;
;; (: (ϕ (: f T3) (: g T4) (: h T5)) (-> T1 T2))
(: type-annotated-bc (-> $a                      ; Knowledge base space
                         Nat                     ; Maximum depth
                         $b                      ; Query
                         $b))                    ; Result

;; Base cases: match the knowledge base
(= (type-annotated-bc $kb $_ (: $prf $thrm))
   (match $kb (: $prf $thrm) (: $prf $thrm)))

;; Recursive step for subtyping transitivity
(= (type-annotated-bc $kb
                      (S $k)
                      (: (STTrans (: $bc (<: $b $c))
                                  (: $ab (<: $a $b)))
                         (<: $a $c)))
   (let* (;; Recurse on $bc
          ((: $bc (<: $b $c)) (type-annotated-bc $kb $k (: $bc (<: $b $c))))
          ;; Recurse on $ab
          ((: $ab (<: $a $b)) (type-annotated-bc $kb $k (: $ab (<: $a $b)))))
     ;; Make sure $a, $b and $c are subtypes of Data
     (when (and (isData $a) (and (isData $b) (isData $c)))
       (: (STTrans (: $bc (<: $b $c))
                   (: $ab (<: $a $b)))
          (<: $a $c)))))

;; Recursive step for subtyping coercion.
(= (type-annotated-bc $kb
                      (S $k)
                      (: (coerce (: $ab (<: $a $b))) (-> (: $x $a) $b)))
   (let ;; Recurse on $ab
       (: $ab (<: $a $b)) (type-annotated-bc $kb $k (: $ab (<: $a $b)))
     ;; Make sure $a, $b and $c are subtypes of Data
     (when (and (isData $a) (isData $b))
       (: (coerce (: $ab (<: $a $b))) (-> (: $x $a) $b)))))

;; Recursive step: bluebird
(= (type-annotated-bc $kb
                      (S $k)
                      (: (. (: $f (-> (: $y $b) $c))
                            (: $g (-> (: $x $a) $b)))
                         (-> (: $x $a) $c)))
   (let* (;; Recurse on f
          ((: $f (-> (: $y $b) $c))
           (type-annotated-bc $kb $k (: $f (-> (: $y $b) $c))))
          ;; Recurse on g
          ((: $g (-> (: $x $a) $b))
           (type-annotated-bc $kb $k (: $g (-> (: $x $a) $b)))))
     ;; Make sure $a, $b and $c are subtypes of Data
     (when (and (isData $a) (and (isData $b) (isData $c)))
       (: (. (: $f (-> (: $y $b) $c))
             (: $g (-> (: $x $a) $b)))
          (-> (: $x $a) $c)))))

;; Recursive step: phoenix
(= (type-annotated-bc $kb
                      (S $k)
                      (: (Φ (: $f (-> (: $y $b) (: $z $c) $d))
                            (: $g (-> (: $x $a) $b))
                            (: $h (-> (: $x $a) $c)))
                         (-> (: $x $a) $d)))
   (let* (;; Recurse on f
          ((: $f (-> (: $y $b) (: $z $c) $d))
           (type-annotated-bc $kb $k (: $f (-> (: $y $b) (: $z $c) $d))))
          ;; Recurse on g
          ((: $g (-> (: $x $a) $b))
           (type-annotated-bc $kb $k (: $g (-> (: $x $a) $b))))
          ;; Recurse on h
          ((: $h (-> (: $x $a) $c))
           (type-annotated-bc $kb $k (: $h (-> (: $x $a) $c)))))
     ;; Make sure $a, $b, $c and $d are subtypes of Data
     (when (and (isData $a) (and (isData $b) (and (isData $c) (isData $d))))
       (: (Φ (: $f (-> (: $y $b) (: $z $c) $d))
             (: $g (-> (: $x $a) $b))
             (: $h (-> (: $x $a) $c)))
          (-> (: $x $a) $d)))))

;; Recursive step for machine-translation.translate.  The point of
;; embedding the machine-translation.translate call in the backward
;; chainer is to be able to infer the correct parameters (in/out
;; languages) for call the service.
(= (type-annotated-bc $kb
                      (S $k)
                      (: (machine-translation.translate (: $in-nl NaturalLanguage)
                                                        (: $out-nl NaturalLanguage))
                         (-> (: $url (UniformResourceLocatorOfType (TextIn $in-nl)))
                             (TextIn $out-nl))))
   (let* (;; Recurse on $in-nl
          ((: $in-nl NaturalLanguage)
           (type-annotated-bc $kb $k (: $in-nl NaturalLanguage)))
          ;; Recurse on $out-nl
          ((: $out-nl NaturalLanguage)
           (type-annotated-bc $kb $k (: $out-nl NaturalLanguage))))
     (: (machine-translation.translate (: $in-nl NaturalLanguage)
                                       (: $out-nl NaturalLanguage))
        (-> (: $url (UniformResourceLocatorOfType (TextIn $in-nl)))
            (TextIn $out-nl)))))

;; Add type missing annotation to be compatible with type-annotated-bc
;; query format.  Whatever is missing is only added as variables, not
;; inferred, for that one may use the bc.  Note that the first
;; annotation must be provided manually
;;
;; For instance
;;
;; (add-type-annotation-holes (ModusPonens ab a))
;;
;; only outputs
;;
;; (ModusPonens (: ab $t#1) (: a $t#2))
;;
;; not
;;
;; (: (ModusPonens (: ab $t#1) (: a $t#2)) $t#3)
;;
;; That is because add-type can only detect application, that is a
;; term of the form (<ABS> <ARG>) to add the type annotation to <ARG>.
(: add-type-annotation-holes (-> $a $a))
(= (add-type-annotation-holes $term)
   (case (get-metatype $term)
     ((Symbol $term)
      (Grounded $term)
      (Variable $term)
      (Expression (case $term
                    ((() ())
                     (($x) ((add-type-annotation-hole $x)))
                     (($x $y) ((add-type-annotation-holes $x)
                               (: (add-type-annotation-holes $y) $a)))
                     (($x $y $z) (if (== $x :)
                                     ;; Already a type annotation,
                                     ;; only recurse on $y
                                     (: (add-type-annotation-holes $y) $z)
                                     ;; Not a type annotation, full
                                     ;; recursion
                                     ((add-type-annotation-holes $x)
                                      (: (add-type-annotation-holes $y) $a)
                                      (: (add-type-annotation-holes $z) $b))))
                     (($x $y $z $w) ((add-type-annotation-holes $x)
                                     (: (add-type-annotation-holes $y) $a)
                                     (: (add-type-annotation-holes $z) $b)
                                     (: (add-type-annotation-holes $w) $c)))
                     ($_ $_)))))))

;; Test add-type-annotation-holes
!(assertAlphaEqual
  (add-type-annotation-holes (: (STTrans VA VIV) (<: (VocalsIn "English") Audio)))
  (: (STTrans (: VA $a) (: VIV $b)) (<: (VocalsIn "English") Audio)))
!(assertAlphaEqual
  (add-type-annotation-holes (coerce (STTrans VA VIV)))
  (coerce (: (STTrans (: VA $a) (: VIV $b)) $c)))
!(assertAlphaEqual
  (add-type-annotation-holes
   (: (. (Φ midi2voice-zh.singingZH
            (. (machine-translation.translate "English" "Chinese")
               (. upload speech-recognition.s2t))
            tomidi.a2m)
         (coerce SIA))
      (-> (: $x (SongIn $l)) (VocalsIn "Chinese"))))
  (: (. (: (Φ (: midi2voice-zh.singingZH $a)
              (: (. (: (machine-translation.translate (: "English" $b)
                                                      (: "Chinese" $c)) $d)
                    (: (. (: upload $e) (: speech-recognition.s2t $f)) $g)) $h)
              (: tomidi.a2m $i)) $j)
        (: (coerce (: SIA $k)) $m))
     (-> (: $x (SongIn $l)) (VocalsIn "Chinese"))))
!(assertAlphaEqual
  (add-type-annotation-holes
   (: (. (Φ mixer.mix
            sound-spleeter.DTLOutput.accomp
            (. (Φ midi2voice-zh.singingZH
                  (. (machine-translation.translate "English" "Chinese")
                     (. upload speech-recognition.s2t))
                  tomidi.a2m)
               (. (coerce (STTrans VA VIV))
                  sound-spleeter.DTLOutput.vocals)))
         sound-spleeter.spleeter)
      (-> (: $x (SongIn "English")) (SongIn "Chinese"))))
  (: (. (: (Φ (: mixer.mix $a)
              (: sound-spleeter.DTLOutput.accomp $b)
              (: (. (: (Φ (: midi2voice-zh.singingZH $c)
                          (: (. (: (machine-translation.translate (: "English" $d)
                                                                  (: "Chinese" $e))
                                   $f)
                                (: (. (: upload $g)
                                      (: speech-recognition.s2t $h))
                                   $i))
                             $j)
                          (: tomidi.a2m $k))
                       $l)
                    (: (. (: (coerce (: (STTrans (: VA $m) (: VIV $n)) $o))
                             $p)
                          (: sound-spleeter.DTLOutput.vocals $q))
                       $r))
                 $s))
           $t)
        (: sound-spleeter.spleeter $u))
     (-> (: $x (SongIn "English")) (SongIn "Chinese"))))

;; Remove type annotations from a query.
;;
;; For instance
;;
;; (remove-type-annotations (: (ModusPonens (: ab (→ A B)) (: a A)) B))
;;
;; outputs
;;
;; (ModusPonens ab a)
(: remove-type-annotations (-> $a $a))
(= (remove-type-annotations $term)
   (case (get-metatype $term)
     ((Symbol $term)
      (Grounded $term)
      (Variable $term)
      (Expression (case $term
                    ;; Only covers up to trinary expression because
                    ;; for now the bc is not supposed to generate
                    ;; n-ary expression where n is greater 3.
                    ((() ())
                     (($x $y $z) (if (== $x :)
                                     (remove-type-annotations $y)
                                     ((remove-type-annotations $x)
                                      (remove-type-annotations $y)
                                      (remove-type-annotations $z))))
                     ($else (let* (($head (car-atom $term))
                                   ($tail (cdr-atom $term))
                                   ($rth (remove-type-annotations $head))
                                   ($rtt (remove-type-annotations $tail)))
                              (cons-atom $rth $rtt)))))))))

;; Test remove-type-annotations
!(assertEqual
  (remove-type-annotations
   (: (STTrans (: VA $a) (: VIV $b)) (<: (VocalsIn "English") Audio)))
  (STTrans VA VIV))
!(assertAlphaEqual
  (remove-type-annotations
   (: (. (: (machine-translation.translate (: "English" $b)
                                           (: "Chinese" $c)) $d)
         (: (. (: upload $e) (: speech-recognition.s2t $f)) $g)) $h))
  (. (machine-translation.translate "English" "Chinese")
     (. upload speech-recognition.s2t)))
!(assertAlphaEqual
  (remove-type-annotations
   (: (Φ (: midi2voice-zh.singingZH $a)
         (: (. (: (machine-translation.translate (: "English" $b)
                                                 (: "Chinese" $c)) $d)
               (: (. (: upload $e) (: speech-recognition.s2t $f)) $g)) $h)
         (: tomidi.a2m $i)) $j))
  (Φ midi2voice-zh.singingZH
     (. (machine-translation.translate "English" "Chinese")
        (. upload speech-recognition.s2t))
        tomidi.a2m))
!(assertAlphaEqual
  (remove-type-annotations
   (. (: (Φ (: midi2voice-zh.singingZH $a)
               (: (. (: (machine-translation.translate (: "English" $b)
                                                       (: "Chinese" $c)) $d)
                     (: (. (: upload $e) (: speech-recognition.s2t $f)) $g)) $h)
               (: tomidi.a2m $i)) $j)
         (: (coerce (: SIA $k)) $l)))
  (. (Φ midi2voice-zh.singingZH
        (. (machine-translation.translate "English" "Chinese")
           (. upload speech-recognition.s2t))
        tomidi.a2m)
     (coerce SIA)))
!(assertAlphaEqual
  (remove-type-annotations
   (: (. (: (Φ (: midi2voice-zh.singingZH $a)
               (: (. (: (machine-translation.translate (: "English" $b)
                                                       (: "Chinese" $c)) $d)
                     (: (. (: upload $e) (: speech-recognition.s2t $f)) $g)) $h)
               (: tomidi.a2m $i)) $j)
         (: (coerce (: SIA $k)) $l))
      (-> (: $x (SongIn $l)) (VocalsIn "Chinese"))))
  (. (Φ midi2voice-zh.singingZH
        (. (machine-translation.translate "English" "Chinese")
           (. upload speech-recognition.s2t))
        tomidi.a2m)
     (coerce SIA)))

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
;; ;; of $x.  It is therefore disabled during AI-service composition
;; ;; synthesis.
;; (= ((Φ $f $g $h) $x) (($f ($g $x)) ($h $x)))

;; These tests allow to prove that the reduction rules are correct in
;; the sense that the reduced term, if applied to arguments, β-reduces
;; to the same term.  Note that in order to pass all combinator
;; β-reduction rules need to be enabled.

;; Test that applying left associative composition reduces is
;; equivalent to applying right associative composition.
!(assertEqual
  ((. (. $h $g) $f) $x)
  ((. $h (. $g $f)) $x))

;; ;; Note: the following two tests can only pass if the Phoenix
;; ;; β-reduction rule is enabled.
;; ;;
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

;; The composition of spleeter with the mixing of accomp
;; and vocals is involutive.
(= (. (Φ mixer.mix
         sound-spleeter.DTLOutput.accomp
         sound-spleeter.DTLOutput.vocals)
      sound-spleeter.spleeter)
   id)
(= (. sound-spleeter.spleeter (Φ mixer.mix
                                 sound-spleeter.DTLOutput.accomp
                                 sound-spleeter.DTLOutput.vocals))
   id)

;; The composition of (. spleeter f) or (. f spleeter) with the mixing
;; of accomp and vocals is idempotent with respect to f.
(= (. (Φ mixer.mix
         sound-spleeter.Output.accomp
         sound-spleeter.DTLOutput.vocals) (. sound-spleeter.spleeter $f))
   $f)
(= (. (. $f sound-spleeter.spleeter)
      (Φ mixer.mix
         sound-spleeter.Output.accomp
         sound-spleeter.DTLOutput.vocals))
   $f)

;; Composing with id is idempotent.  Or id is the identity element of
;; composition.
(= (. id $f) $f)
(= (. $f id) $f)

;; Applying id to x outputs x
(= (id $x) $x)

;; Sequential coercion
(= (. (coerce $bc) (coerce $ab)) (coerce (STTrans $bc $ab)))
(= (. (coerce $bc) (. (coerce $ab) $f)) (. (coerce (STTrans $bc $ab)) $f))

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

;; Like above but doing type inference using type-annotated-bc
!(assertEqual
  (type-annotated-bc &kb
                     (fromNumber 0)
                     (: sound-spleeter.spleeter
                        (-> (: $x (SongIn "English"))
                            (sound-spleeter.DTLOutput "English"))))
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

;; Like above but doing type inference using type-annotated-bc
!(assertEqual
  (type-annotated-bc &kb
                     (fromNumber 0)
                     (: speech-recognition.s2t
                        (-> (: $x Audio) (TextIn "English"))))
  (: speech-recognition.s2t (-> (: $x Audio) (TextIn "English"))))

;; Prove that (<: (VocalsIn "English") Audio)
!(assertEqual
  (bc &kb (fromNumber 1) (: $prf (<: (VocalsIn "English") Audio)))
  (: (STTrans VA VIV) (<: (VocalsIn "English") Audio)))

;; Like above but doing type inference using type-annotated-bc
!(assertEqual
  (type-annotated-bc &kb
                     (fromNumber 1)
                     (: (STTrans (: VA $a) (: VIV $b))
                        (<: (VocalsIn "English") Audio)))
  (: (STTrans (: VA (<: Vocals Audio))
              (: VIV (<: (VocalsIn "English") Vocals)))
     (<: (VocalsIn "English") Audio)))

;; Synthesize composition of
;;
;; (-> (VocalsIn "English") Audio)
;;
;; which should be a coercion
!(assertEqual
  (unique (capture
   (bc &kb (fromNumber 2) (: $prg (-> (: $x (VocalsIn "English")) Audio)))))
  (: (coerce (STTrans VA VIV)) (-> (: $x (VocalsIn "English")) Audio)))

;; Like above but doing type inference using type-annotated-bc
!(assertEqual
  (type-annotated-bc &kb
                     (fromNumber 2)
                     (: (coerce (: (STTrans (: VA $a) (: VIV $b)) $c))
                        (-> (: $x (VocalsIn "English")) Audio)))
  (: (coerce (: (STTrans (: VA (<: Vocals Audio))
                         (: VIV (<: (VocalsIn "English") Vocals)))
                (<: (VocalsIn "English") Audio)))
     (-> (: $x (VocalsIn "English")) Audio)))

;; Synthesize sequential composition of
;;
;; (-> (VocalsIn "English") (TextIn "English"))
;;
;; which should merely be a call of speech-recognition with proper
;; casting from (VocalsIn "English") to Audio.
!(assertEqual
  (unique (capture
   (bc &kb
       (fromNumber 3)
       (: $prg
          (-> (: $x (VocalsIn "English")) (TextIn "English"))))))
  (: (. speech-recognition.s2t (coerce (STTrans VA VIV)))
     (-> (: $x (VocalsIn "English")) (TextIn "English"))))

;; Like above but doing type inference using type-annotated-bc
!(assertAlphaEqual
  (type-annotated-bc &kb
                     (fromNumber 3)
                     (: (add-type-annotation-holes
                         (. speech-recognition.s2t (coerce (STTrans VA VIV))))
                        (-> (: $x (VocalsIn "English")) (TextIn "English"))))
  (: (. (: speech-recognition.s2t (-> (: $y Audio) (TextIn "English")))
        (: (coerce (: (STTrans (: VA (<: Vocals Audio))
                               (: VIV (<: (VocalsIn "English") Vocals)))
                      (<: (VocalsIn "English") Audio)))
           (-> (: $x (VocalsIn "English")) Audio)))
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

;; Like above but doing type inference using type-annotated-bc
!(assertAlphaEqual
  (type-annotated-bc &kb
                     (fromNumber 1)
                     (add-type-annotation-holes
                      (: (. upload speech-recognition.s2t)
                         (-> (: $x Audio)
                             (UniformResourceLocatorOfType (TextIn "English"))))))
  (: (. (: upload (-> (: $y (TextIn "English"))
                      (UniformResourceLocatorOfType (TextIn "English"))))
        (: speech-recognition.s2t (-> (: $x Audio) (TextIn "English"))))
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

;; Like above but doing type inference using type-annotated-bc
!(assertAlphaEqual
  (type-annotated-bc
   &kb
   (fromNumber 4)
   (: (. (: upload $a)
         (: (. (: speech-recognition.s2t $b)
               (: (coerce (: (STTrans (: VA $c) (: VIV $d)) $e)) $f)) $g))
      (-> (: $x (VocalsIn "English"))
          (UniformResourceLocatorOfType (TextIn "English")))))
  (: (. (: upload (-> (: $y (TextIn "English"))
                      (UniformResourceLocatorOfType (TextIn "English"))))
        (: (. (: speech-recognition.s2t (-> (: $z Audio) (TextIn "English")))
              (: (coerce (: (STTrans (: VA (<: Vocals Audio))
                                     (: VIV (<: (VocalsIn "English") Vocals)))
                            (<: (VocalsIn "English") Audio)))
                 (-> (: $x (VocalsIn "English")) Audio)))
           (-> (: $x (VocalsIn "English")) (TextIn "English"))))
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
  (unique (capture
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
  (unique (capture
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

;; Like above but doing type inference using type-annotated-bc
!(assertAlphaEqual
  (type-annotated-bc
   &kb
   (fromNumber 4)
   (: (. (: (Φ (: midi2voice-zh.singingZH $a)
               (: (. (: (machine-translation.translate (: "English" $b)
                                                       (: "Chinese" $c)) $d)
                     (: (. (: upload $e) (: speech-recognition.s2t $f)) $g)) $h)
               (: tomidi.a2m $i)) $j)
         (: (coerce (: SIA $k)) $m))
      (-> (: $x (SongIn $l)) (VocalsIn "Chinese"))))
  (: (. (: (Φ (: midi2voice-zh.singingZH
                 (-> (: $y (TextIn "Chinese"))
                     (: $z MusicalInstrumentDigitalInterface)
                     (VocalsIn "Chinese")))
              (: (. (: (machine-translation.translate
                        (: "English" NaturalLanguage)
                        (: "Chinese" NaturalLanguage))
                       (-> (: $w (UniformResourceLocatorOfType (TextIn "English")))
                           (TextIn "Chinese")))
                    (: (. (: upload
                             (-> (: $t (TextIn "English"))
                                 (UniformResourceLocatorOfType (TextIn "English"))))
                          (: speech-recognition.s2t
                             (-> (: $u Audio) (TextIn "English"))))
                       (-> (: $u Audio)
                           (UniformResourceLocatorOfType (TextIn "English")))))
                 (-> (: $u Audio) (TextIn "Chinese")))
              (: tomidi.a2m (-> (: $u Audio) MusicalInstrumentDigitalInterface)))
           (-> (: $u Audio) (VocalsIn "Chinese")))
        (: (coerce (: SIA (<: (SongIn $l) Audio)))
           (-> (: $x (SongIn $l)) Audio)))
     (-> (: $x (SongIn $l)) (VocalsIn "Chinese"))))

;; ;; ;; Enable this to carry out the final service composition
;; ;; ;; Synthesize all AI service composition going from (SongIn "English")
;; ;; ;; to (SongIn "Chinese").  Sort by lengths and select the top 10.
;; ;; ;; !(assertEqual  ; Re-enable on assert contain is supported
;; ;; !(List.sortWith termLengthLT
;; ;;                 (toList (collapse
;;                                ;; !(limit 6
;;                                 !(bc &kb (fromNumber 6)
;;                                     (: $prg
;;                                        (-> (: $x (SongIn "English"))
;;                                            (SongIn "Chinese")))););)))

;; Infer the type annotations of one of the solutions above but
;; slightly simplified
!(assertAlphaEqual
  (type-annotated-bc
   &kb
   (fromNumber 5)
   (: (Φ (: mixer.mix $a)
         (: sound-spleeter.DTLOutput.accomp $b)
         (: (. (: (Φ (: midi2voice-zh.singingZH $c)
                     (: (. (: (machine-translation.translate (: "English" $d)
                                                             (: "Chinese" $e))
                              $f)
                           (: (. (: upload $g)
                                 (: speech-recognition.s2t $h))
                              $i))
                        $j)
                     (: tomidi.a2m $k))
                  $l)
               (: (. (: (coerce (: (STTrans (: VA $m) (: VIV $n)) $o))
                        $p)
                     (: sound-spleeter.DTLOutput.vocals $q))
                  $r))
            $s))
      $t))
  (: (Φ (: mixer.mix (-> (: $x Instrumental)
                         (: $y (VocalsIn "Chinese"))
                         (SongIn "Chinese")))
        (: sound-spleeter.DTLOutput.accomp
           (-> (: $z (sound-spleeter.DTLOutput $l)) Instrumental))
        (: (. (: (Φ (: midi2voice-zh.singingZH
                       (-> (: $w (TextIn "Chinese"))
                           (: $u MusicalInstrumentDigitalInterface)
                           (VocalsIn "Chinese")))
                    (: (. (: (machine-translation.translate
                              (: "English" NaturalLanguage)
                              (: "Chinese" NaturalLanguage))
                             (-> (: $s (UniformResourceLocatorOfType
                                              (TextIn "English")))
                                 (TextIn "Chinese")))
                          (: (. (: upload
                                   (-> (: $t (TextIn "English"))
                                       (UniformResourceLocatorOfType
                                        (TextIn "English"))))
                                (: speech-recognition.s2t
                                   (-> (: $i Audio)
                                       (TextIn "English"))))
                             (-> (: $i Audio)
                                 (UniformResourceLocatorOfType
                                  (TextIn "English")))))
                       (-> (: $i Audio)
                           (TextIn "Chinese")))
                    (: tomidi.a2m
                       (-> (: $i Audio)
                           MusicalInstrumentDigitalInterface)))
                 (-> (: $i Audio)
                     (VocalsIn "Chinese")))
              (: (. (: (coerce (: (STTrans (: VA (<: Vocals Audio))
                                           (: VIV (<: (VocalsIn $l) Vocals)))
                                  (<: (VocalsIn $l) Audio)))
                       (-> (: $j (VocalsIn $l)) Audio))
                    (: sound-spleeter.DTLOutput.vocals
                       (-> (: $z (sound-spleeter.DTLOutput $l))
                           (VocalsIn $l))))
                 (-> (: $z (sound-spleeter.DTLOutput $l))
                     Audio)))
           (-> (: $z
                  (sound-spleeter.DTLOutput $l))
               (VocalsIn "Chinese"))))
     (-> (: $z (sound-spleeter.DTLOutput $l)) (SongIn "Chinese"))))

;; Infer the type annotations of one of the solutions from above
!(assertAlphaEqual
  (type-annotated-bc
   &kb
   (fromNumber 6)
   (: (. (: (Φ (: mixer.mix $a)
               (: sound-spleeter.DTLOutput.accomp $b)
               (: (. (: (Φ (: midi2voice-zh.singingZH $c)
                           (: (. (: (machine-translation.translate (: "English" $d)
                                                                   (: "Chinese" $e))
                                    $f)
                                 (: (. (: upload $g)
                                       (: speech-recognition.s2t $h))
                                    $i))
                              $j)
                           (: tomidi.a2m $k))
                        $l)
                     (: (. (: (coerce (: (STTrans (: VA $m) (: VIV $n)) $o))
                              $p)
                           (: sound-spleeter.DTLOutput.vocals $q))
                        $r))
                  $s))
            $t)
         (: sound-spleeter.spleeter $u))
      (-> (: $x (SongIn "English")) (SongIn "Chinese"))))
  (: (. (: (Φ (: mixer.mix (-> (: $i Instrumental)
                               (: $vc (VocalsIn "Chinese"))
                               (SongIn "Chinese")))
              (: sound-spleeter.DTLOutput.accomp
                 (-> (: $s (sound-spleeter.DTLOutput "English"))
                     Instrumental))
              (: (. (: (Φ (: midi2voice-zh.singingZH
                             (-> (: $tc (TextIn "Chinese"))
                                 (: $m MusicalInstrumentDigitalInterface)
                                 (VocalsIn "Chinese")))
                          (: (. (: (machine-translation.translate
                                    (: "English" NaturalLanguage)
                                    (: "Chinese" NaturalLanguage))
                                   (-> (: $u
                                          (UniformResourceLocatorOfType
                                           (TextIn "English")))
                                       (TextIn "Chinese")))
                                (: (. (: upload
                                         (-> (: $te (TextIn "English"))
                                             (UniformResourceLocatorOfType
                                              (TextIn "English"))))
                                      (: speech-recognition.s2t
                                         (-> (: $a Audio)
                                             (TextIn "English"))))
                                   (-> (: $a Audio)
                                       (UniformResourceLocatorOfType
                                        (TextIn "English")))))
                             (-> (: $a Audio)
                                 (TextIn "Chinese")))
                          (: tomidi.a2m
                             (-> (: $a Audio)
                                 MusicalInstrumentDigitalInterface)))
                       (-> (: $a Audio)
                           (VocalsIn "Chinese")))
                    (: (. (: (coerce
                              (: (STTrans
                                  (: VA (<: Vocals Audio))
                                  (: VIV (<: (VocalsIn "English") Vocals)))
                                 (<: (VocalsIn "English") Audio)))
                             (-> (: $ve (VocalsIn "English"))
                                 Audio))
                          (: sound-spleeter.DTLOutput.vocals
                             (-> (: $s (sound-spleeter.DTLOutput "English"))
                                 (VocalsIn "English"))))
                       (-> (: $s (sound-spleeter.DTLOutput "English"))
                           Audio)))
                 (-> (: $s (sound-spleeter.DTLOutput "English"))
                     (VocalsIn "Chinese"))))
           (-> (: $s (sound-spleeter.DTLOutput "English"))
               (SongIn "Chinese")))
        (: sound-spleeter.spleeter
           (-> (: $x (SongIn "English"))
               (sound-spleeter.DTLOutput "English"))))
     (-> (: $x (SongIn "English")) (SongIn "Chinese"))))

;; ;; The first 6 candidates are printed in DOT format
;; !(DOT.println! (: (. (Φ mixer.mix sound-spleeter.DTLOutput.accomp (. (Φ midi2voice-zh.singingZH (. (machine-translation.translate "English" "Chinese") (. upload speech-recognition.s2t)) tomidi.a2m) (. (coerce IA) sound-spleeter.DTLOutput.accomp))) sound-spleeter.spleeter) (-> (: $x (SongIn "English")) (SongIn "Chinese"))))
;; !(DOT.println! (: (. (Φ mixer.mix sound-spleeter.DTLOutput.accomp (. (Φ midi2voice-zh.singingZH (. (machine-translation.translate "English" "Chinese") (. upload speech-recognition.s2t)) tomidi.a2m) (. (coerce SIA) (Φ mixer.mix sound-spleeter.DTLOutput.accomp sound-spleeter.DTLOutput.vocals)))) sound-spleeter.spleeter) (-> (: $x (SongIn "English")) (SongIn "Chinese"))))
;; !(DOT.println! (: (. (Φ mixer.mix sound-spleeter.DTLOutput.accomp (. (Φ midi2voice-zh.singingZH (. (machine-translation.translate "English" "Chinese") (. upload speech-recognition.s2t)) tomidi.a2m) (. (coerce (STTrans VA VIV)) sound-spleeter.DTLOutput.vocals))) sound-spleeter.spleeter) (-> (: $x (SongIn "English")) (SongIn "Chinese"))))
;; !(DOT.println! (: (. (Φ mixer.mix (. sound-spleeter.DTLOutput.accomp sound-spleeter.spleeter) (. (Φ midi2voice-zh.singingZH (. (machine-translation.translate "English" "Chinese") (. upload speech-recognition.s2t)) tomidi.a2m) (coerce SIA))) (Φ mixer.mix (. sound-spleeter.DTLOutput.accomp sound-spleeter.spleeter) (. (Φ midi2voice-zh.singingZH (. (machine-translation.translate "English" "Chinese") (. upload speech-recognition.s2t)) tomidi.a2m) (coerce SIA)))) (-> (: $x (SongIn "English")) (SongIn "Chinese"))))
;; !(DOT.println! (: (. (Φ mixer.mix (. sound-spleeter.DTLOutput.accomp sound-spleeter.spleeter) (. (Φ midi2voice-zh.singingZH (. (machine-translation.translate "English" "Chinese") (. upload speech-recognition.s2t)) tomidi.a2m) (coerce SIA))) (Φ mixer.mix (. sound-spleeter.DTLOutput.accomp sound-spleeter.spleeter) (. (Φ midi2voice-zh.singingZH (. (machine-translation.translate "English" "Chinese") (. upload speech-recognition.s2t)) tomidi.a2m) (. (coerce IA) (. sound-spleeter.DTLOutput.accomp sound-spleeter.spleeter))))) (-> (: $x (SongIn "English")) (SongIn "Chinese"))))
;; !(DOT.println! (: (. (Φ mixer.mix (. sound-spleeter.DTLOutput.accomp sound-spleeter.spleeter) (. (Φ midi2voice-zh.singingZH (. (machine-translation.translate "English" "Chinese") (. upload speech-recognition.s2t)) tomidi.a2m) (coerce SIA))) (Φ mixer.mix (. sound-spleeter.DTLOutput.accomp sound-spleeter.spleeter) (. (Φ midi2voice-zh.singingZH (. (machine-translation.translate "English" "Chinese") (. upload speech-recognition.s2t)) tomidi.a2m) (. (coerce (STTrans VA VIV)) (. sound-spleeter.DTLOutput.vocals sound-spleeter.spleeter))))) (-> (: $x (SongIn "English")) (SongIn "Chinese"))))

;; ;; (Partial) 3rd candidate (the solution) printed in DOT format with type
;; ;; annotations on the edges
;; !(DOT.println!
;;   (: (Φ (: mixer.mix (-> (: $x Instrumental)
;;                          (: $y (VocalsIn "Chinese"))
;;                          (SongIn "Chinese")))
;;         (: sound-spleeter.DTLOutput.accomp
;;            (-> (: $z (sound-spleeter.DTLOutput $l)) Instrumental))
;;         (: (. (: (Φ (: midi2voice-zh.singingZH
;;                        (-> (: $w (TextIn "Chinese"))
;;                            (: $u MusicalInstrumentDigitalInterface)
;;                            (VocalsIn "Chinese")))
;;                     (: (. (: (machine-translation.translate
;;                               (: "English" NaturalLanguage)
;;                               (: "Chinese" NaturalLanguage))
;;                              (-> (: $s (UniformResourceLocatorOfType
;;                                               (TextIn "English")))
;;                                  (TextIn "Chinese")))
;;                           (: (. (: upload
;;                                    (-> (: $t (TextIn "English"))
;;                                        (UniformResourceLocatorOfType
;;                                         (TextIn "English"))))
;;                                 (: speech-recognition.s2t
;;                                    (-> (: $i Audio)
;;                                        (TextIn "English"))))
;;                              (-> (: $i Audio)
;;                                  (UniformResourceLocatorOfType
;;                                   (TextIn "English")))))
;;                        (-> (: $i Audio)
;;                            (TextIn "Chinese")))
;;                     (: tomidi.a2m
;;                        (-> (: $i Audio)
;;                            MusicalInstrumentDigitalInterface)))
;;                  (-> (: $i Audio)
;;                      (VocalsIn "Chinese")))
;;               (: (. (: (coerce (: (STTrans (: VA (<: Vocals Audio))
;;                                            (: VIV (<: (VocalsIn $l) Vocals)))
;;                                   (<: (VocalsIn $l) Audio)))
;;                        (-> (: $j (VocalsIn $l)) Audio))
;;                     (: sound-spleeter.DTLOutput.vocals
;;                        (-> (: $z (sound-spleeter.DTLOutput $l))
;;                            (VocalsIn $l))))
;;                  (-> (: $z (sound-spleeter.DTLOutput $l))
;;                      Audio)))
;;            (-> (: $z
;;                   (sound-spleeter.DTLOutput $l))
;;                (VocalsIn "Chinese"))))
;;      (-> (: $z (sound-spleeter.DTLOutput $l)) (SongIn "Chinese"))))

;; ;; 3rd candidate (the solution) printed in DOT format with type
;; ;; annotations on the edges
;; !(DOT.println!
;;   (: (. (: (Φ (: mixer.mix (-> (: $i Instrumental)
;;                                (: $vc (VocalsIn "Chinese"))
;;                                (SongIn "Chinese")))
;;               (: sound-spleeter.DTLOutput.accomp
;;                  (-> (: $s (sound-spleeter.DTLOutput "English"))
;;                      Instrumental))
;;               (: (. (: (Φ (: midi2voice-zh.singingZH
;;                              (-> (: $tc (TextIn "Chinese"))
;;                                  (: $m MusicalInstrumentDigitalInterface)
;;                                  (VocalsIn "Chinese")))
;;                           (: (. (: (machine-translation.translate
;;                                     (: "English" NaturalLanguage)
;;                                     (: "Chinese" NaturalLanguage))
;;                                    (-> (: $u
;;                                           (UniformResourceLocatorOfType
;;                                            (TextIn "English")))
;;                                        (TextIn "Chinese")))
;;                                 (: (. (: upload
;;                                          (-> (: $te (TextIn "English"))
;;                                              (UniformResourceLocatorOfType
;;                                               (TextIn "English"))))
;;                                       (: speech-recognition.s2t
;;                                          (-> (: $a Audio)
;;                                              (TextIn "English"))))
;;                                    (-> (: $a Audio)
;;                                        (UniformResourceLocatorOfType
;;                                         (TextIn "English")))))
;;                              (-> (: $a Audio)
;;                                  (TextIn "Chinese")))
;;                           (: tomidi.a2m
;;                              (-> (: $a Audio)
;;                                  MusicalInstrumentDigitalInterface)))
;;                        (-> (: $a Audio)
;;                            (VocalsIn "Chinese")))
;;                     (: (. (: (coerce
;;                               (: (STTrans
;;                                   (: VA (<: Vocals Audio))
;;                                   (: VIV (<: (VocalsIn "English") Vocals)))
;;                                  (<: (VocalsIn "English") Audio)))
;;                              (-> (: $ve (VocalsIn "English"))
;;                                  Audio))
;;                           (: sound-spleeter.DTLOutput.vocals
;;                              (-> (: $s (sound-spleeter.DTLOutput "English"))
;;                                  (VocalsIn "English"))))
;;                        (-> (: $s (sound-spleeter.DTLOutput "English"))
;;                            Audio)))
;;                  (-> (: $s (sound-spleeter.DTLOutput "English"))
;;                      (VocalsIn "Chinese"))))
;;            (-> (: $s (sound-spleeter.DTLOutput "English"))
;;                (SongIn "Chinese")))
;;         (: sound-spleeter.spleeter
;;            (-> (: $x (SongIn "English"))
;;                (sound-spleeter.DTLOutput "English"))))
;;      (-> (: $x (SongIn "English")) (SongIn "Chinese"))))
