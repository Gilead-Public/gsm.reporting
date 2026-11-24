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
#' @returns A `data.frame` with the current values and the previous values, changes, and percent
#'   changes for each metric. When no previous snapshot is available, the previous-snapshot and
#'   change columns are included with `NA` values.
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

  bHasLongitudinal <- is.data.frame(dfResultsLongitudinal) &&
    nrow(dfResultsLongitudinal) > 0

  if (!bHasLongitudinal) {
    cli::cli_alert_info(
      "`dfResultsLongitudinal` not supplied properly, so change columns will be returned as `NA`."
    )
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
    if (bHasLongitudinal) {
      stop_if(
        cnd = !strColumn %in% colnames(dfResultsLongitudinal),
        message = glue::glue(
          "`{strColumn} not found in `dfResultsLongitudinal`."
        )
      )
    }
  }

  # Filter out current snapshot from longitudinal data if present
  if (bHasLongitudinal) {
    # Determine current snapshot date and ensure formatted as date
    dCurrentSnapshotDate <- max(
      dfResults[[strSnapshotDateColumn]],
      na.rm = T
    ) %>%
      as.Date()

    if (
      dCurrentSnapshotDate %in% dfResultsLongitudinal[[strSnapshotDateColumn]]
    ) {
      cli::cli_alert_info(
        "Current snapshot date ({dCurrentSnapshotDate}) found in longitudinal data - removing to avoid duplication."
      )
    }

    # Remove current snapshot from longitudinal data
    dfResultsLongitudinal <- dfResultsLongitudinal %>%
      dplyr::filter(.data[[strSnapshotDateColumn]] != dCurrentSnapshotDate)

    # Get latest previous snapshot date
    available_dates <- sort(unique(dfResultsLongitudinal[[
      strSnapshotDateColumn
    ]]))
    if (length(available_dates) == 0) {
      cli::cli_alert_info(
        "No valid previous snapshots in longitudinal data - change columns will be returned as `NA`."
      )
      bHasLongitudinal <- FALSE
    }
  }

  if (!bHasLongitudinal) {
    strOutputColumns <- c(
      strIDColumns,
      strSnapshotDateColumn,
      "SnapshotDate_Previous",
      strMetricColumns,
      paste0(strMetricColumns, "_Previous"),
      paste0(strMetricColumns, "_Change"),
      paste0(strMetricColumns, "_PercentChange")
    )

    dfResults <- dfResults %>%
      dplyr::select(all_of(c(
        strIDColumns,
        strSnapshotDateColumn,
        strMetricColumns
      )))
    dfResults$SnapshotDate_Previous <- dfResults[[strSnapshotDateColumn]][
      rep(NA_integer_, nrow(dfResults))
    ]

    for (strColumn in strMetricColumns) {
      dfResults[[paste0(strColumn, "_Previous")]] <- dfResults[[strColumn]][
        rep(NA_integer_, nrow(dfResults))
      ]
      dfResults[[paste0(strColumn, "_Change")]] <- dfResults[[strColumn]][
        rep(NA_integer_, nrow(dfResults))
      ]
      dfResults[[paste0(strColumn, "_PercentChange")]] <- rep(
        NA_real_,
        nrow(dfResults)
      )
    }

    return(dfResults %>% dplyr::select(all_of(strOutputColumns)))
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
      message = glue::glue(
        "`{dPrevSnapshotDate} not found in `dfResults$SnapshotDate`."
      )
    )
    stop_if(
      cnd = dPrevSnapshotDate == dCurrentSnapshotDate,
      message = glue::glue(
        "`dPrevSnapshotDate cannot be equal to the current snapshot date in dfResults`."
      )
    )

    # filter dfResults based on SnapshotDate
    dfResults <- dfResults %>%
      dplyr::filter(
        .data[[strSnapshotDateColumn]] %in%
          c(dPrevSnapshotDate, dCurrentSnapshotDate)
      )
  } else {
    dPrevSnapshotDate <- sort(
      dfResults_combined[[strSnapshotDateColumn]] %>% unique()
    )[-2]
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
      names_from = "Param",
      values_from = c("Value", "Previous", "Change", "PercentChange"),
      names_glue = "{Param}_{.value}",
    ) %>%
    dplyr::rename_with(~ gsub("_Value", "", .x), tidyr::ends_with("_Value"))

  return(dfChanges)
}
