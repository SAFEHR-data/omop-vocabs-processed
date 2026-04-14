library(dplyr)
library(arrow)
library(readr)
library(here)
library(tools)

data_path <- here("data")

# open references to all parquet files in the folder
p <- list.files(data_path, full.names = TRUE, recursive = FALSE, pattern = "*.parquet") |>
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
                 nconcept_ancestor =      p$concept_ancestor |> nrow(),
                 nconcept_relationship =  p$concept_relationship |> nrow(),
                 ndrug_strength =         p$drug_strength |> nrow(),
                 nvocabulary =            p$vocabulary |> nrow(),
                 nconcept_class =         p$concept_class |> nrow(),                                   nconcept_synonym =       p$concept_synonym |> nrow(),
                 ndomain =                p$domain |> nrow(),
                 nrelationship =          p$relationship |> nrow()
)

readr::write_csv(dfsum,"summaries/nrows_per_vocab_file.csv")
