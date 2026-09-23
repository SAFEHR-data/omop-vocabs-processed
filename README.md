# OMOP Processed Vocabularies

This repository hosts curated, versioned, pre‑processed OMOP vocabulary files used at UCLH.

------------------------------------------------------------------------

## Overview

-   **Source**: [OHDSI Athena](https://athena.ohdsi.org/)

-   **Format**: OMOP vocabulary CSV → **Parquet**

-   **Purpose**: Provide stable, versioned vocabularies for ETL, loading, and analysis

------------------------------------------------------------------------

## High‑level Proces

``` mermaid
flowchart TD
    A["Athena (OHDSI)"] -->|"Manual download (CSV)"| B["Raw OMOP vocabularies"]
    B -->|"preprocess_omop_metadata()"| C["Parquet vocabularies"]
    C --> D["Versioned release"]
```

### Summary

0.  Local set-up (if not done before)
1.  Vocabulary csv files downloaded from OHDSI [Athena](https://athena.ohdsi.org/vocabulary/list)
2.  `preprocess_omop_metadata()` converts to parquet (beware that some vocabularies are filtered out)
3.  Run summary report & check if result is as expected
4.  Git: New branch & PR created in [omop-vocabs-processed repository](https://github.com/SAFEHR-data/omop-vocabs-processed) with the new parquet files + create tag and new release
5.  Downloading Published Versions

The vocabulary files are used by :

-   omop_es ETL as shown in this [redacted copy](https://github.com/SAFEHR-data/omop_es) by setting [version in the private repo](https://github.com/uclh-criu/omop_es/blob/f62bcf88dadd082d6cf287f4bc4ef04888845312/omop_metadata/omop_metadata_service.R#L1)
-   [omop-cascade](https://github.com/uclh-criu/omop-cascade) for database upload
-   [omopcept](https://github.com/SAFEHR-data/omopcept) for vocab queries, joining & visualisation

------------------------------------------------------------------------

## 0. Local set-up

-   Install `git lfs`

git LFS (Large File Storage) is required because this repository contains large Parquet files. Git LFS stores these files outside of the main Git history, keeping the repository lightweight and preventing slow clones and bloated storage.

-   If you haven't already set up `git lfs` with your git user account

    1.  Download and install `git lfs` using [their instructions](https://git-lfs.com/)

    2.  Set up git LFS with your git account

        ``` shell
          git lfs install
        ```

-   Clone this repository:

    ``` shell
    git clone https://github.com/SAFEHR-data/omop-vocabs-processed.git
    ```

------------------------------------------------------------------------

## 1. Download Vocabularies

-   The vocabularies are a **curated subset** of Athena downloads. In Athena, you have to pick or unpick boxes manually. From the **default settings**:

| vocab ID      | Brief description                                                 |
|-------------------------|-----------------------------------------------|
| **de-select** |                                                                   |
| 2             | ICD9CM, Clinical Modification, Volume 1 and 2 (NCHS)               |
| 3             | ICD9Proc, Clinical Modification, Volume 3 (NCHS)                  |
| 4             | CPT4                                                              |
| 9             | NDC                                                               |  
| 52            | SPL Structured Product Labeling (FDA)                             |
| 60            | ICD10CM, Clinical Modification (NCHS)                  |
| **select**    |                                                                   |
| 17,18         | Read, OXMIS                                                       |
| 34            | ICD10                                                             |
| 55            | OPCS4 Interventions and Procedures (NHS)                          |
| 57            | HES Specialty                                                     |
| 75            | dm+d                                                              |
| 87            | Specimen Type                                                     |
| 90            | ICDO3                                                             |
| 111           | Episode Type                                                      |
| 117           | HemOnc                                                            |
| 134           | CIViC Clinical Interpretation of Variants in Cancer (civicdb.org) |
| 138           | NCIt NCI Thesaurus (National Cancer Institute)                    |
| 141           | Cancer Modifier Diagnostic modifiers of Cancer (OMOP)             |
| 144           | UK Biobank                                                        |
| 146,147       | OMOP Genomic, OncoTree                                            |
| 154,155       | NHS Ethnic Category, NHS Place of Service                         |
| 156           | CDISC Clinical Data Interchange Standards Consortium              |

------------------------------------------------------------------------

## 2. Pre-process vocabularies for `omop_es`

```         
source('omop_metadata/preprocess_metadata.R')
preprocess_omop_metadata("path where downloaded vocabularies are located")
```

This saves the parquet files in the `omop-vocabs-processed/data` directory.

## 3. Summary outputs

Good way to check if updated vocabularies are as expected is to run `summaries/generate_summaries.R`.

-   Concept counts by vocabulary
    -   `summaries/freq_concepts_by_vocab.csv`
-   Row counts per OMOP vocabulary table + Athena version
    -   `summaries/nrows_per_vocab_file.csv`

------------------------------------------------------------------------

## 4. Commit/push changes

-   Update data files to the remote repository in a new branch - it only worked for me (@anabarbararc) when VPN was disconnected
-   Create a new tag with the vocabulary version (works before or after branch merge).

``` shell
git switch your-new-branch-name
git tag -a v20260829 -m "Release version 2026-08-29"
git push origin --tags
```

-   Go to your repo → Releases → "Draft a new release"
-   In "Choose a tag", select the tag you just pushed
-   In "Target", make sure it points to your new branch (not main) — this is the key step
-   Add a release title (e.g. v1.1.0 - Feature X)
-   Add release notes describing what changed
-   Click "Publish release"

If you need to replace a tagged version, delete the tag locally & remotely. Then re-release.
``` shell
git tag -d v20260829
git push origin --delete v20260829
```

------------------------------------------------------------------------

## 5. Downloading Published Versions

Each release is published as a **Git tag** (e.g. `v20260829`).

### Download URL pattern

You can download a specific tagged version using https. in this format, replacing the curly braced values:

`https://github.com/SAFEHR-data/omop-vocabs-processed/raw/refs/tags/{tag}/{relative_path}`

For example for `v20260829` data file for the `data/version.txt`:

### R

``` r
tag = "v20260829"
relative_path = "data/concept.parquet"
download_url = glue::glue("https://github.com/SAFEHR-data/omop-vocabs-processed/raw/refs/tags/{tag}/{relative_path}")
download.file(download_url,
              destfile = "concept.parquet",
              mode = "wb")
              
relative_path = "data/concept_relationship.parquet"
download_url = glue::glue("https://github.com/SAFEHR-data/omop-vocabs-processed/raw/refs/tags/{tag}/{relative_path}")
download.file(download_url,
              destfile = "concept_relationship.parquet",
              mode = "wb")              
```

### Python

``` python
import urllib.request

tag = "v20260829"
relative_path = "data/concept.parquet"
download_url = f"https://github.com/SAFEHR-data/omop-vocabs-processed/raw/refs/tags/{tag}/{relative_path}"
local_filename = "concept.parquet"

urllib.request.urlretrieve(download_url, local_filename)
```

### Shell

``` shell
export OMOP_METADATA_VERSION=v20260829
export OMOP_METADATA_PATH=data/concept.parquet
curl -L -o concept.parquet "https://github.com/SAFEHR-data/omop-vocabs-processed/raw/refs/tags/${OMOP_METADATA_VERSION}/${OMOP_METADATA_PATH}"
```
