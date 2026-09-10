# Step-by-Step Reporting Workflow

## Introduction

This vignette walks users through the mechanics of the functions and
workflows that produce all of the Reporting output within the
[gsm.reporting](https://gilead-public.github.io/gsm.reporting/) package.
The `{gsm}` suite of packages leverages Key Risk Indicators (KRIs) and
thresholds to conduct study-level, country-level and site-level Risk
Based Monitoring for clinical trials.

These functions and workflows produce data frames, visualizations,
metadata, and reports to be used in reporting and error checking at
clinical sites. The image below illustrates the overarching context in
which the reporting workflow runs, taking inputs from both the output of
the analytics workflow, as well as raw study-, site-, and country-level
data in the Raw/Raw+ format.

![](data_model_detailed.png)

All of the functions to create the data frames in the reporting data
model will run automatically and sequentially when a user specifies the
metadata and data needed for the report, and calls
[`workr::RunWorkflow()`](https://rdrr.io/pkg/workr/man/RunWorkflow.html)
on the YAML files in the `workflow/3_reporting` directory. To create a
report, the output of the reporting YAMLs is fed into the YAMLs in the
`workflow/4_modules` directory to produce an HTML document with all
charts and tables created in the reporting workflow. For a more detailed
discussion of the YAML file and directory structure, see the
[`{gsm.core}` Extensions
vignette](https://gilead-public.github.io/gsm.core/articles/gsmExtensions.html).

Each of the individual functions can also be run independently outside
of a specified yaml workflow.

For the purposes of this documentation, we will evaluate the input(s)
and output(s) of each individual function for a specific KRI to show the
stepwise progression of how a yaml workflow is set up to handle and
process reporting-level data.

------------------------------------------------------------------------

### Case Study - Step-by-Step Full Site-Level Report

We will use sample clinical data simulated from the
[`{gsm.datasim}`](https://github.com/Gilead-Public/gsm.datasim) package
to run the full site-level report for all 12 KRIs included in this
package. The focus of this vignette is the reporting workflow, so the
output of the analytics workflow will be briefly discussed, but only in
the context of *inputs* to the reporting workflow.

Additional supporting functions are explored in [Appendix
1](#appendix-1).

#### Step 0 - Run Analysis Workflow(s)

Prior to running the reporting model to create reporting data frames,
charts and reports, the metrics we are reporting on must be properly
calculated and flagged with the analysis workflow. For more information
on the Analysis Workflow, see the associated `vignette("DataAnalysis")`.

To run the analysis workflow on all 13 KRIs using `clindata` Raw+ data,
use the code snippet below. From this, three pieces of output will be
used in the reporting workflow:

1.  `lAnalysis` - list of data frames in the analysis data model
2.  `lWorkflow` - list containing the metadata for each of the KRIs
3.  `mapped$Mapped_SUBJ` - mapped data.frame of enrolled participants

``` r

core_mappings <- c("AE", "COUNTRY", "DATACHG", "DATAENT", "ENROLL", "LB", "PK", "VISIT", "Death", "OverallResponse", "Randomization",
                   "PD", "QUERY", "STUDY", "STUDCOMP", "SDRGCOMP", "SITE", "SUBJ", "IE", "EXCLUSION", "IPNS")

lSource <- gsm.core::lSource

# Step 0 - Data Ingestion - standardize tables/columns names
mappings_wf <- workr::MakeWorkflowList(strPath = "workflow/1_mappings", 
                                       strNames = core_mappings,
                                       strPackage = "gsm.mapping")
mappings_spec <- CombineSpecs(mappings_wf)
lRaw <- Ingest(lSource, mappings_spec)

# Step 1 - Create Mapped Data Layer - filter, aggregate and join raw data to create mapped data layer
mapped <- workr::RunWorkflows(mappings_wf, lRaw)

# Step 2 - Create Metrics - calculate metrics using mapped data
metrics_wf <- workr::MakeWorkflowList(strPath = "workflow/2_metrics", strNames = "kri", strPackage = "gsm.kri")
lAnalysis <- workr::RunWorkflows(metrics_wf, mapped)
#> Warning: 1 values of [ GroupID ] with a [ Denominator ] value of 0 removed.
#> 1 values of [ GroupID ] with a [ Denominator ] value of 0 removed.
#> 1 values of [ GroupID ] with a [ Denominator ] value of 0 removed.
#> 1 values of [ GroupID ] with a [ Denominator ] value of 0 removed.
#> Warning: 7 values of [ GroupID ] with a [ Denominator ] value of 0
#> removed.
#> Warning: 13 values of [ GroupID ] with a [ Denominator ] value of 0
#> removed.
```

#### Step 1 - Create Reporting Model Data Frames

With all necessary inputs to the reporting model created, we can move on
to generate the reporting data model data frames. These data frames
created are as follows:

1.  `dfGroups`: Group-level metadata dictionary. Created by passing CTMS
    site and study data to `MakeLongMeta()`.
2.  `dfMetrics`: Metric-specific metadata for use in charts and
    reporting. Created by passing an `lWorkflow` object to
    [`MakeMetric()`](https://gilead-public.github.io/gsm.reporting/dev/reference/MakeMetric.md).
3.  `dfResults`: A stacked summary of analysis pipeline output. Created
    by passing a list of results returned by
    [`Summarize()`](https://gilead-biostats.github.io/gsm.core/reference/Summarize.html)
    to
    [`BindResults()`](https://gilead-public.github.io/gsm.reporting/dev/reference/BindResults.md).
4.  `dfBounds`: Set of predicted percentages/rates and upper- and
    lower-bounds across the full range of sample sizes/total exposure
    values for reporting. Created by passing `dfResults` and `dfMetrics`
    to
    [`MakeBounds()`](https://gilead-public.github.io/gsm.reporting/dev/reference/MakeBounds.md).

For more details on any of these tables, see `vignette("DataModel")`.

The following sub-steps will dive into the creation and structure of
each of these tables. Sample data for each of these tables can found in
`{gsm}` as `reportingGroups`, `reportingMetrics`, `reportingResults` and
`reportingBounds`. These sample tables are used throughout the package
in examples and documentation.

##### Step 1.1 - Transform CTMS data into `dfGroups` data frame

The `dfGroups` data frame is critical to providing site-, study- and
country-level information in the final report. This table is based on
CTMS data and the mapped `dfEnrolled` data frame created in the Analysis
workflow. Creating this table requires the creation of 5 smaller tables
that summarize the data at each group level using
[`workr::RunQuery()`](https://rdrr.io/pkg/workr/man/RunQuery.html) and
`MakeLongMeta()`. These small tables are then bound together to create
`dfGroups`.

``` r

#Transform CTMS Site and Study Level data
dfCTMSSite <- workr::RunQuery(df = lSource$Raw_SITE, 
                                 strQuery = "SELECT pi_number as GroupID, site_status as Status, pi_first_name as InvestigatorFirstName, pi_last_name as InvestigatorLastName, city as City, state as State, country as Country, * FROM df") |>
  gsm.mapping::MakeLongMeta(strGroupLevel = 'Site')

dfCTMSStudy <- workr::RunQuery(df = lSource$Raw_STUDY,
                                  strQuery = "SELECT protocol_number as GroupID, status as Status, * FROM df") |>
  gsm.mapping::MakeLongMeta(strGroupLevel = 'Study')

# Get Participant and Site counts for Country, Site and Study
dfSiteCounts <- workr::RunQuery(df = mapped$Mapped_SUBJ,
                                   strQuery = "SELECT invid as GroupID, COUNT(DISTINCT subjid) as ParticipantCount, COUNT(DISTINCT invid) as SiteCount FROM df GROUP BY invid") |>
  gsm.mapping::MakeLongMeta(strGroupLevel = "Site")

dfStudyCounts <- workr::RunQuery(df = mapped$Mapped_SUBJ,
                             strQuery = "SELECT studyid as GroupID, COUNT(DISTINCT subjid) as ParticipantCount, COUNT(DISTINCT invid) as SiteCount FROM df GROUP BY studyid") |>
  gsm.mapping::MakeLongMeta(strGroupLevel = "Study")

dfCountryCounts <- workr::RunQuery(df = mapped$Mapped_SUBJ,
                             strQuery = "SELECT country as GroupID, COUNT(DISTINCT subjid) as ParticipantCount, COUNT(DISTINCT invid) as SiteCount FROM df GROUP BY country") |>
  gsm.mapping::MakeLongMeta(strGroupLevel = "Country")


# Combine CTMS and Counts data as dfGroups
dfGroups <- dplyr::bind_rows(SiteCounts = dfSiteCounts, 
                      StudyCounts = dfStudyCounts, 
                      CountryCounts = dfCountryCounts, 
                      Site = dfCTMSSite, 
                      Study = dfCTMSStudy)
```

The resulting `dfGroups` dataframe contains the following columns:

- `GroupID`: Group Identifier
- `GroupLevel`: Type of Group specified in `GroupID` (Country, Site,
  Study)
- `Param`: Parameter Name (e.g. “Status”)  
- `Value`: Parameter Value (e.g. “Active”)

A more detailed explanation of the `Param`s for each group level can be
found in `vignette("DataModel")`.

##### Step 1.2 - Create `dfMetrics` Metadata

The `dfMetrics` table contains the metadata for each of the KRIs in the
report. This information comes from the `meta` section of the metric
workflows, `metrics_wf` defined in Step 0. Using this workflow
information as the input,
[`MakeMetric()`](https://gilead-public.github.io/gsm.reporting/dev/reference/MakeMetric.md)
is used to produce a data frame with one row per metric.

``` r

dfMetrics <- gsm.reporting::MakeMetric(lWorkflows = metrics_wf)
```

The resulting `dfMetrics` dataframe contains the following columns:

- `File`: The yaml file for workflow
- `MetricID`: ID for the Metric
- `Group`: The group type for the metric (e.g. “Site”)
- `Abbreviation`: Abbreviation for the metric
- `Metric`: Name of the metric
- `Numerator`: Data source for the Numerator
- `Denominator`: Data source for the Denominator
- `Model`: Model used to calculate metric
- `Score`: Type of Score reported
- `Threshold`: Thresholds to be used for bounds and flags

##### Step 1.3 - Stack `dfSummary` data into `dfResults`

The reporting workflow requires that all metrics are stacked into a
single data frame, `dfResults`. This stacked data frame is created by
feeding the `lAnalysis` list from the analysis workflow into
[`BindResults()`](https://gilead-public.github.io/gsm.reporting/dev/reference/BindResults.md)
along with the snapshot date and the study id.

``` r

dfResults <- gsm.reporting::BindResults(lAnalysis = lAnalysis,
                                        strName = "Analysis_Summary",
                                        dSnapshotDate = Sys.Date(),
                                        strStudyID = "ABC-123")
```

The resulting `dfResults` data frame contains the following columns:

- `GroupID`: Group Identifier
- `GroupLevel`: Type of Group specified in `GroupID` (Country, Site,
  Study)
- `Numerator`: The calculated numerator value
- `Denominator`: The calculated denominator value  
- `Metric`: The calculated rate/metric value
- `Score`: The calculated metric score
- `Flag`: The calculated flag
- `MetricID`: The Metric ID
- `StudyID`: The Study ID
- `SnapshotDate`: The Date of the snapshot

##### Step 1.4 - Create `dfBounds` for Confidence Intervals

Several of the charts created for the KRI reports use confidence
intervals and bounds to delineate the observations based on the flag
they receive (no flag, amber or red). In order to create the data frame
that contains the information about these boundaries, `dfBounds`,
`dfResults` and `dfMetrics` is fed into the
[`MakeBounds()`](https://gilead-public.github.io/gsm.reporting/dev/reference/MakeBounds.md)
function. The
[`MakeBounds()`](https://gilead-public.github.io/gsm.reporting/dev/reference/MakeBounds.md)
function is a wrapper around the `Analyze_*_PredictBounds()` functions
that create the bounds based on the model used to estimate the
metric(Normal Approximation or Poisson).

``` r

dfBounds <- gsm.reporting::MakeBounds(dfResults = dfResults,
                                      dfMetrics = dfMetrics)
#> Creating stacked dfBounds data for strMetrics
#> Parsed -2,-1,2,3 to numeric vector: -2, -1, 2, 3
#> nStep was not provided. Setting default step to 2.82.
#> Parsed -2,-1,2,3 to numeric vector: -2, -1, 2, 3
#> nStep was not provided. Setting default step to 2.82.
#> Parsed -3,-2,2,3 to numeric vector: -3, -2, 2, 3
#> nStep was not provided. Setting default step to 2.82.
#> Parsed -3,-2,2,3 to numeric vector: -3, -2, 2, 3
#> nStep was not provided. Setting default step to 2.82.
#> Parsed 2,3 to numeric vector: 2, 3
#> nStep was not provided. Setting default step to 15.812.
#> Parsed 2,3 to numeric vector: 2, 3
#> nStep was not provided. Setting default step to 0.056.
#> Parsed 2,3 to numeric vector: 2, 3
#> nStep was not provided. Setting default step to 0.056.
#> Parsed 2,3 to numeric vector: 2, 3
#> nStep was not provided. Setting default step to 28.672.
#> Parsed 2,3 to numeric vector: 2, 3
#> nStep was not provided. Setting default step to 1.792.
#> Parsed 2,3 to numeric vector: 2, 3
#> nStep was not provided. Setting default step to 7.168.
#> Parsed 2,3 to numeric vector: 2, 3
#> nStep was not provided. Setting default step to 28.672.
#> Parsed -3,-2,2,3 to numeric vector: -3, -2, 2, 3
#> nStep was not provided. Setting default step to 0.068.
#> Parsed 0.9,0.85 to numeric vector: 0.9, 0.85
#> Parsed 1.5,2.5 to numeric vector: 1.5, 2.5
#> Parsed 1,2 to numeric vector: 1, 2
#> Parsed 2,3 to numeric vector: 2, 3
#> nStep was not provided. Setting default step to 0.056.
```

The resulting `dfBounds` data frame contains the following columns:

- `Threshold`: The number of standard deviations that the upper and
  lower bounds are based on
- `Denominator`: The calculated denominator value
- `LogDenominator`: The calculated log denominator value
- `Numerator`: The calculated numerator value
- `Metric`: The calculated rate/metric value
- `MetricID`: The Metric ID
- `StudyID`: The Study ID
- `SnapshotDate`: The Date of the snapshot

#### Step 2 - Create Visualizations

Now that all of the data frames in the reporting data model have been
created, we can create the charts that display this data in a useful and
easily interpreted way. All four of the data frames created in Step 1
are fed into the `MakeCharts()` function to create all relevant charts
given the input data. `MakeCharts()` is a wrapper around several helper
functions that generate each static visualization and JS widget
individually. Appendix 1 goes into more detail about each of these
individual functions.

``` r

lCharts <- gsm.kri::MakeCharts(dfResults = dfResults,
                               dfGroups = dfGroups,
                               dfBounds = dfBounds,
                               dfMetrics = dfMetrics)
```

The output of `MakeCharts` is a list containing the following charts: -
`scatterJS`: A scatter plot using JavaScript. - `scatter`: A scatter
plot using ggplot2. - `barMetricJS`: A bar chart using JavaScript with
metric on the y-axis. - `barScoreJS`: A bar chart using JavaScript with
score on the y-axis. - `barMetric`: A bar chart using ggplot2 with
metric on the y-axis. - `barScore`: A bar chart using ggplot2 with score
on the y-axis. - `timeSeriesContinuousScoreJS`: A time series chart
using JavaScript with score on the y-axis. -
`timeSeriesContinuousMetricJS`: A time series chart using JavaScript
with metric on the y-axis. - `timeSeriesContinuousNumeratorJS`: A time
series chart using JavaScript with numerator on the y-axis.

If the data only contains one snapshot data then the `timeseries` charts
will not be created.

Below are the static and interactive versions of the scatter plot for
the AE KRI:

``` r

lCharts$Analysis_kri0001$scatter
```

``` r


lCharts$Analysis_kri0001$scatterJS
#> NULL
```

#### Step 3 - Generate Report

All of the components are created to generate the HTML report for the
study we are working on. In order to generate this report and save it
locally, simply feed `lCharts`, `dfResults`, `dfGroups`, `dfMetrics` and
(optionally) an absolute directory path and file to which the report
will be saved (`strOutputDir` and `strOutputFile`, respectively) into
`Report_KRI()` and the HTML output will be knit from the
`Report_KRI.Rmd` template. All intermediate files from the knitting
process will be saved in a temporary folder.

``` r

lReport <- gsm.kri::Report_KRI(lCharts = lCharts,
                               dfResults = dfResults,
                               dfGroups = dfGroups,
                               dfMetrics = dfMetrics,
                               strOutputFile = "test_kri_report.html")
```

Below, you will see a screenshot from the beginning of the report. All
charts for all metrics that were included throughout the analysis and
reporting workflows will be included in this report.

![](report_screenshot.png)

------------------------------------------------------------------------

### Using YAML Workflows to generate reports

While it is helpful to understand how each step of this process works,
we have provided a series of YAML workflow files that make running
reports on multiple KRIs easy and with the ability to be automated.

Here, you will see how to run your workflows. The general approach is to
run the analytics workflow(s), followed by the reporting workflow
`data_reporting.yaml` followed by the charts and reports workflow
`reports.yaml`. This allows the user to examine the output of each
workflow individually before moving on to the next step.

#### Option 1 - Run All Workflows Separately

``` r

# Step 1 - Create Mapped Data - filter/map raw data
# Source Data
core_mappings <- c("AE", "COUNTRY", "DATACHG", "DATAENT", "ENROLL", "LB", "PK", "VISIT",
                   "PD", "QUERY", "STUDY", "STUDCOMP", "SDRGCOMP", "SITE", "SUBJ")

lSource <- gsm.core::lSource

# Step 0 - Data Ingestion - standardize tables/columns names
mappings_wf <- workr::MakeWorkflowList(strNames = core_mappings, strPath = "workflow/1_mappings", strPackage = "gsm.mapping")
mappings_spec <- gsm.mapping::CombineSpecs(mappings_wf)
lRaw <- gsm.mapping::Ingest(lSource, mappings_spec)

# Step 1 - Create Mapped Data Layer - filter, aggregate and join raw data to create mapped data layer
mapped <- workr::RunWorkflows(mappings_wf, lRaw)

# Step 2 - Create Metrics - calculate metrics using mapped data
metrics_wf <- workr::MakeWorkflowList(strPath = "workflow/2_metrics", strPackage = "gsm.kri")
analyzed <- workr::RunWorkflows(metrics_wf, mapped)

# Step 3 - Create Reporting Layer - create reports using metrics data
reporting_wf <- workr::MakeWorkflowList(strPath = "workflow/3_reporting", strPackage = "gsm.reporting")
reporting <- workr::RunWorkflows(reporting_wf, c(mapped, list(lAnalyzed = analyzed, lWorkflows = metrics_wf)))

# Step 4 - Create KRI Report - create KRI report using reporting data
module_wf <- workr::MakeWorkflowList(strPath = "workflow/4_modules", strPackage = "gsm.kri")
lReports <- workr::RunWorkflows(module_wf, reporting)
```

|  |
|:---|
| \## Incorporating Historical data into the Reporting Output |
| Using the output from the section above, you can modify the reporting workflow to include historical data by feeding the historical data into [`workr::RunWorkflows`](https://rdrr.io/pkg/workr/man/RunWorkflows.html) as a component of the `lData` argument. |
| By including the `Reporting_Results_Longitudinal` data.frame, the [`CalculateChange()`](https://gilead-public.github.io/gsm.reporting/dev/reference/CalculateChange.md) function is triggered. This function calculates the change in the value (`_Change`) and the percentage change in the value (`_PercentChange`) between the previous snapshot and the current snapshot for all Reporting Result metrics. This is useful for longitudinal studies where you want to compare current results with past snapshots. |
| \`\`\` r \# Prepare historical data historical \<- gsm.core::reportingResults %\>% filter(SnapshotDate == “2025-03-01”) |
| \# Re-run reporting model and KRI report with historical data reporting_long \<- workr::RunWorkflows(reporting_wf, lData = c(mapped, list(lAnalyzed = analyzed, Reporting_Results_Longitudinal = historical, lWorkflows = metrics_wf))) lReports_long \<- workr::RunWorkflows(module_wf, reporting_long) \`\`\` |
| Reporting data with this historical trend will produce an additional section of the KRI report which highlights the “Flags Changed” from the previous snapshot to the current snapshot. This section will look like the following: |
| ![](flags_changed_report.png) |

#### Recap - Reporting Workflow

- `dfGroups` created from CTMS data using
  [`workr::RunQuery()`](https://rdrr.io/pkg/workr/man/RunQuery.html),
  `MakeLongMeta()` and `bind_rows()`
- `dfMetrics` created from `lWorkflow` using
  [`MakeMetric()`](https://gilead-public.github.io/gsm.reporting/dev/reference/MakeMetric.md)
- `dfResults` created from `lAnalysis$dfSummary` using
  [`BindResults()`](https://gilead-public.github.io/gsm.reporting/dev/reference/BindResults.md)
- `dfBounds` created from `dfResults` using
  [`MakeBounds()`](https://gilead-public.github.io/gsm.reporting/dev/reference/MakeBounds.md)
- List of all charts and tables (`lCharts`) created from `dfResults`,
  `dfBounds`, `dfMetrics` and `dfGroups` using `MakeCharts()`
- Report generated from `lCharts`, `dfResults`, `dfMetrics` and
  `dfGroups` using `Report_KRI()`

------------------------------------------------------------------------

## Appendix 1 - Supporting Functions

#### Mapping Functions

- [`workr::RunQuery()`](https://rdrr.io/pkg/workr/man/RunQuery.html):
  Run a SQL query to create new data.frames with filtering and column
  name specifications.

#### Visualization Functions

- [`gsm.kri::Visualize_Scatter()`](https://gilead-public.github.io/gsm.kri/reference/Visualize_Scatter.html):
  Creates scatter plot of Total Exposure (in days, on log scale) vs
  Total Number of Event(s) of Interest (on linear scale). Each data
  point represents one site. Outliers are plotted in red with the site
  label attached. This plot is only created when statistical method is
  **not** defined as `identity`. Chart is called `scatter` in the
  `lCharts` object.
- [`gsm.kri::Visualize_Score()`](https://gilead-public.github.io/gsm.kri/reference/Visualize_Score.html):
  Provides a standard visualization for Score or KRI. Charts are called
  `barScore` or `barMetric` in the `lCharts` object.
- [`gsm.kri::Visualize_Metric()`](https://gilead-public.github.io/gsm.kri/reference/Visualize_Metric.html):
  Creates all available charts and tables for a metric using the data
  provided.

#### Widget Functions

- [`gsm.kri::Widget_GroupOverview()`](https://gilead-public.github.io/gsm.vizr/reference/Widget_GroupOverview.html):
  Creates an interactive table displaying the flag distribution for all
  groups across all metrics.
- [`gsm.kri::Widget_BarChart()`](https://gilead-public.github.io/gsm.vizr/reference/Widget_BarChart.html):
  Creates an interactive bar chart visualization for Score or KRI.
  Charts are called `barScoreJS` or `barMetricJS` in the `lCharts`
  object.
- [`gsm.kri::Widget_ScatterPlot()`](https://gilead-public.github.io/gsm.vizr/reference/Widget_ScatterPlot.html):
  Creates an interactive scatter plot of Total Exposure (in days, on log
  scale) vs Total Number of Event(s) of Interest (on linear scale). Each
  data point represents one site. Outliers are plotted in red with the
  site label attached.Chart is called `scatterJS` in the `lCharts`
  object.
- [`gsm.kri::Widget_TimeSeries()`](https://gilead-public.github.io/gsm.vizr/reference/Widget_TimeSeries.html):
  Creates an interactive time series scatter plot of the score, metric
  or numerator. Charts are called `timeSeriesContinuousScoreJS`,
  `timeSeriesContinuousMetricJS`, or `timeSeriesContinuousNumeratorJS`
  in the `lCharts` object.

#### Table Functions

- [`gsm.kri::Report_MetricTable()`](https://gilead-public.github.io/gsm.kri/reference/Report_MetricTable.html):
  Creates a sortable table displaying the flags per group (e.g. Site,
  Country) for one metric at a time.
