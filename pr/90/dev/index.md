# gsm.reporting

The {gsm} ecosystem provides a standardized Risk Based Quality
Monitoring (RBQM) framework for clinical trials that pairs a flexible
data pipeline with robust reports like the one shown below.

![](reference/figures/gsm_report_screenshot_1.png)

The [gsm.reporting](https://gilead-public.github.io/gsm.reporting/)
package provides the necessary functions and workflows to produce the
reporting data model that is used by many packages to produce
visualizations and reports. This README provides a high-level overview
of {gsm.reporting}; see the [gsm Reporting
Vignette](https://gilead-public.github.io/gsm.reporting/gsmReporting.html)
for additional details.

With all necessary inputs to the reporting model created via functions
in [gsm.mapping](https://github.com/Gilead-Public/gsm.mapping) and
[gsm.core](https://gilead-public.github.io/gsm.core),
[gsm.reporting](https://gilead-public.github.io/gsm.reporting/)
generates the reporting data model data frames. These data frames
created are as follows:

1.  `dfGroups`: Group-level metadata dictionary. Created by passing CTMS
    site and study data to `MakeLongMeta()`.
2.  `dfMetrics`: Metric-specific metadata for use in charts and
    reporting. Created by passing an `lWorkflow` object to
    [`MakeMetric()`](https://gilead-public.github.io/gsm.reporting/dev/reference/MakeMetric.md).
3.  `dfResults`: A stacked summary of analysis pipeline output. Created
    by passing a list of results returned by `Summarize()` to
    [`BindResults()`](https://gilead-public.github.io/gsm.reporting/dev/reference/BindResults.md).
4.  `dfBounds`: Set of predicted percentages/rates and upper- and
    lower-bounds across the full range of sample sizes/total exposure
    values for reporting. Created by passing `dfResults` and `dfMetrics`
    to
    [`MakeBounds()`](https://gilead-public.github.io/gsm.reporting/dev/reference/MakeBounds.md).

## Installation

You can install the latest release of gsm.reporting from
[GitHub](https://github.com/) with:

``` r

# install.packages("pak")
pak::pak("Gilead-Public/gsm.reporting@*release")
```

You can install the development version of gsm.reporting from
[GitHub](https://github.com/) with:

``` r

# install.packages("pak")
pak::pak("Gilead-Public/gsm.reporting")
```
