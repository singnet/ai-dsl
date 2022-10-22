# Project Close Report

## A. Name of project and Project URL on Ideascale/Fund

## B. Name of project manager

## C. Date project started

## D. Date project completed

## E. List of challenge KPIs and how the project addressed them

## F. List of project KPIs and how the project addressed them

## G. Key achievements (in particular around collaboration and engagement)

### AI services test case

Initially it was planned to collaborate with the NuNet team to use the
Fake News Network application as a test case for our AI-DSL prototype.
Since the NuNet team abandonned that test case we decided to reorient
our attention to the following three AI algorithms:

1. Gradient Descent
2. Linear Regression
3. Logistic Regression

These algorithms were chosen because they are:

* widely used in real world applications;
* well understood and relatively simple;
* tightly related to each other, thus well suited to form a network of
  AI services.

They were subdivided into five AI services:

1. Descent: generic optimization algorithm.
2. Gradient Descent: gradient-based optimization algorithm, using
   Descent.
3. Linear Regression: optimization algorithm specialized to learning
   multivariate linear models, using Gradient Descent.
4. Logistic Regression: optimization algorithm specialized to learning
   logisitic models, using Gradient Descent.
5. Logistic-Linear Regression: another version of Logistic Regression
   using Linear Regression instead of Gradient Descent.

The dependency graph of these AI services is displayed below:

```
                          Logistic-Linear Regression
                                      ↓
                             Linear Regression
                           ↙
Descent ← Gradient Descent
                           ↖
                             Logistic Regression
```

In addition, a descending property was formulated and formally proved
for each algorithm to test the idea of using formal description for
autonomous interoperability of AI services.  Even though such
descending property was too simple for achieving precise
discriminative pairing (so that only truly compatible services can
connect to each other), the results were already promising,
demonstrating further the soundness and feasablility of the approach.

More information can be found in the Chapter *Implementation and
Verification of AI Algorithms* of the [Technical report][3].

### AI service composition and fuzzy matching

As planned, AI service composition and fuzzy matching (for composing
AI services that almost fit but not quite yet) were explored via the
more generic problem of *Program Synthesis* that theoretically
underpins them.

Three approaches to program synthesis were explored:

1. via developing our own language framework;
2. via using the Idris elaboration and reflection framework
   [Christiansen2016][6];
3. via using the Idris API for interactive type driven programming;
4. via a coevolutionary intelligent agent market simulation in which
   agents categorize themselves into emergent roles needed for program
   synthesis.  The AI-DSL would formally verify whether programs have
   the role requirements after they are induced from the emergent role
   categories.  The agents categorize into emergent roles via a vector
   of floats that form a functional space, which may be used for fuzzy
   matching. [Duong 2018][7].

As program synthesis is a very hard problem, only partial practical
success were achieved, still promising nonetheless.  For instance,
small programs involving a handful of targeted functions were
synthesized.  More information can be found in the Chapter *Program
Synthesis* of the [Technical report][3].

## H. Key learnings

Formalizing and proving the descending property taught us that even
simple properties may require advanced knowledge of mathematics and
logic to be formalized well, and even more so to be proved.  Proof
discovery can be automated in principle, but in practice it often
requires the input of an advanced user.  This has confirmed what we
already suspected, the AI-DSL should be designed to serve two classes
of users, regular and power user.  Whether the interfaces for one or
the other should be fundamentally different, or may simply be obtained
by masking power-user functionalities from the regular user remains to
be determined.

We also discovered that the formal specification of a function should
probably not solely be coded in its type signature.  Even though Idris
allows that (via Dependent Pairs and Subsets), it may not be the most
practical because the set of properties that is required to take into
consideration for a given set of services to get connected is usually
not known until these services are attemped to be connected.  In other
words, the proof that an AI service assemblage is correct is likely to
be specific to that particular assemblage.

Also as already suspected, program synthesis, which underpins so many
functions of the AI-DSL, such as automated composition, fuzzy
matching, proof discovery and more, is expected to require ongoing
development, possibly for the entire lifetime of the AI-DSL, until
essentially, the AI-DSL and SingularityNET have become intelligent
enough to take over that task.  But this is consistent with the idea
that, the ultimate destination of this endeavor is the making of an
autonomous, decentralized artificial AI researcher.

## I. Next steps for the product or service developed

It should be noted that all that work was exclusively prototyped in
Idris, and no AI services were deployed on SingularityNET during that
phase.  This is the very next step we expect to take.  More
specifically:

* Wrap these 5 AI services in actual SingularityNET services.
* Build upon the AI-DSL Registry prototype of the previous phase to
  compose, or verify compositions of, these services.
* Formalize and prove more properties over these AI services.

Other steps, that may possibly take place during the next phase if
time permits, include:

* Define the syntax of the AI-DSL language (as opposed to using pure
  Idris) taking into account the dichotomy between regular and power
  user.
* Explore seamless integration of crisp mathematical properties and
  uncertain, empirically based ones.  Existing framework such as the
  Probabilistic Logic Network may be used for that [Goertzel2008][5].
* Integrate properties pertaining to run-time performances and
  hardware considerations.  This was explored during the previous
  phase [Geisweiller2021][4] and should be eventually brought back.

## J. Final thoughts/comments

TODO

## K. Links to other relevant project sources or documents. Please also include a link to your video here.

### Video, repository and report

[1]: [Video demo]()

[2]: [Project repository](https://github.com/singnet/ai-dsl)

[3]: [Technical report](https://raw.githubusercontent.com/singnet/ai-dsl/master/doc/technical-reports/2022-Oct/ai-dsl-techrep-2022-oct.pdf)

### Other References

[4]: AI-DSL Technical Report, February to May 2021, Nil Geisweiller, Kabir Veitas, Eman Shemsu Asfaw, Samuel Roberti, Matthew Ikle, Ben Goertzel. https://github.com/singnet/ai-dsl/blob/master/doc/technical-reports/2021-May/ai-dsl-techrep-2021-05_may.pdf

[5]: Probabilistic Logic Networks: A Comprehensive Framework for Uncertain Inference, Ben Goertzel, Matthew Iklé, Izabela Freire Goertzel, Ari Heljakka.

[6]: Elaborator reflection: extending Idris in Idris, David Christiansen and Edwin Brady In proceedings of ICFP 2016.

[7]: SingularityNET’s First Simulation is Open to the Community. Deborah Duong, 2018, https://blog.singularitynet.io/singularitynets-first-simulation-is-open-to-the-community-37445cb81bc4
