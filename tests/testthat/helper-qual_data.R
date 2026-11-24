library(yaml)
# Ensure that the .onLoad() events of other packages have already triggered, so
# we can set the logger safely.
library(gsm.core)
library(gsm.mapping)
set.seed(123)

## Declare all the data
lQualSource <- gsm.core::lSource

# Step 0 - Data Ingestion - standardize tables/columns names
lData <- list(
  Raw_SUBJ = lQualSource$Raw_SUBJ,
  Raw_AE = lQualSource$Raw_AE,
  Raw_PD = lQualSource$Raw_PD %>%
    rename(subjid = subjectenrollmentnumber) %>%
    rename(dvdecod = crocategory) %>%
    rename(dvterm = description) %>%
    rename(dvdtm = deviationdate),
  Raw_LB = lQualSource$Raw_LB,
  Raw_STUDCOMP = lQualSource$Raw_STUDCOMP,
  Raw_SDRGCOMP = lQualSource$Raw_SDRGCOMP %>%
    mutate(phase = as.character(phase)),
  Raw_DATACHG = lQualSource$Raw_DATACHG %>%
    rename(subject_nsv = subjectname),
  Raw_DATAENT = lQualSource$Raw_DATAENT %>%
    rename(subject_nsv = subjectname),
  Raw_QUERY = lQualSource$Raw_QUERY %>%
    rename(subject_nsv = subjectname),
  Raw_ENROLL = lQualSource$Raw_ENROLL,
  Raw_SITE = lQualSource$Raw_SITE %>%
    rename(studyid = protocol) %>%
    rename(invid = pi_number) %>%
    rename(InvestigatorFirstName = pi_first_name) %>%
    rename(InvestigatorLastName = pi_last_name) %>%
    rename(City = city) %>%
    rename(State = state) %>%
    rename(Country = country),
  Raw_STUDY = lQualSource$Raw_STUDY %>%
    rename(studyid = protocol_number),
  Raw_PK = lQualSource$Raw_PK %>%
    rename(visit = foldername),
  Raw_IE = lQualSource$Raw_IE,
  Raw_VISIT = lQualSource$Raw_VISIT %>%
    rename(visit = foldername),
  Raw_OverallResponse = lQualSource$Raw_OverallResponse %>%
    rename(response_folder = foldername),
  Raw_Death = lQualSource$Raw_Death,
  Raw_Randomization = lQualSource$Raw_Randomization,
  Raw_VS = lQualSource$Raw_VS %>%
    rename(studyid = project) %>%
    rename(visit = foldername) %>%
    rename(bsa = bsaentry)
)

## Data with missing values (15% NA's)

## specify domains
domains <- c(gsub("Raw_", "", names(lData)), "COUNTRY", "EXCLUSION", "IPNS")

## Get Mapped data
mappings_wf <- workr::MakeWorkflowList(
  strNames = domains,
  strPath = file.path(
    system.file(package = "gsm.mapping"),
    "workflow",
    "1_mappings"
  )
)

mapping_output <- map(mappings_wf, ~ .x$steps[[1]]$output) %>% unlist()

# Built lazily (and once per process) so tests that don't need them don't pay
# the cost, and the qual tests share a single run.
delayedAssign(
  "mapped_data",
  quietly_run(workr::RunWorkflows(mappings_wf, lData))
)

delayedAssign(
  "kri_workflows",
  workr::MakeWorkflowList(
    strPath = test_path("fixtures", "workflow", "2_metrics")
  )
)

delayedAssign(
  "analyzed",
  quietly_run(workr::RunWorkflows(
    kri_workflows,
    lData = c(mapped_data, list(lWorkflows = kri_workflows))
  ))
)

delayedAssign(
  "reporting_workflows",
  workr::MakeWorkflowList(
    strPath = file.path(
      system.file(package = "gsm.reporting"),
      "workflow",
      "3_reporting"
    )
  )
)
