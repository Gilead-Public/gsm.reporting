dist_workflow <- function() {
  workr::MakeWorkflowList(
    strNames = "Distributions",
    strPath = file.path(
      system.file(package = "gsm.reporting"),
      "workflow",
      "3_reporting"
    )
  )
}

dist_mapped_study <- tibble::tibble(
  GroupID = "STUDY1",
  GroupLevel = "Study",
  Param = "Status",
  Value = "Active"
)

make_dist <- function(strGroupID, strGroupLevel = "Site") {
  tibble::tibble(
    GroupID = strGroupID,
    GroupLevel = strGroupLevel,
    Source = c("Numerator", "Numerator", "Denominator"),
    Variable = c("aeser", "aeser", "drv_ip_nonstarter_status"),
    Category = c("N", "Y", "Dosed"),
    Count = c(3, 1, 2),
    Participants = c(2L, 1L, 2L),
    Total = c(4, 4, 2),
    Percent = c(0.75, 0.25, 1)
  )
}

run_dist_workflow <- function(lAnalyzed) {
  quietly_run(workr::RunWorkflows(
    dist_workflow(),
    lData = list(
      Mapped_STUDY = dist_mapped_study,
      lAnalyzed = lAnalyzed,
      dSnapshotDate = as.Date("2026-11-01")
    )
  ))$Reporting_Distributions
}

test_that("Distributions workflow loads with the expected metadata (#87)", {
  wf <- dist_workflow()
  expect_named(wf, "Distributions")
  expect_equal(wf$Distributions$meta$Type, "Reporting")
  expect_true(wf$Distributions$meta$Active)
  expect_equal(
    wf$Distributions$steps[[length(wf$Distributions$steps)]]$output,
    "Reporting_Distributions"
  )
})

test_that("Reporting_Distributions stacks Analysis_Distributions with the expected schema and types (#87)", {
  lAnalyzed <- list(
    Analysis_kri0001 = list(
      Analysis_Summary = tibble::tibble(GroupID = "S1"),
      Analysis_Distributions = make_dist("S1")
    ),
    Analysis_kri0002 = list(Analysis_Summary = tibble::tibble(GroupID = "S1")),
    Analysis_cou0001 = list(
      Analysis_Summary = tibble::tibble(GroupID = "US"),
      Analysis_Distributions = make_dist("US", "Country")
    )
  )
  dfDist <- run_dist_workflow(lAnalyzed)

  expect_equal(
    vapply(dfDist, \(x) class(x)[[1]], character(1)),
    c(
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
  )
  expect_equal(nrow(dfDist), 6)
  expect_equal(
    dfDist$MetricID,
    rep(c("Analysis_kri0001", "Analysis_cou0001"), each = 3)
  )
  expect_equal(dfDist$GroupLevel, rep(c("Site", "Country"), each = 3))
  expect_true(all(dfDist$SnapshotDate == as.Date("2026-11-01")))
  expect_true(all(dfDist$StudyID == "STUDY1"))
})

test_that("Reporting_Distributions is an empty data frame when no metric defines Analysis_Distributions (#87)", {
  lAnalyzed <- list(
    Analysis_kri0001 = list(Analysis_Summary = tibble::tibble(GroupID = "S1")),
    Analysis_kri0002 = list(Analysis_Summary = tibble::tibble(GroupID = "S1"))
  )
  dfDist <- run_dist_workflow(lAnalyzed)

  expect_s3_class(dfDist, "data.frame")
  expect_equal(nrow(dfDist), 0)
  expect_named(dfDist, c("MetricID", "SnapshotDate", "StudyID"))
})
