## Test Code
test_that("Qual: derived mappings with no Raw_ domain are materialised in the qualification fixture (#77)", {
  # A derived mapping whose upstream columns are missing completes with a NULL
  # output rather than erroring, so assert the frames are non-empty, not just present.
  for (nm in c("Mapped_COUNTRY", "Mapped_EXCLUSION", "Mapped_IPNS")) {
    expect_s3_class(mapped_data[[nm]], "data.frame")
    expect_gt(nrow(mapped_data[[nm]]), 0)
  }
})
