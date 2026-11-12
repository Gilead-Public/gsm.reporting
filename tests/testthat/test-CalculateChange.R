## set up test data and params

dfResults <- data.frame(
  StudyID = c(1, 1, 1, 1, 1, 1),
  GroupLevel = c("A", "A", "A", "A", "A", "A"),
  GroupID = c(1, 2, 3, 4, 5, 6),
  MetricID = c(
    "Metric A",
    "Metric B",
    "Metric C",
    "Metric D",
    "Metric E",
    "Metric F"
  ),
  SnapshotDate = as.Date(c(
    "2023-03-01",
    "2023-03-01",
    "2023-03-01",
    "2023-03-01",
    "2023-03-01",
    "2023-03-01"
  )),
  Numerator = c(10, 25, 40, 5, 5, 15),
  Denominator = c(100, 250, 400, 50, 50, 150),
  Metric = c(.1, .1, .1, .1, .1, .1),
  Score = c(0.1, 0.2, 0.3, 0.05, 0.1, 0.15),
  Flag = c(-2, 0, 1, 0, 0, 2)
)

dfPrevious <- data.frame(
  StudyID = c(1, 1, 1, 1, 1, 1),
  GroupLevel = c("A", "A", "A", "A", "A", "A"),
  GroupID = c(1, 2, 3, 4, 5, 6),
  MetricID = c(
    "Metric A",
    "Metric B",
    "Metric C",
    "Metric D",
    "Metric E",
    "Metric F"
  ),
  SnapshotDate = as.Date(c(
    "2023-02-01",
    "2023-02-01",
    "2023-02-01",
    "2023-02-01",
    "2023-02-01",
    "2023-02-01"
  )),
  Numerator = c(10, 20, 30, 5, 10, 15),
  Denominator = c(100, 200, 300, 50, 100, 150),
  Metric = c(.1, .1, .1, .1, .1, .1),
  Score = c(0.1, 0.2, 0.3, 0.05, 0.1, 0.15),
  Flag = c(-2, -1, 0, 0, 1, 2)
)

strIDColumns <- c(
  "StudyID",
  "GroupLevel",
  "GroupID",
  "MetricID"
)

strSnapshotDateColumn <- "SnapshotDate"

strMetricColumns <- c(
  "Numerator",
  "Denominator",
  "Metric",
  "Score",
  "Flag"
)

test_that("[ CalculateChange ] correctly calculates change from the previous snapshot. (#6, #30, #31, #35)", {
  # [ CalculateChange ] returns a data frame with one record per combination of the
  # following columns
  # - StudyID
  # - GroupLevel
  # - GroupID
  # - MetricID
  # - SnapshotDate
  dfChanges <- CalculateChange(
    dfResults = dfResults,
    dfResultsLongitudinal = dfPrevious
  )

  # Check that the output is a data frame.
  expect_true(is.data.frame(dfChanges))

  # Check that the output has the expected number of rows.
  expect_equal(
    nrow(dfChanges),
    sum(nrow(dfResults), nrow(dfPrevious))
  )

  # Check that the output has the expected columns.
  expect_true(all(
    c(
      strIDColumns,
      strSnapshotDateColumn,
      "SnapshotDate_Previous",
      paste(strMetricColumns, "Previous", sep = "_"),
      paste(strMetricColumns, "Change", sep = "_"),
      paste(strMetricColumns, "PercentChange", sep = "_")
    ) %in%
      colnames(dfChanges)
  ))

  # Check that the output has the expected values.
  expect_equal(
    dfChanges$Numerator,
    c(10, 10, 25, 20, 40, 30, 5, 5, 5, 10, 15, 15)
  )
  expect_equal(
    dfChanges$Denominator,
    c(100, 100, 250, 200, 400, 300, 50, 50, 50, 100, 150, 150)
  )
  expect_equal(
    dfChanges$Metric,
    c(.1, .1, .1, .1, .1, .1, .1, .1, .1, .1, .1, .1)
  )
  expect_equal(
    dfChanges$Score,
    c(0.10, 0.10, 0.20, 0.20, 0.30, 0.30, 0.05, 0.05, 0.10, 0.10, 0.15, 0.15)
  )
  expect_equal(
    dfChanges$Flag,
    c(-2, -2, 0, -1, 1, 0, 0, 0, 0, 1, 2, 2)
  )

  # Check that the output has the expected change values.
  expect_equal(
    dfChanges$Numerator_Change,
    c(0, NA, 5, NA, 10, NA, 0, NA, -5, NA, 0, NA)
  )
  expect_equal(
    dfChanges$Denominator_Change,
    c(0, NA, 50, NA, 100, NA, 0, NA, -50, NA, 0, NA)
  )
  expect_equal(
    dfChanges$Metric_Change,
    c(0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA)
  )
  expect_equal(
    dfChanges$Score_Change,
    c(0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA)
  )
  expect_equal(
    dfChanges$Flag_Change,
    c(0, NA, 1, NA, 1, NA, 0, NA, -1, NA, 0, NA)
  )

  # Check that the output has the expected percent change values.
  expect_equal(
    dfChanges$Numerator_PercentChange,
    c(0, NA, 25, NA, 100 / 3, NA, 0, NA, -50, NA, 0, NA)
  )
  expect_equal(
    dfChanges$Denominator_PercentChange,
    c(0, NA, 25, NA, 100 / 3, NA, 0, NA, -50, NA, 0, NA)
  )
  expect_equal(
    dfChanges$Metric_PercentChange,
    c(0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA)
  )
  expect_equal(
    dfChanges$Score_PercentChange,
    c(0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA)
  )
  expect_equal(
    dfChanges$Flag_PercentChange,
    c(0, NA, -100, NA, Inf, NA, NaN, NA, -100, NA, 0, NA)
  )
})

test_that("[ CalculateChange ] returns message and dfResults unchanged if dfPrevious not supplied. (#31, #30)", {
  expect_message(
    {
      dfChanges <- CalculateChange(
        dfResults = dfResults
      )
    },
    "dfResults will be returned unchanged"
  )
  expect_equal(dfChanges, dfResults)
})

test_that("[ CalculateChange ] compares against the latest previous snapshot regardless of input row order. (#30)", {
  dfOlder <- dfPrevious
  dfOlder$SnapshotDate <- as.Date("2023-01-01")
  dfOlder$Numerator <- dfOlder$Numerator + 100
  # Most recent previous snapshot first, older snapshot after.
  dfLongitudinal <- rbind(dfPrevious, dfOlder)

  dfChanges <- CalculateChange(
    dfResults = dfResults,
    dfResultsLongitudinal = dfLongitudinal
  )
  dfCurrent <- dfChanges[dfChanges$SnapshotDate == as.Date("2023-03-01"), ]

  expect_equal(
    unique(dfCurrent$SnapshotDate_Previous),
    as.Date("2023-02-01")
  )
  expect_equal(dfCurrent$Numerator_Previous, dfPrevious$Numerator)
})
