# Filter by latest snapshot date

**\[experimental\]**

Filter a data frame to the most recent snapshot date, or to a specified
snapshot date.

## Usage

``` r
FilterByLatestSnapshotDate(df, strSnapshotDate = NULL)
```

## Arguments

- df:

  (`data.frame`) Data with a `SnapshotDate` column. If `df` has no rows,
  or has no `SnapshotDate` column and `strSnapshotDate` is `NULL`, `df`
  is returned unchanged.

- strSnapshotDate:

  (`length-1 character`) Snapshot date to filter to. Defaults to the
  maximum `SnapshotDate` in `df`.

## Value

`df`, filtered to rows from the selected snapshot date, with
`SnapshotDate` converted to `Date`.

## Examples

``` r
reportingResults_latest <- FilterByLatestSnapshotDate(
  gsm.core::reportingResults
)
```
