;; Curried Backward Chainer type signature
(: bc (-> $a                            ; Knowledge base space
          Nat                           ; Maximum depth
          $b                            ; Query
          $b))                          ; Result

;; Base case
(= (bc $kb $_ (: $prf $ccln))
   (trace! (bc-bas $_ (: $prf $ccln))
   (match $kb (: $prf $ccln) (: $prf $ccln))))

;; Recursive step
(= (bc $kb (S $k) (: ($prfabs $prfarg) $ccln))
   (trace! (bc-rec (S $k) (: ($prfabs $prfarg) $ccln))
   (let* (;; Recursive call on function
          ((: $prfabs (-> $prms $ccln))
           (bc $kb $k (: $prfabs (-> $prms $ccln))))
          ;; Recursive call on argument
          ((: $prfarg $prms)
           (bc $kb $k (: $prfarg $prms))))
     ;; Query with holes filled
     (: ($prfabs $prfarg) $ccln))))

;; Knowledge base
!(bind! &kb (new-space))
!(add-atom &kb (: 42 Number))
!(add-atom &kb (: foo (-> Number String)))
!(add-atom &kb (: bar (-> String Bool)))
!(add-atom &kb (: . (-> (-> $b $c) (-> (-> $a $b) (-> $a $c)))))

;; Tests
;; Infer the type of 42
!(bc &kb Z (: 42 $type))

;; Synthesize terms of type String
!(bc &kb (S Z) (: $prg String))

;; Synthesize all functions that output a Boolean value
!(bc &kb (S (S Z)) (: $prg (-> $intput Bool)))
