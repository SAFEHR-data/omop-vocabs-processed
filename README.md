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

# get reference to the data
concept       <- arrow::open_dataset("concept.parquet")
relationship  <- arrow::open_dataset("concept_relationship.parquet")

freq_concepts_by_vocab      <- concept |> 
    count(vocabulary_id, sort=TRUE) |> 
    collect()
    
freq_relationships_by_vocab <- relationship |> 
    left_join(concept, join_by(concept_id_1==concept_id)) |> 
    count(vocabulary_id, sort=TRUE) |> 
    collect()

readr::write_csv(freq_concepts_by_vocab,"summaries/freq_concepts_by_vocab.csv")
readr::write_csv(freq_relationships_by_vocab,"summaries/freq_relationships_by_vocab.csv")

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

