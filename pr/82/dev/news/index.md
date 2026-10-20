# Changelog

## gsm.reporting (development version)

## gsm.reporting 1.1.7

This patch release removes the log4r package dependency, because the
log4r package was archived on CRAN
([\#66](https://github.com/Gilead-Public/gsm.reporting/issues/66)).

## gsm.reporting 1.1.6

This release migrates workflow orchestration to the new `workr` package
and improves how metric metadata flows through to reports.

**Changes:** - Workflow orchestration functions (such as
[`MakeWorkflowList()`](https://gilead-biostats.github.io/gsm.core/reference/MakeWorkflowList.html)
and
[`RunWorkflows()`](https://gilead-biostats.github.io/gsm.core/reference/RunWorkflows.html))
are now provided by the new `workr` package. Documentation and examples
have been updated to reference `workr::` in place of `gsm.core::`. -
[`MakeMetric()`](https://gilead-public.github.io/gsm.reporting/dev/reference/MakeMetric.md)
now passes through all metadata fields defined on a workflow (for
example `Active` and `GenerateRiskSignal`), so custom metadata is
preserved in the metrics data used by charts and reports
([\#62](https://github.com/Gilead-Public/gsm.reporting/issues/62)). -
The bundled reporting workflows (Bounds, Groups, Metrics, Results) now
set `Active: true` so they are included by default when running the
reporting pipeline.

## gsm.reporting 1.1.5

This patch release updates the GitHub action workflows to align with the
new federated action framework in `gsm.utils`

## gsm.reporting 1.1.4

This patch release primarily focuses on tightening quality control (new
qualitative tests + qcthat automation) and aligning docs/dependencies
with the RC versions of upstream `gsm.*` packages.

**Changes:** - Add qualitative test helpers + new qual test cases (T15.1
/ T15.2) for reporting outputs and deltas. - Add qcthat GitHub Action
workflow and repo guidance docs (agents + documentation skill).

## gsm.reporting 1.1.3

This patch release adds new contributor guidelines and standardized
issue templates, as well as a small edit to resolve a
[bug](https://github.com/Gilead-Public/gsm.reporting/issues/25)
in[`MakeBounds()`](https://gilead-public.github.io/gsm.reporting/dev/reference/MakeBounds.md)

## gsm.reporting 1.1.2

This patch release addresses changes to an `.rda` object updated in
`gsm.core` v1.1.3.

## gsm.reporting 1.1.1

This patch release adds a section about incorporating historical data
into the reporting data model, and updates tests to comply with new
gsm.core sample data.

## gsm.reporting 1.1.0

This minor release adds the capability to calculate the change of
user-specified metrics from the previous snapshot date. The primary use
case of this function is to check for changes in the metrics when
determining if continued flags should be actioned.

Edits have been made to the Results.yaml to support this functionality
when longitudinal data is provided.

## gsm.reporting 1.0.2

This patch release updates the description file to incorporate min
version for `gsm` packages.

## gsm.reporting v1.0.1

This patch release updates tests in order to align with the new package
data from `gsm.core v1.1.0`

## gsm.reporting v1.0.0

We are pleased to introduce the first major release of the
`gsm.reporting` package, which powers the GSM reporting data model and
orchestrates the workflows for generating reports within the GSM
pipeline. This release marks a significant milestone, the release of a
modularized ecosystem for the GSM pipeline.

### Key Updates:

- **Qualification Report GitHub Actions (GHA):**  
  A new GitHub Actions workflow has been integrated for generating
  qualification reports, streamlining the process and automating report
  generation for better efficiency.  
  [PR](https://github.com/Gilead-Public/gsm.reporting/pull/12)
  [\#12](https://github.com/Gilead-Public/gsm.reporting/issues/12)

- **Replacement of `clindata` with `gsm.datasim`:**  
  The outdated `clindata` data has been replaced with `gsm.datasim`, a
  more advanced and reliable module for data simulation.  
  [PR](https://github.com/Gilead-Public/gsm.reporting/pull/13)
  [\#13](https://github.com/Gilead-Public/gsm.reporting/issues/13)

- **Vignette Updates and Enhancements:**  
  Several changes have been made to improve the documentation, to ensure
  users can easily navigate the reporting workflows.  
  [PR](https://github.com/Gilead-Public/gsm.reporting/pull/14)
  [\#14](https://github.com/Gilead-Public/gsm.reporting/issues/14)

### Additional Changes:

- Various bug fixes have been implemented to improve the stability of
  the package.

For more details, please refer to the pull requests linked above.

Happy reporting!

## gsm.reporting v0.0.1

This initial release migrates the reporting data model functions,
workflows and documentation from `{gsm}` to
[gsm.reporting](https://gilead-public.github.io/gsm.reporting/).
