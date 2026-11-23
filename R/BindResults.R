#' Helper function to bind results from multiple workflows
#'
#' @description
#' `r lifecycle::badge("stable")`
#'
#' Used to stack results (e.g. `dfSummary`) from a list of analysis pipeline
#' output formatted like the result of [workr::RunWorkflows()]. Also adds study
#' level metadata when provided. Metrics that do not contain `strName` are
#' skipped and listed in an info-level log message; if none do, a zero-row
#' data frame with the metadata columns is returned.
#'
#' @param lAnalysis Named List of analysis results in the format returned by
#'   [workr::RunWorkflows()].
#' @param strName Name of the object to stack. Pulled from `lAnalysis` (or from
#'   `lAnalysis$lData` when `bUselData` is `TRUE`).
#' @param dSnapshotDate Date of the snapshot. Default is [Sys.Date()].
#' @param strStudyID Study ID.
#' @param bUselData Should the function bind results from an `lData` object (or
#'   look directly in the root elements of `lAnalysis`)? Default is `FALSE.`
#'
#' @return A data frame.
#'
#' @export

BindResults <- function(
  lAnalysis,
  strName,
  dSnapshotDate = Sys.Date(),
  strStudyID = NULL,
  bUselData = FALSE
) {
  lResults <- lAnalysis %>%
    purrr::imap(
      function(result, metric) {
        if (bUselData) {
          subResult <- result$lData[[strName]]
        } else {
          subResult <- result[[strName]]
        }
        if (is.null(subResult)) {
          return(NULL)
        }
        return(subResult %>% dplyr::mutate(MetricID = metric))
      }
    )

  strSkipped <- names(lResults)[purrr::map_lgl(lResults, is.null)]
  if (length(strSkipped) > 0) {
    LogMessage(
      level = "info",
      message = "`{strName}` not found for {length(strSkipped)} metric(s); skipped: {glue::glue_collapse(strSkipped, sep = '; ')}.",
      cli_detail = "inform"
    )
  }

  dfResults <- purrr::list_rbind(lResults)

  if (ncol(dfResults) == 0) {
    dfResults <- tibble::tibble(MetricID = character())
  }

  # If NULL or the placeholder string was passed in, use Sys.Date()
  if (
    is.null(dSnapshotDate) ||
      (is.character(dSnapshotDate) && dSnapshotDate == "dSnapshotDate")
  ) {
    dfResults$SnapshotDate <- Sys.Date()
  } else {
    dfResults$SnapshotDate <- as.Date(dSnapshotDate)
  }

  if (!is.null(strStudyID)) {
    dfResults$StudyID <- strStudyID
  }

  return(dfResults)
}
