all: architecture.pdf

clean:
	rm -rf *.pdf *.aux *.log *.png

architecture.pdf: architecture.tex
	pdflatex $^ -o $@

architecture.png: architecture.pdf
	pdftoppm $^ | pnmtopng > $@	
