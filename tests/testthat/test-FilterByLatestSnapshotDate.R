test_that("FilterByLatestSnapshotDate keeps only the latest snapshot", {
  df <- data.frame(
    x = 1:3,
    SnapshotDate = c("2025-01-01", "2025-02-01", "2025-02-01")
  )
  test_result <- FilterByLatestSnapshotDate(df)
  expect_equal(test_result$x, 2:3)
  expect_s3_class(test_result$SnapshotDate, "Date")
})

test_that("FilterByLatestSnapshotDate ignores missing snapshot dates", {
  df <- data.frame(
    x = 1:3,
    SnapshotDate = c("2025-01-01", NA, "2025-02-01")
  )
  test_result <- FilterByLatestSnapshotDate(df)
  expect_equal(test_result$x, 3L)
  expect_s3_class(test_result$SnapshotDate, "Date")
})

test_that("FilterByLatestSnapshotDate returns no rows for all-missing dates", {
  df <- data.frame(x = 1:2, SnapshotDate = c(NA, NA))
  test_result <- FilterByLatestSnapshotDate(df)
  expect_equal(nrow(test_result), 0L)
  expect_s3_class(test_result$SnapshotDate, "Date")
})

test_that("FilterByLatestSnapshotDate filters to strSnapshotDate", {
  df <- data.frame(
    x = 1:3,
    SnapshotDate = c("2025-01-01", "2025-02-01", "2025-02-01")
  )
  test_result <- FilterByLatestSnapshotDate(df, "2025-01-01")
  expect_equal(test_result$x, 1L)
})

test_that("FilterByLatestSnapshotDate errors when strSnapshotDate is given without SnapshotDate", {
  df_no_date <- data.frame(x = 1:2)
  expect_error(
    FilterByLatestSnapshotDate(df_no_date, "2025-01-01"),
    "df_no_date"
  )
})

test_that("FilterByLatestSnapshotDate returns input without rows or SnapshotDate", {
  df_empty <- data.frame(SnapshotDate = as.Date(character()))
  expect_identical(FilterByLatestSnapshotDate(df_empty), df_empty)
  df_no_date <- data.frame(x = 1:2)
  expect_identical(FilterByLatestSnapshotDate(df_no_date), df_no_date)
  df_partial_date <- data.frame(
    x = 1:2,
    SnapshotDate_Previous = c("2025-01-01", "2025-02-01")
  )
  expect_identical(
    FilterByLatestSnapshotDate(df_partial_date),
    df_partial_date
  )
  expect_error(
    FilterByLatestSnapshotDate(df_partial_date, "2025-01-01"),
    "df_partial_date"
  )
})
