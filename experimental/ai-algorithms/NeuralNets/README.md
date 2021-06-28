# Fake News Warning Classifier in Idris

Work done:

1.  Implementing a simple fake new classifier task in Haskell and
    Idris1.

2.  AI services aggregation with Idris2.

## Fake News Warning Classifier

### Description

The idea is to develop an NLP model using word embedding and train it
with fake news vs real news dataset [@Kaggle_Datasets].I implemented a
word embedding model based on an article shared by Eligijus Bujokas on
medium [@Word_embedding]. Hence, given a dataset or a csv file
containing these lines for instance.

1.  The future king is the prince.

2.  Daughter is the princess.

3.  Son is the prince.

4.  Only a man can be a king.

The goal is to make the computer understand the relationship between
words in a sentence. Therefore, we want to create data points for all
words in a sentence such that we have :-

(The, future)(The, king) (future, king) (future,The)..etc

What we did here is that we took each word and created pairs between 2
words adjacent to it from its left and it's right. For example the word
\"King\" in sentence 1 has 2 words on its left which are \"future\" and
\"The\" and 2 words on its right \"is\" and \"the\". Therefore we have.
(king,future) (king,The) (king,is) (king,the) as our data points.
\"King\" here is our focus word and the points created are called
context. For Context can be as many as 2, 3, 4\...etc as we wish, but
for this example we picked 2.

``` idris
makeWordPairs :: [Str] -> [(Str,Str)]
makeWordPairs [] = []
makeWordPairs (x:y:z:h:xs) = (x,y):(x,z):(y,x):(y,z):(y,h):(z,x):(z,y):(z,h):(h,x):(h,y):(h,z):makeWordPairs xs
makeWordPairs (x:y:z:xs) = (x,y):(x,z):(y,x):(y,z):(z,x):(z,y):makeWordPairs xs
makeWordPairs (x:y:xs) =  (x,y):makeWordPairs xs
```

The corresponding Idris1 code is as follows

``` idris
makeWordPairs : List String ->
        List (String, String)
makeWordPairs [] = []
makeWordPairs (x::y::z::h::xs) = (x,y)::(x,z)::(y,z)::(y,h)::(z,x)::(z,y)::(z,h)::(h,x)::(h,y)::(h,z)::makeWordPairs xs
makeWordPairs (x::y::z::xs) = (x,y)::(x,z)::(y,z)::(z,x)::(z,y)::makeWordPairs xs
makeWordPairs (x::y::xs) = (x,y)::makeWordPairs xs
```

Our model's input will be the x values of our data points where as the
targets are the ys e.g in (king,future) (king, The)

X Y King future King The . . .

Before we make word pairs, however, we perform some common dataset
preprocessing such as removing stop words and creating dictionaries.

``` idris
removeStopWords :: Str -> [Str]
removeStopWords line = filter (not . ((flip elem ) stopwords )) (words line)
```

Corresponding Idris1 code

``` idris
export
removeStopWords : String -> List String
removeStopWords line = filter (not . ((flip elem) stopwords)) (words line)
```

``` idris
createDictionary::(Integral i) => [Str] -> [(Str, i)]
createDictionary vocabs = zip  (sort . nub $ vocabs) [1..]
```

Corresponding Idris1 code

``` idris
createDictionary : List String ->  List (String, Nat)
createDictionary xss = func 0 tmp
  where
    tmp = sort . nub $ xss
    func : Nat -> List String -> List (String, Nat)
    func _ [] = []
    func Z (x::xs) = (x, S Z) :: func (S (S Z)) xs
    func (S k) (x::xs) = (x, S k) :: func (S (S k) ) xs
```

The next step is passing the input to our model. To do so we need to
first one-hot encode the inputs and the targets.

``` idris
oneHotEncoder :: (Num q) => [Int] -> [q] -> [[q]]
oneHotEncoder xs zs = foldr (\x acc -> insertAt zs 1 x: acc) [] xs
```

Corresponding Idris1 code

``` idris
oneHotEncoder : List Nat ->
        List Double ->
        List (List Double)
oneHotEncoder ws zs = foldr(\x, acc => (insertAt zs 1.0 x)::acc) [] ws

Finally, we pass it to our model which has one Deep Neural Network of  (n,n) Shape.
We apply softmax activation to our output and compute cost using cross entropy loss function.
Model function here returns newly learned weights.

\begin{minted}
model :: (Floating j) => [[j]] -> [[j]] -> [[j]] -> j -> j -> j -> j -> Int -> [[j]]
model [] _ _ _ _ _ _ _ = []
model _ [] _ _ _ _ _ _ = []
model _ _ [] _ _ _ _ _ = []
model [] [] [] _ _ _ _ _= []
model weights inputs targets alpha beta1 beta2 epsilon iterations
  |iterations == 0 = weights
  |otherwise = do
    let predicted = fullNNLayer inputs weights
    let full_cost = loss_func grad_CrossEntropy  predicted targets
    let new_weights = optimizer adam_Optimizer weights full_cost alpha 0.0 0.0 beta1 beta2 epsilon
    model new_weights inputs targets alpha beta1 beta2 epsilon (iterations - 1)
```

Corresponding Idris1 code

``` idris
export
model : List (List Double) ->
    List (List Double) ->
    List (List Double) ->
    Double ->
    Double ->
    Double ->
    Double ->
    Int ->
    List (List Double )
model [] _ _ _ _ _ _ _ = []
model _ [] _ _ _ _ _ _ = []
model _ _ [] _ _ _ _ _ = []
model weights inputs targets alpha beta1 beta2 epsilon iterations = case iterations == 0 of
  True => weights
  False => do
    let predicted = fullNNLayer inputs weights
    let full_cost = loss_func grad_CrossEntropy predicted targets
    let new_weights = optimizer adam_Optimizer weights full_cost alpha 0.0 0.0 beta1 beta2 epsilon
    model new_weights inputs targets alpha beta1 beta2 epsilon (iterations - 1)
```

### Objectives and Achievements

The objective of the work was to explore Idris better and get familiar
with it. Since Idris adopts Haskel's syntax I thought it would be better
to get familiar with Haskel first. I decided to study it by reading
"Learn you Haskel for good" by Miran Lipovača which is one of the best
resources out there for learning Haskel and I highly recommend it.
Writing the fake News classifier with Haskel was just my attempt to
understand Haskel better i.e is not related to the task. Both the Idris
and Haskel model accepts a list of list of Strings which represents a
dataset and return weights predicted by the models.

### Future work {#future-work-3}

It's worth noting that the above models return the learned weights and
not the prediction accuracy as in classical machine learning tasks. The
function that tests the model's prediction over a test set is not
implemented as well and can be added in future work.

## AI services aggregation with Idris2

The idea is to showcase how Idris can facilitate AI services
co-operations of tasks. For the purposes of demonstration, I came up
with an algorithm that can choose the best performing cost function for
the fake news classifier model I discussed in the earlier section. The
algorithm is yet to be implemented in Idris. However, it's important I
describe what it does ideally as I have updated the fake news classifier
based on how their interaction would be.

Let's call the algorithm that finds the best cost function the reducer
and the fake news classifier as the classifier. The reducer ideally does
the following:

1.  Accepts a model and runs a comparison test on it over a selected
    list of cost functions.

2.  Run iteratively with say 50 iterations each time running the
    classifier with the cost functions and recording its performance.
    Please note that the overall training performance is costly hence
    the number of iterations of the reducer must be lowered.

3.  Compare the losses and count 1 for the cost function with the lowest
    loss.

4.  Repeat the process until you reach the last 10 iterations.

5.  For the last 10 we want to add the total counts so far plus a term
    called accumulate and a coefficient of 0.4.

6.  We do so for each score gained at the last 10 iterations so that we
    put weights to the scores gained toward the end of the iteration as
    we assume that at this point the classifier must have learnt
    something. The points added on top of the original score are bonuses
    and they increase with a margin of accumulate + 0.4.

For example let's say we have two costs Cross entropy loss (CE) and Mean
squared error (MST). Let's also say that at the end of the 39th
iteration of this reducer function CE has scored 24 points and MST 15
points (points are gained each time the cost gives lower results than
the other cost functions)

If MST scored a point at the 40th iteration we don't just add 1 to total
16 rather we add the bonus 1+ 0.4 so its 16.04. 1 here is the initial
accumulate value. Whoever scores a point in the 41th Iteration is
rewarded with accumulate + 0.4 . So for the next iteration we have 1.4 +
0.4 which gives 1.8 as our new accumulate value. The addition continues
until the last iteration. This algorithm is inspired from the concept of
exponential weighted moving average used in RMSprop and Adam to optimize
gradient descent.

You can find the old version of the fake news classifier in
ai-dsl/experimental/ai-algorithims/NeuralNets/Lib.idr where as the more
recent version can be found in Lib2.idr of the same directory.

### Future works

I intend to study Idris better to implement the reducer. From my
experience, I can say that the task requires a deeper understanding and
familiarity with the language that I currently do not possess.
Nonetheless, this is definitely something I would be excited to work on
in the future.

## Author

Eman Shemsu Asfaw
