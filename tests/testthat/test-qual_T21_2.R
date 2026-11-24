testthat::skip_if_not_installed("gsm.mapping")

## Test Setup
# Input_Rate_Dist() is added in gsm.core#213; skip the tests that build
# distributions until the installed gsm.core provides it.
skip_if_no_input_rate_dist <- function() {
  testthat::skip_if_not(
    exists("Input_Rate_Dist", envir = asNamespace("gsm.core")),
    "gsm.core::Input_Rate_Dist() is not available (gsm.core#213)."
  )
}

t21_snapshot <- as.Date("2026-11-01")

# Expected configuration of the fixture metrics in
# fixtures/workflow/2_metrics_dist, stated independently so that a change to
# the fixtures is caught by the comparisons below.
t21_config <- list(
  Analysis_kri0001_dist = list(
    GroupLevel = "Site",
    strGroupCol = "invid",
    strDenominatorCol = "timeonstudy",
    Numerator = c("aeser", "ae_flags"),
    Denominator = "drv_ip_nonstarter_status"
  ),
  Analysis_cou0001_dist = list(
    GroupLevel = "Country",
    strGroupCol = "country",
    strDenominatorCol = NULL,
    Numerator = "aeser",
    Denominator = "drv_ip_nonstarter_status"
  )
)
t21_no_dist <- c("Analysis_kri0001", "Analysis_kri0002", "Analysis_kri0005")

t21_columns <- c(
  GroupID = "character",
  GroupLevel = "character",
  Source = "character",
  Variable = "character",
  Category = "character",
  Count = "numeric",
  Participants = "integer",
  Total = "numeric",
  Percent = "numeric",
  MetricID = "character",
  SnapshotDate = "Date",
  StudyID = "character"
)

# Run metrics with and without distributions, then the reporting workflows,
# once and reuse the result across tests.
run_t21 <- local({
  result <- NULL
  function() {
    if (is.null(result)) {
      lWorkflows <- c(
        kri_workflows,
        workr::MakeWorkflowList(
          strPath = test_path("fixtures", "workflow", "2_metrics_dist")
        )
      )
      lAnalyzed <- quietly_run(workr::RunWorkflows(
        lWorkflows,
        lData = c(mapped_data, list(lWorkflows = lWorkflows))
      ))
      lReporting <- quietly_run(workr::RunWorkflows(
        reporting_workflows,
        lData = c(
          mapped_data,
          list(
            lAnalyzed = lAnalyzed,
            lWorkflows = lWorkflows,
            dSnapshotDate = t21_snapshot
          )
        )
      ))
      result <<- list(analyzed = lAnalyzed, reporting = lReporting)
    }
    result
  }
})

# Double-programmed distribution of a single-value category column: one row
# per group and observed category, zero-filled, with "Not recorded" for
# missing or blank values.
expected_single_value_dist <- function(
  dfRecords,
  dfSubjects,
  strGroupCol,
  strCatCol,
  strValueCol = NULL
) {
  dfSubjects <- dfSubjects[!is.na(dfSubjects[[strGroupCol]]), ]
  dfRecords <- dfRecords[dfRecords$subjid %in% dfSubjects$subjid, ]
  dfRecords$GroupID <- dfSubjects[[strGroupCol]][
    match(dfRecords$subjid, dfSubjects$subjid)
  ]
  dfRecords$Category <- ifelse(
    is.na(dfRecords[[strCatCol]]) | trimws(dfRecords[[strCatCol]]) == "",
    "Not recorded",
    trimws(dfRecords[[strCatCol]])
  )
  dfRecords$Weight <- if (is.null(strValueCol)) {
    1
  } else {
    as.numeric(dfRecords[[strValueCol]])
  }
  dfRecords$Weight[is.na(dfRecords$Weight)] <- 0

  dfCounts <- dfRecords %>%
    group_by(GroupID, Category) %>%
    summarise(
      Count = sum(Weight),
      Participants = n_distinct(subjid),
      .groups = "drop"
    )

  tidyr::expand_grid(
    GroupID = unique(dfSubjects[[strGroupCol]]),
    Category = unique(dfRecords$Category)
  ) %>%
    left_join(dfCounts, by = c("GroupID", "Category")) %>%
    mutate(
      Count = coalesce(Count, 0),
      Participants = coalesce(Participants, 0L)
    )
}

## Test Code
testthat::test_that("Qual: Given metrics with and without Analysis_Distributions, the Distributions reporting workflow creates Reporting_Distributions with the expected structure (#87)", {
  skip_if_no_input_rate_dist()
  test <- run_t21()$reporting$Reporting_Distributions

  expect_s3_class(test, "data.frame")
  expect_named(test, names(t21_columns))
  expect_equal(
    vapply(test, \(x) class(x)[[1]], character(1)),
    t21_columns
  )
  expect_gt(nrow(test), 0)
  expect_setequal(unique(test$Source), c("Numerator", "Denominator"))
  expect_true(all(test$SnapshotDate == t21_snapshot))
  expect_true(all(test$StudyID == unique(mapped_data$Mapped_STUDY$GroupID)))
})

testthat::test_that("Qual: Reporting_Distributions stacks the rows of every metric that defines Analysis_Distributions with the correct MetricID, and skips metrics that do not (#87)", {
  skip_if_no_input_rate_dist()
  lRun <- run_t21()
  test <- lRun$reporting$Reporting_Distributions

  expect_setequal(unique(test$MetricID), names(t21_config))
  expect_false(any(t21_no_dist %in% test$MetricID))

  # Stack each metric's Analysis_Distributions by hand.
  expected <- do.call(
    rbind,
    lapply(names(t21_config), function(strMetricID) {
      df <- as.data.frame(lRun$analyzed[[strMetricID]]$Analysis_Distributions)
      df$MetricID <- strMetricID
      df$SnapshotDate <- t21_snapshot
      df$StudyID <- unique(mapped_data$Mapped_STUDY$GroupID)
      df
    })
  )
  sort_rows <- function(df) {
    df %>%
      as.data.frame() %>%
      arrange(MetricID, Source, Variable, GroupID, Category)
  }
  expect_equal(sort_rows(test), sort_rows(expected), ignore_attr = TRUE)

  # Each metric contributes its configured variables at its group level.
  for (strMetricID in names(t21_config)) {
    cfg <- t21_config[[strMetricID]]
    dfMetric <- test[test$MetricID == strMetricID, ]
    expect_true(all(dfMetric$GroupLevel == cfg$GroupLevel))
    expect_setequal(
      unique(dfMetric$Variable[dfMetric$Source == "Numerator"]),
      cfg$Numerator
    )
    expect_setequal(
      unique(dfMetric$Variable[dfMetric$Source == "Denominator"]),
      cfg$Denominator
    )
  }
})

testthat::test_that("Qual: Every group in Reporting_Results for a configured metric has distribution rows for each configured variable (#87)", {
  skip_if_no_input_rate_dist()
  lReporting <- run_t21()$reporting

  for (strMetricID in names(t21_config)) {
    cfg <- t21_config[[strMetricID]]
    vResultGroups <- lReporting$Reporting_Results$GroupID[
      lReporting$Reporting_Results$MetricID == strMetricID
    ]
    expect_gt(length(vResultGroups), 0)
    for (strSource in c("Numerator", "Denominator")) {
      for (strVariable in cfg[[strSource]]) {
        dfVariable <- lReporting$Reporting_Distributions %>%
          filter(
            MetricID == strMetricID,
            Source == strSource,
            Variable == strVariable
          )
        expect_setequal(unique(dfVariable$GroupID), vResultGroups)
      }
    }
  }
})

testthat::test_that("Qual: Reporting_Distributions Total equals the Numerator or Denominator in Reporting_Results for the same metric and group (#87)", {
  skip_if_no_input_rate_dist()
  lReporting <- run_t21()$reporting

  dfResults <- lReporting$Reporting_Results %>%
    filter(MetricID %in% names(t21_config)) %>%
    select(MetricID, GroupID, Numerator, Denominator) %>%
    tidyr::pivot_longer(
      c(Numerator, Denominator),
      names_to = "Source",
      values_to = "Expected"
    )
  check <- lReporting$Reporting_Distributions %>%
    distinct(MetricID, GroupID, Source, Variable, Total) %>%
    left_join(dfResults, by = c("MetricID", "GroupID", "Source"))

  expect_gt(nrow(check), 0)
  expect_false(anyNA(check$Expected))
  expect_equal(check$Total, as.numeric(check$Expected))
})

testthat::test_that("Qual: Reporting_Distributions Count, Participants and Percent match independently derived distributions for single-value variables (#87)", {
  skip_if_no_input_rate_dist()
  test <- run_t21()$reporting$Reporting_Distributions

  for (strMetricID in names(t21_config)) {
    cfg <- t21_config[[strMetricID]]
    lExpected <- list(
      Numerator = expected_single_value_dist(
        dfRecords = mapped_data$Mapped_AE,
        dfSubjects = mapped_data$Mapped_SUBJ,
        strGroupCol = cfg$strGroupCol,
        strCatCol = "aeser"
      ),
      Denominator = expected_single_value_dist(
        dfRecords = mapped_data$Mapped_SUBJ,
        dfSubjects = mapped_data$Mapped_SUBJ,
        strGroupCol = cfg$strGroupCol,
        strCatCol = "drv_ip_nonstarter_status",
        strValueCol = cfg$strDenominatorCol
      )
    )
    vVariables <- c(Numerator = "aeser", Denominator = "drv_ip_nonstarter_status")

    for (strSource in names(lExpected)) {
      actual <- test %>%
        filter(
          MetricID == strMetricID,
          Source == strSource,
          Variable == vVariables[[strSource]]
        )
      expected <- lExpected[[strSource]] %>%
        group_by(GroupID) %>%
        mutate(Total = sum(Count)) %>%
        ungroup() %>%
        mutate(Percent = ifelse(Total == 0, NA_real_, Count / Total))

      compare_cols <- c(
        "GroupID", "Category", "Count", "Participants", "Total", "Percent"
      )
      sort_rows <- function(df) {
        df %>%
          as.data.frame() %>%
          select(all_of(compare_cols)) %>%
          arrange(GroupID, Category)
      }
      expect_equal(sort_rows(actual), sort_rows(expected), ignore_attr = TRUE)
    }
  }
})

testthat::test_that("Qual: Given metrics without Analysis_Distributions, the Distributions reporting workflow creates an empty Reporting_Distributions data frame (#87)", {
  test <- quietly_run(workr::RunWorkflows(
    reporting_workflows,
    lData = c(
      mapped_data,
      list(
        lAnalyzed = analyzed,
        lWorkflows = kri_workflows,
        dSnapshotDate = t21_snapshot
      )
    )
  ))

  expect_s3_class(test$Reporting_Distributions, "data.frame")
  expect_equal(nrow(test$Reporting_Distributions), 0)
  expect_true(all(
    c("MetricID", "SnapshotDate", "StudyID") %in%
      names(test$Reporting_Distributions)
  ))
  expect_equal(
    nrow(test$Reporting_Results),
    sum(map_int(analyzed, \(x) nrow(x$Analysis_Summary)))
  )
})
