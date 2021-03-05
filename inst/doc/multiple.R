## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  results='hide'
)

## -----------------------------------------------------------------------------
library(seasonal)
m <- seas(cbind(fdeaths, mdeaths), x11 = "")
final(m)

## -----------------------------------------------------------------------------
seas(cbind(fdeaths, mdeaths), list = list(x11 = ""))

## -----------------------------------------------------------------------------
seas(
  cbind(fdeaths, mdeaths),
  list = list(
    list(x11 = ""),
    list()
  )
)

## -----------------------------------------------------------------------------
seas(
  cbind(fdeaths, mdeaths),
  regression.aictest = NULL,
  list = list(
    list(x11 = ""),
    list()
  )
)

## -----------------------------------------------------------------------------
seas(list(mdeaths, AirPassengers))

## -----------------------------------------------------------------------------
seas(
  list = list(
    list(x = mdeaths, x11 = ""),
    list(x = fdeaths)
  )
)

## -----------------------------------------------------------------------------
seas(cbind(fdeaths, mdeaths), multimode = "x13")
seas(cbind(fdeaths, mdeaths), multimode = "R")

## -----------------------------------------------------------------------------
seas(
  cbind(mdeaths, fdeaths),
  composite = list(),
  series.comptype = "add"
)

## -----------------------------------------------------------------------------
seas(ldeaths)

