% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AllGenerics.R
\name{NA_filter}
\alias{NA_filter}
\alias{NA_filter,SnpArrayExperiment-method}
\alias{NA_filter,character-method}
\alias{NA_filter,list-method}
\alias{NA_filter,numeric-method}
\alias{NA_filter,oligoSnpSet-method}
\title{Remove SNPs with NAs in any of the low-level estimates}
\usage{
NA_filter(x, i)
}
\arguments{
\item{x}{a container for SNP data (\code{\link{SnpArrayExperiment}})}

\item{i}{integer vector to subset}
}
\value{
An object of the same class
}
\description{
Remove SNPs with NAs in any of the low-level estimates
}
