#' Calculate Change
#'
#' Calculate the change of user-specified metrics from the previous snapshot date.
#' The primary use case of this function is to check for changes in the metrics when determining if
#' continued flags should be actioned.
#'
#' @param dfResults `data.frame` A stacked summary of analysis pipeline output.
#'   Created by passing a list of results returned by [gsm.core::Summarize()] to
#'   [gsm.reporting::BindResults()]. Expected columns: `GroupID`, `GroupLevel`, `Numerator`,
#'   `Denominator`, `Metric`, `Score`, `Flag`, `MetricID`, `StudyID`,
#'   `SnapshotDate`.
#' @param dfResultsLongitudinal `data.frame` A stacked summary of analysis pipeline output
#'   from the previous snapshot.
#'   Created by passing a list of results returned by [gsm.core::Summarize()] to
#'   [gsm.reporting::BindResults()]. Expected columns: `GroupID`, `GroupLevel`, `Numerator`,
#'   `Denominator`, `Metric`, `Score`, `Flag`, `MetricID`, `StudyID`,
#'   `SnapshotDate`.
#' @param strIDColumns `character` A vector of column names with which to group
#'   results. Default:
#'   - StudyID
#'   - GroupLevel
#'   - GroupID
#'   - MetricID
#' @param strSnapshotDateColumn `character` The name of the column containing the
#'   snapshot date. Default: `SnapshotDate`.
#' @param dPrevSnapshotDate `Date` The date of the previous snapshot to be compared.
#'   Optional. Default = `NULL`.
#' @param strMetricColumns `character` A vector of numeric column names with which calculate change from
#'   previous snapshot. Default:
#'   - Numerator
#'   - Denominator
#'   - Metric
#'   - Score
#'   - Flag
#'
#' @return `data.frame` A transposed table of results with a column for each attribute, its value,
#'   and the change from the previous snapshot.
#'
#' @examples
#' dfResults <- gsm.core::reportingResults |> dplyr::filter(SnapshotDate == "2025-04-01")
#' dfResultsLongitudinal <- gsm.core::reportingResults |> dplyr::filter(SnapshotDate != "2025-04-01")
#' dfChChChChanges <- CalculateChange(
#'   dfResults = dfResults,
#'   dfResultsLongitudinal = dfResultsLongitudinal
#' )
#'
#' @export

CalculateChange <- function(
  dfResults,
  dfResultsLongitudinal = NULL,
  strIDColumns = c(
    "StudyID",
    "GroupLevel",
    "GroupID",
    "MetricID"
  ),
  strSnapshotDateColumn = "SnapshotDate",
  dPrevSnapshotDate = NULL,
  strMetricColumns = c(
    "Numerator",
    "Denominator",
    "Metric",
    "Score",
    "Flag"
  )
) {
  stop_if(
    cnd = !is.data.frame(dfResults),
    message = "`dfResults` must be a data frame."
  )

  # If dfResultsLongitudinal is not a data.frame, just return the dfResults
  if (!is.data.frame(dfResultsLongitudinal) || nrow(dfResultsLongitudinal) == 0) {
    cli::cli_alert_info("`dfResultsLongitudinal` not supplied properly, so dfResults will be returned unchanged.")
    return(dfResults)
  }

  # Check that all columns exist in [ dfResults ] and [ dfResultsLongitudinal ].
  for (strColumn in c(
    strIDColumns,
    strSnapshotDateColumn,
    strMetricColumns
  )) {
    stop_if(
      cnd = !strColumn %in% colnames(dfResults),
      message = glue::glue("`{strColumn} not found in `dfResults`.")
    )
    stop_if(
      cnd = !strColumn %in% colnames(dfResultsLongitudinal),
      message = glue::glue("`{strColumn} not found in `dfResultsLongitudinal`.")
    )
  }

  # Determine current snapshot date and ensure formatted as date
  dCurrentSnapshotDate <- max(dfResults[[strSnapshotDateColumn]], na.rm = T) %>% as.Date()

  # Filter out current snapshot from longitudinal data if present
  if (!is.null(dfResultsLongitudinal) && nrow(dfResultsLongitudinal) > 0) {
    if (dCurrentSnapshotDate %in% dfResultsLongitudinal[[strSnapshotDateColumn]]) {
      cli::cli_alert_info("Current snapshot date ({dCurrentSnapshotDate}) found in longitudinal data - removing to avoid duplication.")
    }

    # Remove current snapshot from longitudinal data
    dfResultsLongitudinal <- dfResultsLongitudinal %>%
      dplyr::filter(.data[[strSnapshotDateColumn]] != dCurrentSnapshotDate)

    # Get latest previous snapshot date
    available_dates <- sort(unique(dfResultsLongitudinal[[strSnapshotDateColumn]]))
    if (length(available_dates) == 0) {
      cli::cli_alert_info("No valid previous snapshots in longitudinal data - returning current results unchanged.")
      return(dfResults)
    }
  }

  # Bind dfResults and dfResultsLongitudinal and keep appropriate columns
  dfResults_combined <- dplyr::bind_rows(dfResultsLongitudinal, dfResults) %>%
    select(all_of(c(
      strIDColumns,
      strSnapshotDateColumn,
      strMetricColumns
    )))


  # If dPrevSnapshotDate is not null, then filter the data to only the current and previous snapshot dates.
  # This is primarily for gismo implementation when intermediary snapshots are taken but not reported.
  if (!is.null(dPrevSnapshotDate)) {
    dPrevSnapshotDate <- dPrevSnapshotDate %>% as.Date()
    # ensure dPrevSnapshotDate is a date in dfResults$SnapshotDate
    # and that it is not equal to the current snapshot date.
    stop_if(
      cnd = !dPrevSnapshotDate %in% dfResults_combined$SnapshotDate,
      message = glue::glue("`{dPrevSnapshotDate} not found in `dfResults$SnapshotDate`.")
    )
    stop_if(
      cnd = dPrevSnapshotDate == dCurrentSnapshotDate,
      message = glue::glue("`dPrevSnapshotDate cannot be equal to the current snapshot date in dfResults`.")
    )

    # filter dfResults based on SnapshotDate
    dfResults <- dfResults %>%
      dplyr::filter(.data[[strSnapshotDateColumn]] %in% c(dPrevSnapshotDate, dCurrentSnapshotDate))
  } else {
    dPrevSnapshotDate <- sort(dfResults_combined[[strSnapshotDateColumn]] %>% unique())[-2]
  }

  # Calculate change from previous snapshot.
  dfChanges <- dfResults_combined %>%
    tidyr::pivot_longer(
      cols = all_of(strMetricColumns),
      names_to = "Param",
      values_to = "Value"
    ) %>%
    dplyr::mutate(
      Param = factor(.data$Param, levels = strMetricColumns)
    ) %>%
    dplyr::group_by(across(all_of(c(
      strIDColumns,
      "Param"
    )))) %>%
    dplyr::arrange(
      .data[[strSnapshotDateColumn]],
      .by_group = TRUE
    ) %>%
    dplyr::mutate(
      Previous = dplyr::lag(.data$Value),
      Change = .data$Value - dplyr::lag(.data$Value),
      PercentChange = .data$Change / dplyr::lag(.data$Value) * 100,
      SnapshotDate_Previous = dplyr::lag(.data[[strSnapshotDateColumn]])
    ) %>%
    dplyr::ungroup() %>%
    dplyr::arrange(across(all_of(c(
      strIDColumns,
      "SnapshotDate_Previous",
      "Param",
      strSnapshotDateColumn
    )))) %>%
    tidyr::pivot_wider(
      names_from = Param,
      values_from = c("Value", "Previous", "Change", "PercentChange"),
      names_glue = "{Param}_{.value}",
    ) %>%
    dplyr::rename_with(~ gsub("_Value", "", .x), tidyr::ends_with("_Value"))

  return(dfChanges)
}
