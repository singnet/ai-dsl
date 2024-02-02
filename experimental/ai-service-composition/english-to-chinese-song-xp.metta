;; Turn English song into a Chinese song
!(import! &kb english-to-chinese-song-services.metta)

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

;; Look for a program that takes a source_lang as String, a
;; target_lang as String, a sentences_url as String and returns a
;; naint.machine-translation.Input.
!(bc &kb
     (: $prg (-> String String String naint.machine-translation.Input))
     (fromNumber 0))
