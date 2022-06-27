FILENAME = main

date = $(shell date +%Y-%m-%d)
output_file = draft_$(date).pdf

figure_src = $(wildcard figures/*.svg figures/*/*.svg figures/*.tex figures/*/*.tex)
figure_list = $(patsubst %.svg,%.pdf,$(patsubst %.tex,%.pdf,$(figure_src)))

# LATEX = lualatex
LATEX = pdflatex

BIBTEX = bibtex

default: slides

figures: $(figure_list)

figures/%.pdf: figures/%.svg
	inkscape -z -D --file=$(basename $@).svg --export-pdf=$(basename $@).pdf

# Target assumes figure source is in same directory as expected figure path
figures/%.pdf: figures/%.tex
	latexmk -$(LATEX) -interaction=nonstopmode -halt-on-error $(basename $@)
	mv $(notdir $(basename $@)).pdf $(basename $@).pdf
	rm $(notdir $(basename $@)).*

slides: figures
	latexmk -$(LATEX) -shell-escape -logfilewarnings -halt-on-error $(FILENAME)
	rsync $(FILENAME).pdf $(output_file)
	rsync $(FILENAME).pdf $(FILENAME)_2022-06-29.pdf

clean:
	rm -f *.aux *.bbl *.blg *.dvi *.idx *.lof *.log *.lot *.toc \
		*.xdy *.nav *.out *.snm *.vrb *.mp \
		*.synctex.gz *.brf *.fls *.fdb_latexmk \
		*.glg *.gls *.glo *.ist *.alg *.acr *.acn

clean_figures:
	rm -f $(figure_list)

clean_drafts:
	rm -f draft_*.pdf

realclean: clean clean_figures
	rm -f *.ps *.pdf

final:
	if [ -f *.aux ]; then \
		$(MAKE) clean; \
	fi
	$(MAKE) figures
	$(MAKE) slides
	$(MAKE) clean
