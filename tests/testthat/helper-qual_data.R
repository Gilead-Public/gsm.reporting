library(yaml)
# Ensure that the .onLoad() events of other packages have already triggered, so
# we can set the logger safely.
library(gsm.core)
library(gsm.mapping)
set.seed(123)

## Declare all the data
lSource <- gsm.core::lSource

# Step 0 - Data Ingestion - standardize tables/columns names
lData <- list(
  Raw_SUBJ = lSource$Raw_SUBJ,
  Raw_AE = lSource$Raw_AE,
  Raw_PD = lSource$Raw_PD %>%
    rename(subjid = subjectenrollmentnumber) %>%
    rename(dvdecod = crocategory) %>%
    rename(dvterm = description) %>%
    rename(dvdtm = deviationdate),
  Raw_LB = lSource$Raw_LB,
  Raw_STUDCOMP = lSource$Raw_STUDCOMP,
  Raw_SDRGCOMP = lSource$Raw_SDRGCOMP %>%
    mutate(phase = as.character(phase)),
  Raw_DATACHG = lSource$Raw_DATACHG %>%
    rename(subject_nsv = subjectname),
  Raw_DATAENT = lSource$Raw_DATAENT %>%
    rename(subject_nsv = subjectname),
  Raw_QUERY = lSource$Raw_QUERY %>%
    rename(subject_nsv = subjectname),
  Raw_ENROLL = lSource$Raw_ENROLL,
  Raw_SITE = lSource$Raw_SITE %>%
    rename(studyid = protocol) %>%
    rename(invid = pi_number) %>%
    rename(InvestigatorFirstName = pi_first_name) %>%
    rename(InvestigatorLastName = pi_last_name) %>%
    rename(City = city) %>%
    rename(State = state) %>%
    rename(Country = country),
  Raw_STUDY = lSource$Raw_STUDY %>%
    rename(studyid = protocol_number),
  Raw_PK = lSource$Raw_PK %>%
    rename(visit = foldername),
  Raw_IE = lSource$Raw_IE,
  Raw_VISIT = lSource$Raw_VISIT %>%
    rename(visit = foldername),
  Raw_OverallResponse = lSource$Raw_OverallResponse %>%
    rename(response_folder = foldername),
  Raw_Death = lSource$Raw_Death,
  Raw_Randomization = lSource$Raw_Randomization
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

gsm.core::SetLogLevel("ERROR")
mapped_data <- workr::RunWorkflows(mappings_wf, lData)
gsm.core::SetLogLevel("DEBUG")

mapping_output <- map(mappings_wf, ~ .x$steps[[1]]$output) %>% unlist()
