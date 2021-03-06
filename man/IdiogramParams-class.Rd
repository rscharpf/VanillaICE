% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AllClasses.R, R/methods-IdiogramParams.R
\docType{class}
\name{IdiogramParams-class}
\alias{IdiogramParams-class}
\alias{show,IdiogramParams-method}
\title{Paramater class for plotting idiograms}
\usage{
\S4method{show}{IdiogramParams}(object)
}
\arguments{
\item{object}{an IdiogramParam object}
}
\description{
Paramater class for plotting idiograms
}
\section{Slots}{

\describe{
\item{\code{seqnames}}{length-one character vector providing chromosome name}

\item{\code{seqlengths}}{length-one numeric vector indicating size of chromosome}

\item{\code{unit}}{character string indicating unit for genomic position (default is 'kb')}

\item{\code{genome}}{character string indicating genome build}

\item{\code{box}}{a list of parameters for plotting the box around the part of the idiogram that is plotted.}
}}

\examples{
if(require(BSgenome.Hsapiens.UCSC.hg18) && require(grid)){
   si <- seqinfo(BSgenome.Hsapiens.UCSC.hg18)
   iparam <- IdiogramParams(seqnames="chr1",
                            genome="hg18",
                            seqlengths=seqlengths(si)["chr1"],
                            box=list(xlim=c(20e6L, 25e6L), color="blue", lwd=2))
   iparam
   idiogram <- plot(iparam)
   vp <- viewport(x=0.05, y=0.8, width=unit(0.9, "npc"), height=unit(0.2, "npc"),
                  name="vp1", just=c("left", "bottom"))
   grid.newpage()
   pushViewport(vp)
   print(idiogram, vp=vp, newpage=FALSE)
}

}
