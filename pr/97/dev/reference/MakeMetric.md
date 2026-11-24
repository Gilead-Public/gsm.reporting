# Parse metadata from workflows to a data frame

**\[stable\]**

Used to format metric metadata (`dfMetrics`) for use in charts and
reports. This function takes a list of workflows and returns a data
frame with one row per `MetricID`.

## Usage

``` r
MakeMetric(lWorkflows)
```

## Arguments

- lWorkflows:

  A list of workflows, like the one returned by
  [`workr::MakeWorkflowList()`](https://gilead-public.github.io/workr/reference/MakeWorkflowList.html).

## Value

A data frame.

## Examples

``` r
lWorkflows <- list(
  kri0001 = list(meta = list(Type = "Analysis", ID = "kri0001")),
  kri0002 = list(meta = list(Type = "Analysis", ID = "kri0002"))
)
MakeMetric(lWorkflows)
#> # A tibble: 2 × 3
#>   Type     ID      MetricID        
#>   <chr>    <chr>   <chr>           
#> 1 Analysis kri0001 Analysis_kri0001
#> 2 Analysis kri0002 Analysis_kri0002
```
