# $Id: Makefile,v 1.19 2018-04-19 14:58:55-07 - - $
# Names: Julius Fan (jzfan), Lucas Simon(lasimon) 

DEPSFILE  = Makefile.deps
NOINCLUDE = ci clean spotless
NEEDINCL  = ${filter ${NOINCLUDE}, ${MAKECMDGOALS}}
SOURCE    = bigint.mli bigint.ml maindc.ml scanner.mll
ALLSRC    = ${SOURCE} dc.ml Makefile
OBJCMI    = bigint.cmi scanner.cmi
MAINCMI   = maindc.cmi
OBJCMO    = ${OBJCMI:.cmi=.cmo} maindc.cmo
CAMLRUN   = ocamldc
LISTING   = Listing.ps

all : ${CAMLRUN}

${CAMLRUN} : ${OBJCMI} ${OBJCMO}
	ocamlc ${OBJCMO} -o ${CAMLRUN}

%.cmi : %.mli
	- checksource $<
	ocamlc -c $<

%.cmo : %.ml
	- checksource $<
	ocamlc -c $<

scanner.cmi scanner.cmo scanner.ml : scanner.mll
	- checksource $<
	ocamllex $<
	ocamlc -c scanner.ml

clean :
	- rm ${OBJCMO} ${OBJCMI} ${MAINCMI} ${DEPSFILE} scanner.ml

spotless : clean
	- rm ${CAMLRUN} ${LISTING} ${LISTING:.ps=.pdf}

ci : ${RCSFILES}
	- checksource ${ALLSRC}
	cid + ${ALLSRC}

deps : ${SOURCE}
	ocamldep ${SOURCE} >${DEPSFILE}

${DEPSFILE} :
	@ touch ${DEPSFILE}
	make --no-print-directory deps

lis : ${ALLSRC}
	mkpspdf ${LISTING} ${ALLSRC} ${DEPSFILE}

again :
	make --no-print-directory spotless ci deps all lis

ifeq (${NEEDINCL}, )
include ${DEPSFILE}
endif
