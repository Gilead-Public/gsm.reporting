test_that("MakeBounds makes dfBounds (#41, #42)", {
  gsm.core::reportingResults %>% dplyr::count(SnapshotDate)
  expect_snapshot({
    MakeBounds(
      dfResults = dplyr::filter(
        gsm.core::reportingResults,
        SnapshotDate == "2025-04-01"
      ),
      dfMetrics = gsm.core::reportingMetrics
    )
  })
})

test_that("MakeBounds uses user-supplied strMetrics (#41)", {
  expect_snapshot({
    MakeBounds(
      dfResults = dplyr::filter(
        gsm.core::reportingResults,
        SnapshotDate == "2025-04-01"
      ),
      dfMetrics = gsm.core::reportingMetrics,
      strMetrics = "Analysis_kri0001"
    )
  })
})

test_that("MakeBounds fails for NULLed arguments", {
  expect_error(
    {
      MakeBounds(
        dfResults = gsm.core::reportingResults,
        dfMetrics = gsm.core::reportingMetrics,
        strMetrics = NULL
      )
    },
    regexp = "strMetrics"
  )
  expect_error(
    {
      MakeBounds(
        dfResults = gsm.core::reportingResults,
        dfMetrics = gsm.core::reportingMetrics,
        dSnapshotDate = NULL
      )
    },
    regexp = "dSnapshotDate"
  )
  expect_error(
    {
      MakeBounds(
        dfResults = gsm.core::reportingResults,
        dfMetrics = gsm.core::reportingMetrics,
        strStudyID = NULL
      )
    },
    regexp = "strStudyID"
  )
})

test_that("MakeBounds fails gracefully for multiple arg values", {
  expect_warning(
    {
      expect_message(
        {
          dfBounds <- MakeBounds(
            dfResults = gsm.core::reportingResults,
            dfMetrics = gsm.core::reportingMetrics
          )
        },
        "Creating stacked dfBounds data"
      )
    },
    regexp = "SnapshotDate",
  )
  expect_null(dfBounds)
  expect_warning(
    {
      expect_message(
        {
          dfBounds <- MakeBounds(
            dfResults = dplyr::filter(
              gsm.core::reportingResults,
              SnapshotDate == "2025-04-01"
            ),
            dfMetrics = gsm.core::reportingMetrics,
            strStudyID = c("a", "b")
          )
        },
        "Creating stacked dfBounds data"
      )
    },
    regexp = "StudyID",
  )
  expect_null(dfBounds)
})

test_that("MakeBounds makes poisson dfBounds (#41)", {
  reportingMetrics <- gsm.core::reportingMetrics
  reportingMetrics$Type <- "poisson"
  expect_snapshot({
    MakeBounds(
      dfResults = dplyr::filter(
        gsm.core::reportingResults,
        SnapshotDate == "2025-04-01"
      ),
      dfMetrics = reportingMetrics
    )
  })
})

test_that("MakeBounds has appropriate expected warnings (#25)", {
  expect_warning(
    dfBounds <- suppressMessages(
      MakeBounds(
        dfResults = gsm.core::reportingResults %>%
          dplyr::filter(SnapshotDate == max(.data$SnapshotDate)),
        dfMetrics = gsm.core::reportingMetrics %>%
          dplyr::filter(
            !(MetricID %in% c("Analysis_kri0001", "Analysis_kri0002"))
          )
      )
    ),
    regexp = "Analysis_kri0001; Analysis_kri0002 are missing from `dfMetrics`."
  ) |>
    expect_warning("Failed to parse strThreshold")
})

test_that("MakeBounds skips metrics without thresholds (#95)", {
  dfResults <- dplyr::filter(
    gsm.core::reportingResults,
    SnapshotDate == "2025-04-01",
    MetricID == "Analysis_kri0001"
  )
  dfUnflagged <- dplyr::mutate(
    dfResults,
    MetricID = "Analysis_ctq0001",
    Score = NA_real_,
    Flag = NA_real_
  )
  dfMetrics <- dplyr::filter(
    gsm.core::reportingMetrics,
    MetricID == "Analysis_kri0001"
  )
  dfMetricsUnflagged <- dplyr::bind_rows(
    dfMetrics,
    tibble::tibble(MetricID = "Analysis_ctq0001", GroupLevel = "Site")
  )

  dfExpected <- suppressMessages(MakeBounds(dfResults, dfMetrics))
  dfBounds <- suppressWarnings(suppressMessages(MakeBounds(
    dplyr::bind_rows(dfResults, dfUnflagged),
    dfMetricsUnflagged
  )))
  expect_equal(dfBounds, dfExpected)

  # Metadata from unflagged workflows alone has no Threshold column.
  expect_equal(
    NROW(suppressMessages(MakeBounds(
      dfUnflagged,
      dplyr::select(dfMetricsUnflagged[2, ], "MetricID", "GroupLevel")
    ))),
    0
  )
})