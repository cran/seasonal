% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/update.R
\name{update.seas}
\alias{update.seas}
\title{Update and Re-evaluate a Seasonal Adjustment Model}
\usage{
\method{update}{seas}(object, ..., evaluate = TRUE)
}
\arguments{
\item{object}{an object of class \code{"seas"}, usually, a result of a
call to \code{\link[=seas]{seas()}}.}

\item{...}{spec-argument options sent to X-13 (with the same
syntax as in \code{\link[=seas]{seas()}})}

\item{evaluate}{logical. If \code{TRUE}, the call is evaluated.}
}
\value{
Object of class \code{"seas"}. Or an object of class \code{"call"}
if \code{evaluate = FALSE}.
}
\description{
Method to update and re-evaluate an object of class \code{"seas"}.
}
\details{
Contrary to the default method of \code{\link[=update]{update()}}, the  \code{"seas"}
method uses the evaluated call, rather than the actual call for re-
evaluation. This means you can savely use it in other functions, which
is useful with \code{\link[=lapply]{lapply()}} and friends (see examples.)
}
\examples{
\donttest{
# updating the call
m <- seas(AirPassengers)
update(m, x11 = "")
update(m, x = sqrt(AirPassengers), x11 = "")

# 'update' can be also used with lapply (or mapply)

# a list of time series
dta <- list(fdeaths = fdeaths, mdeaths = mdeaths)

# use 'seas' via lapply
ll <- lapply(dta, seas, x11 = "")

# use 'update' via lapply
lapply(ll, update, arima.model = c(0, 1, 1, 0, 1, 1))
}
}
\seealso{
\code{\link[=seas]{seas()}} for the main function.

\code{\link[=static]{static()}}, to return the (optionally evaluated) static
call of a \code{"seas"} object.
}
