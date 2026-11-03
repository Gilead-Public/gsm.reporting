#' Filter by latest snapshot date
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Filter a data frame to the most recent snapshot date, or to a specified
#' snapshot date.
#'
#' @param df (`data.frame`) Data with a `SnapshotDate` column. If `df` has no
#'   rows, or has no `SnapshotDate` column and `strSnapshotDate` is `NULL`, `df`
#'   is returned unchanged.
#' @param strSnapshotDate (`length-1 character`) Snapshot date to filter to.
#'   Defaults to the maximum `SnapshotDate` in `df`.
#'
#' @returns `df`, filtered to rows from the selected snapshot date, with
#'   `SnapshotDate` converted to `Date`.
#'
#' @examples
#' reportingResults_latest <- FilterByLatestSnapshotDate(
#'   gsm.core::reportingResults
#' )
#'
#' @export
FilterByLatestSnapshotDate <- function(df, strSnapshotDate = NULL) {
  if (!nrow(df)) {
    return(df)
  }
  if (!length(df$SnapshotDate)) {
    if (length(strSnapshotDate)) {
      arg_name <- rlang::caller_arg(df)
      LogMessage(
        level = "fatal",
        message = "`{arg_name}` must contain a `SnapshotDate` column."
      )
    }
    return(df)
  }
  strSnapshotDate <- as.Date(strSnapshotDate) %|0|% max(df$SnapshotDate)
  df$SnapshotDate <- as.Date(df$SnapshotDate)
  return(dplyr::filter(df, .data$SnapshotDate == strSnapshotDate))
}

`%|0|%` <- function(x, y) {
  if (length(x)) {
    return(x)
  } else {
    return(y)
  }
}
