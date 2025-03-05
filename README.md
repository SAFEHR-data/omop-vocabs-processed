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

1. Update the vocabulary
2. Update the [data/version.txt](data/version.txt) file with this version. 
   For backwards compatibility, also copy this to `data/metadata_version.txt`, we will eventually not maintain this file.
3. Tag the release, replacing `${version}` with your version, e.g. `v5`
    ```shell
    git tag ${version}
    ```
4. Push the tag for a release
    ```shell
    git push --tags origin
    ```

