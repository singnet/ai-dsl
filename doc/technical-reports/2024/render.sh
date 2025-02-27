for i in {1..3}; do
    bibtex ai-dsl-techrep-2024
    pdflatex --synctex=1 -shell-escape ai-dsl-techrep-2024.tex
done
