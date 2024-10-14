# OMOP Metadata

Repository for metadata for working with the [OMOP CDM](https://ohdsi.github.io/CommonDataModel/) at UCLH.

You can download these files directly or follow the local development instructions to use git to clone the files

## Downloading versions

You can download a specific tagged version using https.
in this format, replacing the curly braced values:

`https://github.com/SAFEHR-data/omop-metadata/raw/refs/tags/{tag}/{relative_path}`

For example for `v4` data file for the `data/metadata_version.txt`:

```r
tag = "v4"
relative_path = "data/metadata_version.txt"
download_url = glue::glue("https://github.com/SAFEHR-data/omop-metadata/raw/refs/tags/{tag}/{relative_path}")
download.file(download_url,
              destfile = "metadata_version.txt",
              mode = "w")
```

```python
import urllib.request

tag = "v4"
relative_path = "data/metadata_version.txt"
download_url = f"https://github.com/SAFEHR-data/omop-metadata/raw/refs/tags/{tag}/{relative_path}"
local_filename = "metadata_version.txt"

urllib.request.urlretrieve(download_url, local_filename)
```

```shell
export OMOP_METADATA_VERSION=v4
export OMOP_METADATA_PATH=data/metadata_version.txt
curl -L -o metadata_version.txt "https://github.com/SAFEHR-data/omop-metadata/raw/refs/tags/${OMOP_METADATA_VERSION}/${OMOP_METADATA_PATH}"
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
git clone https://github.com/SAFEHR-data/omop-metadata.git
```

## Release procedure

1. Update the vocabulary
2. Update the [data/metadata_version.txt](data/metadata_version.txt) file with this version
3. Tag the release, replacing `${version}` with your version, e.g. `v4`
    ```shell
    git tag ${version}
    ```
4. Push the tag for a release
    ```shell
    git push --tags origin
    ```

