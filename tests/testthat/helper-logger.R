TestAtLogLevel <- function(chrLevel = "FATAL", envir = rlang::caller_env()) {
  lvlStart <- gsm.core::GetLogLevel()
  withr::defer(gsm.core::SetLogLevel(lvlStart), envir = envir)
  gsm.core::SetLogLevel(toupper(chrLevel))
  local_quiet_workr(envir = envir)
}

# WORKAROUND: workr's internal LogMessage() emits unconditionally, ignoring the
# gsm.core log level. Swap in a level-aware version for the calling scope.
# Remove once fixed upstream.
quiet_workr_log_message <- function(
  level = "info",
  message,
  cli_detail = NULL
) {
  vRank <- c(FATAL = 1, ERROR = 2, WARN = 3, INFO = 4, DEBUG = 5, TRACE = 6)
  nMsg <- vRank[[toupper(level)]]
  nMax <- vRank[[toupper(gsm.core::GetLogLevel())]]
  if (nMsg > nMax) {
    return(invisible(NULL))
  }
  msg <- glue::glue(message, .envir = parent.frame())
  message("[", toupper(level), "] ", msg)
}

local_quiet_workr <- function(envir = rlang::caller_env()) {
  testthat::local_mocked_bindings(
    LogMessage = quiet_workr_log_message,
    .package = "workr",
    .env = envir
  )
}

# Run `expr` with all workr/gsm logging and warnings silenced (for fixtures).
quietly_run <- function(expr) {
  TestAtLogLevel("FATAL")
  suppressWarnings(suppressMessages(expr))
}
