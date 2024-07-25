# AI-DSL

Artificial Intelligence Domain Specific Language (AI-DSL) for
autonomous interoperability between AI services.

## Overview

The general idea of the AI-DSL is to provide

1. A simple and powerful language to express AI service assemblages,
   as well as to formalize mathematical properties, both crisp and
   statistical, to be met by these AI service assemblages.  These
   properties may pertain to algorithmic behaviors, interactions with
   other servies as well as resource usage, computational, financial
   or otherwise.

2. A tool set for not only verifying the validity of such assemblages
   but also automatically create such assemblages.  Basically, if a
   user can formalize precisely enough the desired function, then the
   AI-DSL tool set should be able to automatically fetch and combine
   the right AI services to deliver that function.

## Status

Up to now the work has been mostly exploratory resulting into
prototypes and experimental code covering various aspects of the
AI-DSL as opposed to a final product.  This is justified by the fact
that it is an ambitious project and requires a fair bit of research
and development.

Progress has been taking place into phases.  Details can be found in
technical reports written at the end of each phase.  An overview of is
given below.

### Phase 1

* Overview:
  1. Formalize trivial properties about service resources,
     computational, finantial and performance using
     [Idris](https://www.idris-lang.org/).
  2. Formalize trivial properties of services doing simple arithmetic
     operations using Idris to experiment with dependent type checking
     based service assemblage validation.
  3. Explore existing ontologies such as
     [SUMO](http://www.ontologyportal.org/) to provide a rich
     vocabulary to the AI-DSL.
* [Technical Report of May 2021](doc/technical-reports/2021/ai-dsl-techrep-2021-05_may.pdf)

### Phase 2

* Overview:
  1. Implement the machine algorithms gradient descent, linear and
     logistic regression in Idris.
  2. Formalize and prove a descending property for each algorithm in
     Idris.
  3. Explore program synthesis in various ways, including developing
     our own language framework as well as using existing tools
     provided by Idris.  Program synthesis is important because it is
     the backbone of automated service assemblage.
* [Technical Report of Octover 2022](doc/technical-reports/2022/ai-dsl-techrep-2022-oct.pdf)

## Folder Structure

- `doc`: contain technical reports and other documentation
- `experimental`: contain a number of experiments, ranging from
  representing and proving properties using dependent types,
  performing program synthesis to type checking protobuf
  specifications, and more.
- `ontology`: experiment representing SingularityNET platform
  knowledge in SUO-KIF format.
- `snet-marketplace-space`: scripts to build an atomspace of the
  SingularityNET Marketplace, as well as file dumps in MeTTa and JSON
  formats.

## Further Reading

* [Initial Blog Post](https://blog.singularitynet.io/ai-dsl-toward-a-general-purpose-description-language-for-ai-agents-21459f691b9e)
