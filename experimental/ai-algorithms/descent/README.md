# Descent

This folder contains a definition of a descent algorithm (a la
gradient descent) and the proof that it descends, that is the output
candidate is either better (has a lower cost) than or equal to the
input candidate.  The definition of that algorithm, called `descent`
and its descending proof, called `descent_le`, can be found in
`Descent.idr`.  A gradient descent algorithm that relies on `descent`
is also defined in `GradientDescent.idr` and used in two examples
`MultivariateLinearRegression.idr` and `LogisticRegression.idr`.
Proofs of descending are provided for these examples as well though
they trivially derive from the proof that `descent` descends.

## Description

In addition it contains a number of simpler algorithms and their
proofs creating a sequence of incrementally more difficult proofs to
resolve, leading to proving that descent descends.

The files are the following, ordered more or less by difficulty:

- `FunEq.idr`: Trivial proof that two functions are equivalent.

- `OrdProofs.idr`: Collection of axioms over ordered types,
  i.e. implementing the Ord interface, about <, <=, >, >=.  Most of
  these axioms are only true if <= is a total order, and <, >, >= are
  defined in the conventional way relative to <=.  For instance, that
  < is the irreflexive kernel of <=, etc.  These axioms are necessary
  because the interface Ord does not come give these guaranties.

- `MinProofs.idr`: Definitions and proofs that the min function
  descends.  It also contains the proof over an n-ary min function
  (minimal element), that uses mapProperty, as defined in
  Data.Vect.Quantifiers to perform a proof by induction under the
  hood.

- `TestRewrite.idr`: Play with rewrite macro over the <= relation.

- `SuperOverSimplifiedDescent.idr`: Break down the descent proof into
  smaller pieces involving the rewrite macro (and a workaround so that
  unification works in spite of the Ord interface requirement).

- `OverSimplifiedDescent.idr`: Simplify the descent algorithm and
  proof such that the candidate is just a cost.  See
  `OverSimplifiedDescent - Whiteboard.jpg` as a helpful whiteboard
  snapshot.

- `Descent.idr`: Full proof that descent descends.  See
  `DescentProof - Whiteboard.jpg` as a helpful whiteboard snapshot.

- `GradientDescent.idr`: Definition of a gradient descent algorithm
  and its proof that it descends.

- `Matrix.idr`: Matrix library used by learning examples below.

- `Utils.idr`: Various miscellaneous functions.

- `MultivariateLinearRegression.idr`: Example of multivariate linear
  regression.

- `LogisticRegression.idr`: Example of logistic regression.

## Usage

To run the various files without having to install the descent package
simply invoke idris2 from that directory as follows

```
idris2 --find-ipkg <IDRIS_FILE>
```

this will look for package in the current or parent directory.  In
that instance the package it will find is `descent` as defined in the
`descent.ipkg` package file.

For instance to run the logistic regression example, type the command

```
idris2 --find-ipkg LogisticRegression.idr
```

Then once in the Idris2 REPL, type

```idris2
:exec test_logreg
```

Beware that this might take a while to complete.
