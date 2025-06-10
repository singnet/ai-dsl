for f in *.dot; do
    dot -Tpng "${f}" -o "${f%.dot}.png"
done
