#' Create randomized residuals and observations for data sets that have some censored data
#'
#'  This function is used to add two columns to the Sample data frame: rResid and rObserved.
#'  rResid is the randomized residual value computed in log concentration units, and rObserved
#'  is the randomized 'observed' value of concentration in concentration units.
#'  Both of these are computed for all censored samples ("less than values").
#'
#' @param eList named list with at least the Sample dataframe
#' @keywords water-quality statistics
#' @examples 
#' choptankAugmented <- makeAugmentedSample(Choptank_eList)
#' @export
#' @return eList named list with modified Sample data frame.
makeAugmentedSample <- function(eList){
  
  if(all(c("SE","yHat") %in% names(eList$Sample))){
    localSample <- eList$Sample
    numSamples <- length(localSample$Uncen)
    a <- ifelse(localSample$Uncen==0&!is.na(localSample$ConcLow),log(localSample$ConcLow)-localSample$yHat,-Inf)
    b <- ifelse(localSample$Uncen==1,+Inf,log(localSample$ConcHigh) - localSample$yHat)
    mean <- ifelse(localSample$Uncen==1,log(localSample$ConcHigh) - localSample$yHat,0)
    sd <- ifelse(localSample$Uncen==1,0,localSample$SE)
    localSample$rResid <- truncnorm::rtruncnorm(numSamples,a,b,mean,sd)
    localSample$rObserved <- exp(localSample$rResid + localSample$yHat)
    
    eList	<- as.egret(eList$INFO, eList$Daily, localSample, eList$surfaces)
  } else {
    message("Pseudo only supported after running modelEstimation")
  }
  return(eList)
}
