for i in {1..3}; do
    bibtex ai-dsl-techrep-2021-05_may
    pdflatex -shell-escape ai-dsl-techrep-2021-05_may.tex
done
