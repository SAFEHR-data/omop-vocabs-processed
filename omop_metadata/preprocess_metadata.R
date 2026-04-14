# *** This is NOT intended to be run or called by most users ***
# Users would normally download and use the resulting files.

library(dplyr)

#' This function reads in vocabulary files downloaded from Athena, preprocess them
#' and writes them out as binary files for better performance.
#' This is only likely to be called occasionally (~6 months).
#' also all of this could be moved to an omop_vocabs folder because it is
#' not metadata in the sense that OHDSI use the term https://ohdsi.github.io/CommonDataModel/cdm54.html#metadata
#'
#' The resulting files should be uploaded to an accessible internet location
preprocess_omop_metadata <- function(athena_source_directory) {
  stopifnot(file.exists(athena_source_directory))

  convert_valid_dates <- function(df) {
    df |>
      mutate(
        valid_start_date = lubridate::ymd(valid_start_date),
        valid_end_date   = lubridate::ymd(valid_end_date)
      )
  }

  read_athena_data <- function(file, col_types) {
    # na = "" is needed to stop one concept_name being converted from "NA" to NA
    readr::read_tsv(here::here(athena_source_directory, file), col_types = col_types, na = "", quote = "")
  }

  write_result <- function(data, file) {
    vocab_dir <- glue::glue(here::here("data"))
    if (!dir.exists(vocab_dir)) fs::dir_create(vocab_dir)
    output_file <- glue::glue(vocab_dir, "\\", file)
    arrow::write_parquet(data, output_file)
  }

  concepts <- read_athena_data("CONCEPT.csv", col_types = "icccccciic") |>
    convert_valid_dates() |>
    # beware this filtering out of some vocabs
    # deselecting in Athena download could fix all except OSM that is included by default
    filter(!(vocabulary_id %in% c("NDC", "SPL", "OSM", "ICD10PCS", "ICD10CM", "ICD9CM"))) |>
    write_result("concept.parquet")

  read_athena_data("CONCEPT_RELATIONSHIP.csv", col_types = "iiciic") |>
    # semi_joins to exclude concepts not in concept.csv, e.g. vocabs filtered above
    semi_join(concepts, by = c("concept_id_1" = "concept_id")) |>
    semi_join(concepts, by = c("concept_id_2" = "concept_id")) |>
    convert_valid_dates() |>
    write_result("concept_relationship.parquet")

  read_athena_data("CONCEPT_ANCESTOR.csv", col_types = "iiiicc") |>
    semi_join(concepts, by = c("ancestor_concept_id" = "concept_id")) |>
    semi_join(concepts, by = c("descendant_concept_id" = "concept_id")) |>
    write_result("concept_ancestor.parquet")

  read_athena_data("DRUG_STRENGTH.csv", col_types = "iininininiic") |>
    semi_join(concepts, by = c("drug_concept_id" = "concept_id")) |>
    convert_valid_dates() |>
    write_result("drug_strength.parquet")

  read_athena_data("VOCABULARY.csv", col_types = "cccci") |>
    write_result("vocabulary.parquet")

  # following vocab files not currently used by omop_es
  # but are stored in omop-vocabs-processed for other uses (Baptiste)
  read_athena_data("RELATIONSHIP.csv", col_types = "ccccci") |>
    write_result("relationship.parquet")
  read_athena_data("CONCEPT_SYNONYM.csv", col_types = "ici") |>
    write_result("concept_synonym.parquet")
  read_athena_data("CONCEPT_CLASS.csv", col_types = "cci") |>
    write_result("concept_class.parquet")
  read_athena_data("DOMAIN.csv", col_types = "cci") |>
    write_result("domain.parquet")
}
