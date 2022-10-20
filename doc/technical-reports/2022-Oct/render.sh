for i in {1..3}; do
    bibtex ai-dsl-techrep-2022-oct
    pdflatex --synctex=1 -shell-escape ai-dsl-techrep-2022-oct.tex
done
