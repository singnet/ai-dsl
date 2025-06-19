for i in {1..3}; do
    bibtex ai-dsl-techrep-2024
    lualatex --synctex=1 -shell-escape ai-dsl-techrep-2024.tex
done
