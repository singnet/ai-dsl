for i in {1..3}; do
    bibtex snet-marketplace-assistant-design
    pdflatex -shell-escape snet-marketplace-assistant-design.tex
done
