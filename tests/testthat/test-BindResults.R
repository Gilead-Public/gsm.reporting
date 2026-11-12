test_that("BindResults binds dfs in lAnalysis (#24)", {
  lAnalysis <- list(
    resultA = list(
      tbl1 = tibble::tibble(
        a = 1:3,
        b = letters[1:3]
      ),
      tbl2 = tibble::tibble()
    ),
    resultB = list(
      tbl1 = tibble::tibble(
        a = 4:6,
        b = letters[4:6]
      ),
      tbl3 = tibble::tibble()
    )
  )
  expect_identical(
    BindResults(
      lAnalysis = lAnalysis,
      strName = "tbl1",
      strStudyID = "ThisStudy"
    ),
    tibble::tibble(
      a = 1:6,
      b = letters[1:6],
      MetricID = c(rep("resultA", 3), rep("resultB", 3)),
      SnapshotDate = Sys.Date(),
      StudyID = "ThisStudy"
    )
  )
})

test_that("BindResults binds dfs in lAnalysis$lData (#24)", {
  lAnalysis <- list(
    resultA = list(
      lData = list(
        tbl1 = tibble::tibble(
          a = 1:3,
          b = letters[1:3]
        ),
        tbl2 = tibble::tibble()
      )
    ),
    resultB = list(
      lData = list(
        tbl1 = tibble::tibble(
          a = 4:6,
          b = letters[4:6]
        ),
        tbl3 = tibble::tibble()
      )
    )
  )
  expect_identical(
    BindResults(
      lAnalysis = lAnalysis,
      strName = "tbl1",
      strStudyID = "ThisStudy",
      bUselData = TRUE
    ),
    tibble::tibble(
      a = 1:6,
      b = letters[1:6],
      MetricID = c(rep("resultA", 3), rep("resultB", 3)),
      SnapshotDate = Sys.Date(),
      StudyID = "ThisStudy"
    )
  )
})

test_that("BindResults skips metrics without strName and logs them (#86)", {
  lAnalysis <- list(
    kri0001 = list(Analysis_Distributions = tibble::tibble(GroupID = c("1", "2"))),
    kri0002 = list(Analysis_Input = tibble::tibble(GroupID = "1")),
    kri0003 = list(Analysis_Distributions = tibble::tibble(GroupID = "3"))
  )
  expect_message(
    dfResults <- BindResults(
      lAnalysis = lAnalysis,
      strName = "Analysis_Distributions",
      dSnapshotDate = as.Date("2026-11-01"),
      strStudyID = "ThisStudy"
    ),
    "not found for 1 metric\\(s\\); skipped: kri0002"
  )
  expect_identical(
    dfResults,
    tibble::tibble(
      GroupID = c("1", "2", "3"),
      MetricID = c("kri0001", "kri0001", "kri0003"),
      SnapshotDate = as.Date("2026-11-01"),
      StudyID = "ThisStudy"
    )
  )
})

test_that("BindResults skips metrics without strName in lData (#86)", {
  lAnalysis <- list(
    kri0001 = list(lData = list(Analysis_Input = tibble::tibble(GroupID = "1"))),
    kri0002 = list(lData = list(Analysis_Distributions = tibble::tibble(GroupID = "2")))
  )
  expect_message(
    dfResults <- BindResults(
      lAnalysis = lAnalysis,
      strName = "Analysis_Distributions",
      bUselData = TRUE
    ),
    "skipped: kri0001"
  )
  expect_identical(
    dfResults,
    tibble::tibble(
      GroupID = "2",
      MetricID = "kri0002",
      SnapshotDate = Sys.Date()
    )
  )
})

test_that("BindResults returns an empty data frame when no metric has strName (#86)", {
  lAnalysis <- list(
    kri0001 = list(Analysis_Summary = tibble::tibble(GroupID = "1")),
    kri0002 = list(Analysis_Input = tibble::tibble(GroupID = "1"))
  )
  expect_message(
    dfResults <- BindResults(
      lAnalysis = lAnalysis,
      strName = "Analysis_Distributions",
      dSnapshotDate = as.Date("2026-11-01"),
      strStudyID = "ThisStudy"
    ),
    "skipped: kri0001; kri0002"
  )
  expect_identical(
    dfResults,
    tibble::tibble(
      MetricID = character(),
      SnapshotDate = as.Date(character()),
      StudyID = character()
    )
  )
  expect_identical(
    suppressMessages(
      BindResults(lAnalysis = lAnalysis, strName = "Analysis_Distributions", bUselData = TRUE)
    ),
    tibble::tibble(MetricID = character(), SnapshotDate = as.Date(character()))
  )
  expect_no_message(
    dfEmpty <- BindResults(lAnalysis = list(), strName = "Analysis_Distributions")
  )
  expect_identical(
    dfEmpty,
    tibble::tibble(MetricID = character(), SnapshotDate = as.Date(character()))
  )
})

test_that("BindResults logs nothing when every metric has strName (#86)", {
  lAnalysis <- list(
    kri0001 = list(Analysis_Summary = tibble::tibble(GroupID = "1")),
    kri0002 = list(Analysis_Summary = tibble::tibble(GroupID = "2"))
  )
  expect_no_message(
    BindResults(lAnalysis = lAnalysis, strName = "Analysis_Summary")
  )
})

test_that("BindResults skip message respects the gsm.core log level (#86)", {
  TestAtLogLevel("WARN")
  lAnalysis <- list(
    kri0001 = list(Analysis_Distributions = tibble::tibble(GroupID = "1")),
    kri0002 = list(Analysis_Input = tibble::tibble(GroupID = "1"))
  )
  expect_no_message(
    dfResults <- BindResults(lAnalysis = lAnalysis, strName = "Analysis_Distributions")
  )
  expect_identical(dfResults$MetricID, "kri0001")
})
