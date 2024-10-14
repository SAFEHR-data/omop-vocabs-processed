# OMOP Metadata

Repository for metadata for working with the [OMOP CDM](https://ohdsi.github.io/CommonDataModel/) at UCLH.

You can download these files directly or follow the local development instructions to use git to clone the files

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
