.test_hmm_oligoSnpSetWithBAFs <- function(){
  ## Results are sensitive to the seed, and differs between the unit test and my
  library(oligoClasses)
  states <- as.integer(c(3, 4, 3, 5, 3, 2, 3, 3, 2, 3, 2, 3))
  nmarkers <- as.integer(c(996, 102, 902, 50, 2467, 102, 76, 1822,
                           99, 900, 20, 160))
  statepath <- rep(states, nmarkers)
  if(FALSE){
    oligoset <- VanillaICE:::artificialData(states, nmarkers)
    save(oligoset, file="~/Software/VanillaICE/inst/extdata/oligosetForUnitTest.rda")
  } else {
    path <- tryCatch(system.file("extdata", package="VanillaICE", mustWork=TRUE), error=function(e) NULL)
    if(is.null(path)) path <- "~/Software/VanillaICE/inst/extdata"
    load(file.path(path, "oligosetForUnitTest.rda"))
  }
  ## produces an error -- can't find replacement method for baf
  copyNumber(oligoset)[c(5, 6), ] <- NA
  fit <- hmm(oligoset, is.log=FALSE,
             TAUP=1e10,
             p.hom=1,
             cnStates=c(0.5, 1.5, 2, 2, 2.5, 3.2))
  checkEquals(state(fit[[1]]), states)
  checkEquals(coverage2(fit[[1]]), nmarkers, tolerance=0.02)
  if(FALSE){
    library(IRanges)
    library(Biobase)
    rect2 <- function(object){
      object <- object[state(object) !=3 , ]
      object <- object[order(width(object), decreasing=TRUE), ]
      rect(xleft=start(object)/1e6,
           xright=end(object)/1e6,
           ybottom=rep(0.7,length(object)),
           ytop=rep(1,length(object)),
           col=(1:3)[as.integer(as.factor(state(object)))],
           border=(1:3)[as.integer(as.factor(state(object)))])
    }
    franges <- makeFeatureGRanges(oligoset)
    olaps <- lapply(fit, findOverlaps, subject=franges)
    plot(position(oligoset)/1e6, copyNumber(oligoset)/100, pch=".", col="black")
    ##trace(rect2, browser)
    rect2(fit[[1]])
    rect2(res2[[1]])
    plot(position(oligoset)/1e6, baf(oligoset)/1000, pch=".", col="black")
    rect2(fit)
  }
  res2 <- hmm(object=oligoset, is.log=FALSE, p.hom=0,
              cnStates=c(0.5, 1, 2, 2, 3, 3.5),
              TAUP=1e10,
              prOutlierBAF=list(initial=1e-4, max=1e-3, maxROH=1e-5))
  nmarkers2 <- nmarkers[-c(1,2)]
  nmarkers2[1] <- sum(nmarkers[1:3])
  checkEquals(numberProbes(res2[[1]]), nmarkers2, tolerance=0.02)
}

test_hmm_cnset <- function(){
  library(VanillaICE)
  library(oligoClasses)
  library(Biobase)
  library(foreach);registerDoSEQ()
  require(crlmm)
  data(cnSetExample, package="crlmm")
  if(FALSE){
    cnSetExample@genome <- "hg19"
    save(cnSetExample, file="~/Software/crlmm/data/cnSetExample.rda")
  }
  ##brList <- BafLrrSetList(cnSetExample)
  se <- as(cnSetExample, "SnpArrayExperiment")
  se <- sort(se)
  param <- EmissionParam(temper=1/2, p_outlier=1/100)
  res <- hmm2(se[, 1], param)
  g <- cnvFilter(res, FilterParam(state=c("1", "2", "5", "6"), numberFeatures = 5))
  g <- reduce(g, min.gapwidth=500e3)
  query <- GRanges("chr8", IRanges(3.7e6,3.8e6))
  i <- subjectHits(findOverlaps(query, se, maxgap=500e3))
  j <- subjectHits(findOverlaps(query, g))
  if(FALSE){
    plot(start(se)[i], lrr(se)[i, 1], pch=20, ylim=c(-1,1))
    abline(v=c(start(query), end(query)))
    plot(start(se)[i], lrr(se)[i, 2], pch=20, ylim=c(-1,1))
    abline(v=c(start(query), end(query)))
  }
  checkTrue(state(g)[j]==5)
  checkEquals(as.integer(numberFeatures(g)[j]), 776L, tolerance=5)
}


.test_hmm_genotypesOnly <- function(){
  library(IRanges)
  states <- as.integer(c(3, 4, 3, 5, 3, 2, 3, 3, 2, 3, 2, 3))
  nmarkers <- as.integer(c(996, 102, 902, 50, 2467, 102, 76, 1822,
                           99, 900, 20, 160))
  statepath <- rep(states, nmarkers)
  states2 <- ifelse(states==c(2,4), 2L, 1L)
  states2 <- c(1,2,1,2,1,1,2,1)
  path <- system.file("extdata", package="VanillaICE")
  load(file.path(path, "oligosetForUnitTest.rda"))
  snpSet <- as(oligoset, "SnpSet2")
  res <- hmm(snpSet, S=2L, prGtHom=c(0.7, 0.99), normalIndex=1L,
             TAUP=1e10)
  checkEquals(state(res[[1]]), states2)

  ## test ICE hmm
  ## annotation package not supported
  ##  library(Biobase)
  ##  checkException(hmm(snpSet, S=2L, ICE=TRUE, normalIndex=1L, TAUP=1e10))
  ##  annotation(snpSet) <- "genomewidesnp6Crlmm"
  ##  snpCallProbability(snpSet)[c(1049,1050)] <- p2i(0.5)
  ##  fit <- hmm(snpSet, S=2L, ICE=TRUE, normalIndex=1L, TAUP=1e10)[[1]]
  ##  stop(" what is the expectation ")
}



## test_oligoSnpSetGT <- function(){
##   library(VanillaICE);library(RUnit)
##   library(oligoClasses)
##   library(Biobase)
##   data(oligoSetExample, package="oligoClasses")
##   oligoSet <- oligoSet[chromosome(oligoSet) == 1, ]
##   hmmResults <- hmm(oligoSet, p.hom=0, TAUP=1e10, is.log=FALSE)
##   if(FALSE){
##     library(IRanges)
##     library(Biobase)
##     rect2 <- function(object){
##       object <- object[order(width(object), decreasing=TRUE), ]
##       rect(xleft=start(object)/1e6,
##            xright=end(object)/1e6,
##            ybottom=rep(-1,length(object)),
##            ytop=rep(-0.8,length(object)),
##            col=c("grey0","grey30", "white", "lightblue", "blue", "blue")[state(object)],
##            border=c("grey0","grey30", "white", "lightblue", "blue")[state(object)])
##     }
##     franges <- makeFeatureGRanges(oligoSet)
##     olaps <- lapply(hmmResults, findOverlaps, subject=franges)
##     par(las=1)
##     plot(position(oligoSet)/1e6, copyNumber(oligoSet)/100, pch=21, cex=0.6,
##          col=c("lightblue", "red", "lightblue")[calls(oligoSet)],
##          bg=c("lightblue", "red", "lightblue")[calls(oligoSet)],
##          xlab="position (Mb)", ylab="log2 copy number")
##     rect2(hmmResults[[1]])
##   }
##   hmmResults <- hmmResults[[1]]
##   index <- subjectHits(findOverlaps(GRanges("chr1", IRanges(70.1e6, 73e6)), hmmResults))
##   checkTrue(state(hmmResults)[index] >= 5)
## }

test_state4 <- function(){
  library(VanillaICE)
  library(oligoClasses)
  library(Biobase)
  data(oligoSetExample, package="oligoClasses")
  oligoSet <- oligoSet[chromosome(oligoSet) == 1, ]
  rd <- GRanges(paste0("chr", chromosome(featureData(oligoSet))),
                IRanges(position(oligoSet), width=1))
  cn <- copyNumber(oligoSet)/100
  cn <- log2((2^cn)/2)
  gt <- calls(oligoSet)[,]
  bf <- rep(NA, length(gt))
  u <- runif(length(gt))
  bf[gt==1 & u > 0.5] <- runif(sum(gt==1 & u > 0.5), 0, 0.05)
  bf[gt==1 & u <= 0.5] <- runif(sum(gt==1 & u <= 0.5), 0.95, 1)
  bf[gt==2] <- runif(sum(gt==2), 0.45, 0.55)
  ##bf[1049:1050] <- runif(2, 0, 0.03)
  bf[900:1200] <- runif(length(900:1200), 0, 0.03)
  cn <- as.matrix(cn)
  bf <- as.matrix(bf)
  dimnames(cn) <- dimnames(bf) <- list(featureNames(oligoSet), sampleNames(oligoSet))
  se <- SnpArrayExperiment(cn=cn,
                           baf=bf,
                           rowRanges=rd,
                           isSnp=rep(TRUE, length(rd)))
  fit <- hmm2(se)
  checkTrue(!any(state(fit[[1]])==4))

  eparam <- EmissionParam(modelHomozygousRegions=TRUE)
  fit2 <- hmm2(se, eparam)
  checkTrue(state(fit2[[1]])[2]==4)
}
