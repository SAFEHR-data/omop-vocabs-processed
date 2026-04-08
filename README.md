# OMOP Processed Vocabularies

This repository hosts curated, versioned, pre‑processed OMOP vocabulary files used at UCLH.

------------------------------------------------------------------------

## Overview

-   **Source**: OHDSI Athena\
    <https://athena.ohdsi.org/>

-   **Format**: OMOP vocabulary CSV → **Parquet**

-   **Purpose**: Provide stable, versioned vocabularies for ETL, loading, and analysis

------------------------------------------------------------------------

## High‑level Proces

```         
Athena (OHDSI)
      |
      |  Manual download (CSV)
      v
Raw OMOP vocabularies
      |
      |  preprocess_omop_metadata()  
      v
Parquet vocabularies
      |
      |  Versioned release
```

### Summary

0. Local set-up (if not done before)
1. Vocabulary csv files downloaded from OHDSI [Athena](https://athena.ohdsi.org/vocabulary/list)
2. `preprocess_omop_metadata()` converts to parquet (beware that some vocabularies are filtered out)
3. Run summary report & check if result is as expected
4. New branch & PR created in [omop-vocabs-processed repository](https://github.com/SAFEHR-data/omop-vocabs-processed) with the new parquet files

The vocabulary files are used by :

- [download_omop_metadata()](download_omop_metadata.R) for omop_es ETL (Extract, Transform & Load)
- [omop-cascade](https://github.com/uclh-criu/omop-cascade) for database upload
- [omopcept](https://github.com/SAFEHR-data/omopcept) for vocab queries, joining & visualisation

---

## 0. Local set-up

- Install `git lfs`

git LFS (Large File Storage) is required because this repository contains large Parquet files. Git LFS stores these files outside of the main Git history, keeping the repository lightweight and preventing slow clones and bloated storage.

- If you haven't already set up `git lfs` with your git user account

  1. Download and install `git lfs` using [their instructions](https://git-lfs.com/)
  2. Set up git LFS with your git account
  
      ```shell
        git lfs install
      ```
    
- Clone this repository:

  ```shell
  git clone https://github.com/SAFEHR-data/omop-vocabs-processed.git
  ```

---

## 1. Download Vocabularies

-   The vocabularies are a **curated subset** of Athena downloads. In Athena, you have to pick or unpick boxes manually. From the **default settings**:

| vocab ID      | Brief description                                                 |
|-------------------------|-----------------------------------------------|
| **de-select** |                                                                   |
| 4             | CPT4                                                              |
| 9             | NDC                                                               |
| **select**    |                                                                   |
| 17,18         | Read, OXMIS                                                       |
| 34,35         | ICD10, ICD10PS                                                    |
| 55            | OPCS4 Interventions and Procedures (NHS)                          |
| 57            | HES Specialty                                                     |
| 75            | dm+d                                                              |
| 87            | Specimen Type                                                     |
| 90            | ICDO3                                                             |
| 111           | Episode Type                                                      |
| 117           | HemOnc                                                            |
| 134           | CIViC Clinical Interpretation of Variants in Cancer (civicdb.org) |
| 138,139       | NCIt NCI Thesaurus (National Cancer Institute), HGNC              |
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

## 4. Downloading Published Versions

Each release is published as a **Git tag** (e.g. `v20250827`).

### Download URL pattern

```         
https://github.com/SAFEHR-data/omop-vocabs-processed/raw/refs/tags/{tag}/{relative_path}
```
