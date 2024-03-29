#' Check Installation of X-13ARIMA-SEATS
#'
#' Check the installation of the binary executables of X-13ARIMA-SEATS. See
#' [seasonal()] for details on how to set `X13_PATH` manually if
#' you intend to use your own binaries.
#'
#' @param fail  logical, whether an error should interrupt the process. If
#'   `FALSE`, a message is returned.
#' @param fullcheck  logical, whether a full test should be performed. Runs
#'   `Testairline.spc` (which is shiped with X-13ARIMA-SEATS) to test the
#'   working of the binaries. Returns a message.
#' @param htmlcheck  logical, whether the presence of the the HTML version of
#'   X-13 should be checked.
#' @examples
#' old.path <- Sys.getenv("X13_PATH")
#' Sys.setenv(X13_PATH = "")  # its broken now
#' try(checkX13())
#'
#' # fix it (provided it worked in the first place)
#' if (old.path == "") {
#'   Sys.unsetenv("X13_PATH")
#' } else {
#'   Sys.setenv(X13_PATH = old.path)
#' }
#' try(checkX13())
#' @export
checkX13 <- function(fail = FALSE, fullcheck = TRUE, htmlcheck = TRUE){

  if (fullcheck){
    if (identical(get_x13_path(), (x13binary::x13path()))){
      message("seasonal is using the X-13 binaries provided by x13binary")
    }
  }

  ### check path
  no.path.message <- "No path to the binary executable of X-13 specified.\n\nYou can set 'X13_PATH' manually if you intend to use your own\nbinaries. See ?seasonal for details.\n"
  x13_path <- get_x13_path()

  if (x13_path == ""){
    if (fail){
      message(no.path.message)
      stop("Process terminated")
    } else {
      packageStartupMessage(no.path.message)
      return(invisible(NULL))
    }
  }

  ### check validity of path
  if (!file.exists(x13_path)){
    invalid.path.message <- paste0("Path '", x13_path, "' specified but does not exists.")
    if (fail){
      message(invalid.path.message)
      stop("Process terminated")
    } else {
      packageStartupMessage(invalid.path.message)
      return(invisible(NULL))
    }
  }

  ### check existence of binaries
  # platform dependent binaries
  if (.Platform$OS.type == "windows"){
    x13.bin <- file.path(x13_path, "x13as.exe")
    x13.bin.html <- file.path(x13_path, "x13ashtml.exe")
  } else {
    x13.bin <- file.path(x13_path, "x13as")
    # ignore case on unix to avoid problems with different binary names
    fl <- list.files(x13_path)
    fn <- fl[grepl("^x13ashtml$", fl, ignore.case = TRUE)]
    if (length(fn) > 0){
      x13.bin.html <- file.path(x13_path, fn)
    } else {
      x13.bin.html <- file.path(x13_path, "x13ashtml")
    }
  }
  no.file.message <- paste("Binary executable file", x13.bin, "or", x13.bin.html, "not found.\nSee ?seasonal for details.\n")

  if (!(file.exists(x13.bin) | file.exists(x13.bin.html))){
    if (fail){
      message(no.file.message)
      stop("Process terminated")
    } else {
      packageStartupMessage(no.file.message)
      return(invisible(NULL))
    }
  }

  ### set html mode
  if (file.exists(file.path(x13.bin.html))){
    options(htmlmode = 1)
  } else {
    options(htmlmode = 0)
  }

  ### full working test
  if (fullcheck){
    has.failed <- FALSE
    message("X-13 installation test:")
    message("  - X13_PATH correctly specified")
    message("  - binary executable file found")

    if (.Platform$OS.type == "windows"){
      if (getOption("htmlmode") == 1){
        x13.bin <- paste0("\"", file.path(x13_path, "x13ashtml.exe"), "\"")
      } else {
        x13.bin <- paste0("\"", file.path(x13_path, "x13as.exe"), "\"")
      }
    } else {
      if (getOption("htmlmode") == 1){
        # ignore case on unix to avoid problems with different binary names
        fl <- list.files(x13_path)
        x13.bin <- file.path(x13_path, fl[grepl("^x13ashtml$", fl, ignore.case = TRUE)])
      } else {
        x13.bin <- file.path(x13_path, "x13as")
      }
    }

    # X-13 command line test run
    wdir <- file.path(tempdir(), "x13")
    if (!file.exists(wdir)){
      dir.create(wdir)
    }
    file.remove(list.files(wdir, full.names = TRUE))
    testfile <- system.file("tests", "Testairline.spc", package="seasonal")
    file.copy(testfile, wdir)
    try(x13_run(file.path(wdir, "Testairline"), out = TRUE), silent = TRUE)

    if (file.exists(file.path(wdir, "Testairline.out")) | file.exists(file.path(wdir, "Testairline.html"))){
      message("  - command line test run successful")
      if (file.exists(file.path(wdir, "Testairline.html"))){
        message("  - command line test produced HTML output")
      }
    } else {
      message("\nError : X-13 command line test run failed. To debug, try running the binary file directly in the terminal. Try using it with Testairline.spc which is part of the program package by the Census Office.")
      if (.Platform$OS.type != "windows"){
        message("Perhaps it is not executable; you can make it executable with 'chmod +x ", x13.bin, "', using the terminal.")
      }
      has.failed <- TRUE
    }

    # seasonal test run
    m <- try(seas(datasets::AirPassengers), silent = TRUE)
    if (inherits(m, "seas")){
      message("  - seasonal test run successful")
    } else {
      message("\nError : seasonal test run failed, with the message:\n", m)
      has.failed <- TRUE
    }

    if (has.failed){
      message("\nError details:")
      message("  - X13_PATH:         ", get_x13_path())
      message("  - Full binary path: ", x13.bin)
      message("  - Platform:         ", R.version$platform)
      message("  - R-Version:        ", R.version$version.string)
      message("  - seasonal-Version: ", as.character(packageVersion("seasonal")), "\n")
    } else {
      message("Congratulations! 'seasonal' should work fine!")
    }
  }

  ### check HTML mode
  if (htmlcheck){
    if ((getOption("htmlmode") == 0)){
      if (.Platform$OS.type == "windows"){
        packageStartupMessage("\nseasonal now supports the HTML version of X13, which offers a more\naccessible output via the out() function. For best user experience, \ndownload the HTML version from:",
                              "\n\n  https://www.census.gov/data/software/x13as.X-13ARIMA-SEATS.html\n\n",
                              "and copy x13ashtml.exe to:\n\n",
                              "  ", x13_path)
      } else {
        packageStartupMessage("\nseasonal now supports the HTML version of X13, which offers a more \naccessible output via the out() function. For best user experience, \ncopy the binary executables of x13ashtml to:\n\n",
                              "  ", x13_path)
      }
    }
  }

  unlink(list.files(tempdir(), pattern = "Testairline.*", full.names = TRUE))

  invisible()

}

get_x13_path <- function() {
  env_path <- Sys.getenv("X13_PATH")
  if (env_path != "") {
    return(env_path)
  }
  x13binary::x13path()
}
