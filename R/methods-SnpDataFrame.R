setMethod(SnpDataFrame, "missing",
          function(x, row.names=NULL, check.names=TRUE,
                   isSnp=logical(nrow(x))){
            tmp=new("SnpDataFrame")
            tmp$isSnp <- logical()
            tmp
          })

#' @aliases SnpGRanges,missing-method
#' @rdname SnpGRanges
setMethod(SnpGRanges, "missing",
          function(object, isSnp){
            cd <- SnpDataFrame()
            g <- new("SnpGRanges")
            mcols(g) <- cd
            g
          })

setMethod(SnpDataFrame, "DataFrame",
          function(x, row.names=NULL, check.names=TRUE, isSnp){
            if(!"isSnp" %in% colnames(x)){
              if(missing(isSnp) && nrow(x) == 0){
                isSnp <- logical(0L)
              } else stop("isSnp must be specified")
              x$isSnp <- isSnp
            }
            as(x, "SnpDataFrame")
          })

#' @aliases SnpGRanges,GRanges-method
#' @rdname SnpGRanges
setMethod(SnpGRanges, "GRanges",
          function(object, isSnp){
            if(!"isSnp" %in% colnames(mcols(object))){
              if(missing(isSnp)){
                if(length(object) > 0) stop("isSnp must be specified")
                object$isSnp <- logical(0L)
              } else object$isSnp <- isSnp
            }
            object@elementMetadata <- SnpDataFrame(mcols(object))
            object2 <- as(object, "SnpGRanges")
            mc <- mcols(object2)
            rownames(mc) <- NULL
            mcols(object2) <- mc
            ##@elementMetadata <- mc
            object2
          })

#' @export
setAs("GenomeAnnotatedDataFrame", "SnpGRanges",
      function(from, to){
        chr <- paste0("chr", integer2chromosome(chromosome(from)))
        gr <- GRanges(chr,
                      IRanges(position(from)-12L,
                              width=25L),
                      isSnp=from$isSnp)
        SnpGRanges(gr)
      })

setMethod(isSnp, "SnpDataFrame", function(object) object$isSnp)

setValidity("SnpDataFrame", function(object){
  msg <- TRUE
  if(!"isSnp" %in% colnames(object))
    return("Missing a column 'isSnp'")
})


setValidity("SnpGRanges", function(object){
  msg <- TRUE
  if(!validObject(mcols(object)))
    return("Missing a column 'isSnp'")
  msg
})
