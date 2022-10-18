# Program synthesis via Idris proof search

Since recently, Idris2 has introduced a form of program synthesis,
albeit with important limitations.  In these experiments we explore
how to use this functionality.

## Requirements

We recommend to access Idris2 proof search via the idris2-lsp server,
see https://github.com/idris-community/idris2-lsp.

Otherwise you may still use the `:ps` and `:psnext` meta-command of
the REPL, but they are, as of 2022-10-18, somewhat buggy.  See
https://github.com/idris-lang/Idris2/issues/2711 for more info.

We also recommend that you use a fairly recent version of Idris2.  The
one used in these experiments is obtained directly by compiling the
head of Idris2 from https://github.com/idris-lang/Idris2, revision
6823915dd to be precise.  Any existing releases, as of today, do not
support proof search.

## Content

The main limitation of Idris proof search is that it does not have
access to the data structures and the functions defined in the current
module or imported modules.  In order to work around that we have
tried 3 different approaches, 2 successful, 1 not.

The following approaches can be found in the following files:

1. `PSAST.idr`: using Abstract Syntax Trees to represent programs,
   functions can be placed directly in such AST definition and Idris2
   can uses these to synthesize programs.

2. `PSVar.idr`: representing functions as variables, a function can be
   described as its type definition (which should be enough given the
   powerful type system of Idris), and Idris can combine these
   variables to synthesize programs.

3. `PSLet.idr`: the idea was to use `let` to expend the scope of proof
   search beyond constructors and variables, but it did not work.

## Usage

### With the Idris LSP server (recommended)

Point to the hole to fill and call the LSP code action

```
Expression search
```

How to do that precisely depends on your IDE.

### With the REPL (not recommended)

Load the file in the Idris2 REPL and call

```
:ps HOLE_LINE_NUMBER HOLE_NAME
```

to get the first candidate.  Then call

```
:psnext
```

to get subsequent candidates, but it may not work.
