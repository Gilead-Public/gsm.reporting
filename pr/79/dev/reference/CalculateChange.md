# Calculate Change

Calculate the change of user-specified metrics from the previous
snapshot date. The primary use case of this function is to check for
changes in the metrics when determining if continued flags should be
actioned.

## Usage

``` r
CalculateChange(
  dfResults,
  dfResultsLongitudinal = NULL,
  strIDColumns = c("StudyID", "GroupLevel", "GroupID", "MetricID"),
  strSnapshotDateColumn = "SnapshotDate",
  dPrevSnapshotDate = NULL,
  strMetricColumns = c("Numerator", "Denominator", "Metric", "Score", "Flag")
)
```

## Arguments

- dfResults:

  `data.frame` A stacked summary of analysis pipeline output. Created by
  passing a list of results returned by
  [`gsm.core::Summarize()`](https://gilead-biostats.github.io/gsm.core/reference/Summarize.html)
  to
  [`BindResults()`](https://gilead-public.github.io/gsm.reporting/dev/reference/BindResults.md).
  Expected columns: `GroupID`, `GroupLevel`, `Numerator`, `Denominator`,
  `Metric`, `Score`, `Flag`, `MetricID`, `StudyID`, `SnapshotDate`.

- dfResultsLongitudinal:

  `data.frame` A stacked summary of analysis pipeline output from the
  previous snapshot. Created by passing a list of results returned by
  [`gsm.core::Summarize()`](https://gilead-biostats.github.io/gsm.core/reference/Summarize.html)
  to
  [`BindResults()`](https://gilead-public.github.io/gsm.reporting/dev/reference/BindResults.md).
  Expected columns: `GroupID`, `GroupLevel`, `Numerator`, `Denominator`,
  `Metric`, `Score`, `Flag`, `MetricID`, `StudyID`, `SnapshotDate`.

- strIDColumns:

  `character` A vector of column names with which to group results.
  Default:

  - StudyID

  - GroupLevel

  - GroupID

  - MetricID

- strSnapshotDateColumn:

  `character` The name of the column containing the snapshot date.
  Default: `SnapshotDate`.

- dPrevSnapshotDate:

  `Date` The date of the previous snapshot to be compared. Optional.
  Default = `NULL`.

- strMetricColumns:

  `character` A vector of numeric column names with which calculate
  change from previous snapshot. Default:

  - Numerator

  - Denominator

  - Metric

  - Score

  - Flag

## Value

`data.frame` A transposed table of results with a column for each
attribute, its value, and the change from the previous snapshot.

## Examples

``` r
dfResults <- gsm.core::reportingResults |> dplyr::filter(SnapshotDate == "2025-04-01")
dfResultsLongitudinal <- gsm.core::reportingResults |> dplyr::filter(SnapshotDate != "2025-04-01")
dfChChChChanges <- CalculateChange(
  dfResults = dfResults,
  dfResultsLongitudinal = dfResultsLongitudinal
)
```
