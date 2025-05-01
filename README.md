# OMOP Processed Vocabularies

Repository for pre-processed vocabularies for working with the [OMOP CDM](https://ohdsi.github.io/CommonDataModel/) at UCLH.

You can download these files directly or follow the local development instructions to use git to clone the files

## Downloading versions

You can download a specific tagged version using https.
in this format, replacing the curly braced values:

`https://github.com/SAFEHR-data/omop-vocabs-processed/raw/refs/tags/{tag}/{relative_path}`

For example for `v5` data file for the `data/version.txt`:

### R

```r
tag = "v5"
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

```python
import urllib.request

tag = "v5"
relative_path = "data/concept.parquet"
download_url = f"https://github.com/SAFEHR-data/omop-vocabs-processed/raw/refs/tags/{tag}/{relative_path}"
local_filename = "concept.parquet"

urllib.request.urlretrieve(download_url, local_filename)
```
### Shell

```shell
export OMOP_METADATA_VERSION=v5
export OMOP_METADATA_PATH=data/concept.parquet
curl -L -o concept.parquet "https://github.com/SAFEHR-data/omop-vocabs-processed/raw/refs/tags/${OMOP_METADATA_VERSION}/${OMOP_METADATA_PATH}"
```

## Brief summary of vocabs

### R

After downloading as indicated above.

```r

library(dplyr)
library(arrow)
library(readr)
library(here)
library(tools)

path <- here("data")

# open references to all parquet files in the folder
p <- list.files(path, full.names = TRUE, recursive = FALSE, pattern = "*.parquet") |>
     #set list element names, remove extension, lowercase, remove path
     purrr::set_names(~ file_path_sans_ext(tolower(basename(.)))) |>
     purrr::map(arrow::open_dataset)

# more longwinded way of doing on indiv files
# concept               <- arrow::open_dataset(here(datafolder,"concept.parquet"))
# concept_relationship  <- arrow::open_dataset(here(datafolder,"concept_relationship.parquet"))
# drug_strength         <- arrow::open_dataset(here(datafolder,"drug_strength.parquet"))

freq_concepts_by_vocab      <- p$concept |> 
    count(vocabulary_id, sort=TRUE) |> 
    collect()
    
freq_concept_relationships_by_vocab <- p$concept_relationship |> 
    left_join(p$concept, join_by(concept_id_1==concept_id)) |> 
    count(vocabulary_id, sort=TRUE) |> 
    collect()

readr::write_csv(freq_concepts_by_vocab,"summaries/freq_concepts_by_vocab.csv")
readr::write_csv(freq_concept_relationships_by_vocab,"summaries/freq_concept_relationships_by_vocab.csv")

# create simple summary file just recording num rows in each vocab file
# can potentially be used to compare versions of vocabs
dfsum <- tibble( vocabulary_version =     p$vocabulary |> filter(vocabulary_id=='None') |> pull(vocabulary_version,as_vector=TRUE),
                 nconcept =               p$concept |> nrow(),
                 nconcept_relationship =  p$concept_relationship |> nrow(),
                 ndrug_strength =         p$drug_strength |> nrow())
                 
readr::write_csv(dfsum,"summaries/nrows_per_vocab_file.csv")                 

```

## Local development

If you haven't already set up `git lfs` with your git user account:

1. Download and install `git lfs` using [their instructions](https://git-lfs.com/)
2. Set up git LFS with your git account
    ```shell
    git lfs install
    ```

Clone this repository:

```shell
git clone https://github.com/SAFEHR-data/omop-vocabs-processed.git
```

## Release procedure

1. Clone this repository and create a new branch
1. Download vocabulary csv files from Athena & pre-process to parquet files as [detailed in the UCLH omop_es private repository](https://github.com/uclh-criu/omop_es/blob/master/omop_metadata/omop_vocabs_readme.md)
1. Copy new parquet files to the data folder 
1. Update the [data/version.txt](data/version.txt) file with this version. 
   For backwards compatibility, also copy this to `data/metadata_version.txt`, we will eventually not maintain this file.
1. Tag the release, replacing `${version}` with your version, e.g. `v5`
    ```shell
    git tag ${version}
    ```
1. Push the tag for a release
    ```shell
    git push --tags origin
    ```
1. Submit pull request

