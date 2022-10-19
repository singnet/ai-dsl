# Descent

## Overview

This folder contains a definition of a descent algorithm (a la
gradient descent) and the proof that it descends, that is the output
candidate is either better (has a lower cost) than or equal to the
input candidate.

The definition of that algorithm, called `descent` and its proof,
called `descent_le`, can be found in `Search/Descent.idr`.

A gradient descent algorithm that relies on `descent` is also defined
in `Search/GradientDescent.idr` and used to define two algorithms,
linear and logistic regression used in `Examples/LinearRegression.idr`
and `Examples/LogisticRegression.idr`.  A third example in
`Examples/LogisticToLinearRegression.idr` solving logistic regression
by mapping the problem into a linear regression one is provided as
well.  The idea being that an effective AI services composer would be
able to discover such alternate way to solve that problem.

Proofs of descending are provided for all of these algorithms, even
though they trivially derive from the proof that `descent` descends.
The descending proof of `descent` itself is not trivial, though still
relatively easy.

## Content

In addition it contains a number of simpler algorithms and their
proofs creating a sequence of incrementally more difficult proofs to
resolve, leading to proving that descent descends, as well as couple
libraries about matrix manipulation and such.

Here is the detail of the folders and their files:

- `Data` contains:
  - `Matrix.idr`: a matrix library used by linear and logistic regression.
  - `Counter.idr`: a counter library similar to collections.Counter
    from Python.

- `Debug` contains `NoTrace.idr`, a drop-in replacement for
  `Debug.Trace` from the standard library but that does not trace
  anything.  Unfortunately it is too inefficient.

- `Examples` contains:
  - `LinearRegression.idr`: Example of multivariate linear regression.
  - `LogisticRegression.idr`: Example of logistic regression.
  - `LogisticLinearRegression.idr`: Example of solving a logistic
    regression problem by mapping it into a linear regression.

- `Experiments` contains a collections of experiments to learn about
  Idris and its proof system, in particular:
  - `FunEq.idr`: Trivial proof that two functions are equivalent.
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

- `Search` contains:
  - `OrdProofs.idr`: Collection of axioms over ordered types,
    i.e. implementing the Ord interface, about <, <=, >, >=.  Most of
    these axioms are only true if <= is a total order, and <, >, >=
    are defined in the conventional way relative to <=.  For instance,
    that < is the irreflexive kernel of <=, etc.  These axioms are
    necessary because the interface Ord does not come give these
    guaranties.
  - `Descent.idr`: Full proof that descent descends.  See
    `DescentProof - Whiteboard.jpg` as a helpful whiteboard snapshot.
  - `GradientDescent.idr`: Definition of a gradient descent algorithm
    and its proof that it descends.
  - `Util.idr`: a number of utility functions used by the various
    algorithms.
  - `Regression`: a folder containing:
    - `Linear.idr`: linear regression algorithm and the proof that it
      descends.
    - `Logistic.idr`: logistic regression algorithm and the proof that
      it descends.
    - `LogisticLinear.idr`: logistic regression algorithm reframed as
      linear regression and the proof that it descends.

## Usage

All operations take place within the current directory (the one that
README.md is in).

1. Build the descent package

```bash
idris2 --build descent.ipkg
```

2. To run the various files within that package without having to
   install anything simply invoke idris2 with the `--find-ipkg`
   command argument, as follows

```bash
idris2 --find-ipkg <IDRIS_FILE>
```

this will look for any package in the current or parent directory,
here `descent`.

For instance to run the logistic regression example, type the command

```bash
idris2 --find-ipkg Examples/LogisticRegression.idr
```

Then once in the Idris2 REPL, type

```idris2
:exec test_logreg
```

Beware that this one takes a while to complete, for a quick example try

```bash
idris2 --find-ipkg Examples/LinearRegression.idr
```

Then once in the Idris2 REPL, type

```idris2
:exec test_linreg
```
