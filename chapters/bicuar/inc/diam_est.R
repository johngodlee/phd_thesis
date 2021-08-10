##' @author Casey M. Ryan
##' @param d_in diameter measured at the POM (in cm)
##' @param POM height of the POM (in m)
##' @return d130, estimated diameter at a POM of 1.3 m (in cm). 
POMadj <- function(d_in, POM) {
  d_in_clean <- d_in[!is.na(d_in)]
  POM_clean <- POM[!is.na(d_in)]
  edges <- c(5.0, 15.8, 26.6, 37.4)
  sm <- d_in_clean < edges[2]
  med <- d_in_clean >= edges[2] & d_in_clean < edges[3]
  lg <- d_in_clean >= edges[3]
  delta_d <- data.frame(
    small = 3.4678-5.2428 * POM_clean+2.9401 * 
      POM_clean^2-0.7141 * POM_clean^3,
    med = 4.918-8.819 * POM_clean+6.367 * 
      POM_clean^2-1.871 * POM_clean^3,
    large = 9.474+-18.257 * POM_clean + 12.873 * 
      POM_clean^2+-3.325 * POM_clean^3)
  dd <- NA_real_
  dd[sm] <- delta_d$small[sm]
  dd[med] <- delta_d$med[med]
  dd[lg] <- delta_d$large[lg]
  dd[POM_clean > 1.7] <- 0 
  d130 <- NA
  d130[is.na(d_in)] <- NA
  d130[!is.na(d_in)] <- d_in_clean - dd
  if (any(d130[!is.na(d_in)] < 0)) { 
    warning("Negative d130, replaced with NA") 
  }
  d130[d130 <= 0 & !is.na(d130)] <- NA
  return(d130)
}

