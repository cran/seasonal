% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/import.spc.R
\name{import.spc}
\alias{import.spc}
\alias{print.import.spc}
\title{Import X-13 \code{.spc} Files}
\usage{
import.spc(file, text = NULL)

\method{print}{import.spc}(x, ...)
}
\arguments{
\item{file}{character, path to the X-13 \code{.spc} file}

\item{text}{character, alternatively, the content of a \code{.spc} file as a character string.}

\item{x}{object of class \code{import.spc}}

\item{...}{further arguments, not used}
}
\value{
returns an object of class \code{import.spc}, which is a list with the following (optional) objects of class \code{call}:
\item{x}{the call to retrieve the data for the input series}
\item{xtrans}{the call to retrieve the data for the \code{xtrans} series (if required by the call)}
\item{xreg}{the call to retrieve the data for the \code{xreg} series (if required by the call)}
\item{seas}{the call to \code{\link[=seas]{seas()}}}
}
\description{
Utility function to import \code{.spc} files from X-13. It generates a list
of calls to \code{seas} (and  \code{import.ts}) that can be run in R.
Evaluating these calls should perform the same X-13 procedure as the original
\code{.spc} file. The \code{print} method displays the calls in a way that
they can be copy-pasted into an R script.
}
\examples{

# importing the orginal X-13 example file
import.spc(text =
'
  series{
    title="International Airline Passengers Data from Box and Jenkins"
    start=1949.01
    data=(
    112 118 132 129 121 135 148 148 136 119 104 118
    115 126 141 135 125 149 170 170 158 133 114 140
    145 150 178 163 172 178 199 199 184 162 146 166
    171 180 193 181 183 218 230 242 209 191 172 194
    196 196 236 235 229 243 264 272 237 211 180 201
    204 188 235 227 234 264 302 293 259 229 203 229
    242 233 267 269 270 315 364 347 312 274 237 278
    284 277 317 313 318 374 413 405 355 306 271 306
    315 301 356 348 355 422 465 467 404 347 305 336
    340 318 362 348 363 435 491 505 404 359 310 337
    360 342 406 396 420 472 548 559 463 407 362 405
    417 391 419 461 472 535 622 606 508 461 390 432)
    span=(1952.01, )
  }
  spectrum{
    savelog=peaks
  }
  transform{
    function=auto
    savelog=autotransform
  }
  regression{
    aictest=(td easter)
    savelog=aictest
  }
  automdl{
    savelog=automodel
  }
  outlier{ }
  x11{}
'
)

\donttest{

### reading .spc with multiple user regression and transformation series

# running a complex seas call and save output in a temporary directory
tdir <- tempdir()
seas(x = AirPassengers, xreg = cbind(a = genhol(cny, start = 1, end = 4,
    center = "calendar"), b = genhol(cny, start = -3, end = 0,
    center = "calendar")), xtrans = cbind(sqrt(AirPassengers), AirPassengers^3),
    transform.function = "log", transform.type = "temporary",
    regression.aictest = "td", regression.usertype = "holiday", dir = tdir,
    out = TRUE)

# importing the .spc file from the temporary location
ll <- import.spc(file.path(tdir, "iofile.spc"))

# ll is list containing four calls:
# - 'll$x', 'll$xreg' and 'll$xtrans': calls to import.ts(), which read the
#   series from the X-13 data files
# - 'll$seas': a call to seas() which performs the seasonal adjustment in R
str(ll)

# to replicate the original X-13 operation, run all four calls in a series.
# You can either copy/paste and run the print() output:
ll

# or use eval() to evaluate the call(s). To evaluate the first call and
# import the x variable:
eval(ll$x)

# to run all four calls in 'll', use lapply() and eval():
ee <- lapply(ll, eval, envir = globalenv())
ee$seas  # the 'seas' object, produced by the final call to seas()
}
}
\seealso{
\code{\link[=import.ts]{import.ts()}}, for importing X-13 data files.

\code{\link[=seas]{seas()}} for the main function of seasonal.
}
