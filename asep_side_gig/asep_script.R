library(readxl)
library(dplyr)
library(jsonlite)
library(purrr)
library(stringr)

# Load PE data
folder_path_pe <- "C:/Users/grigoris.kalampoukas/Downloads/ΠΙΝΑΚΕΣ ΒΑΘΜ_ΠΕ ΑΝΑ ΚΛΑΔΟ_ΕΙΔΙΚΟΤΗΤΑ"
files_pe <- list.files(path = folder_path_pe, pattern = "\\.xlsx$", full.names = TRUE)
file_names_pe <- basename(files_pe) %>% tools::file_path_sans_ext()
pe_codes <- paste0("pe_", str_extract(file_names_pe, "^\\d{3}"))
pe_map <- setNames(file_names_pe, pe_codes)

pe_list <- files_pe %>%
  set_names(pe_codes) %>%
  map(~ read_excel(.x) %>%
        slice(-(1:5)) %>%
        set_names(c("aa", "surname", "name", "fathers_name", "social_security", "total_grade")) %>%
        select(aa, total_grade) %>%
        mutate(across(everything(), as.numeric))
  ) %>%
  imap(~ .x %>%
         mutate(category = factor(.y))
  )
asep_pe <- bind_rows(pe_list)

# Load TE data
folder_path_te <- "C:/Users/grigoris.kalampoukas/Downloads/ΠΙΝΑΚΕΣ ΒΑΘΜ_ΤΕ ΑΝΑ ΚΛΑΔΟ_ΕΙΔΙΚΟΤΗΤΑ"
files_te <- list.files(path = folder_path_te, pattern = "\\.xlsx$", full.names = TRUE)
file_names_te <- basename(files_te) %>% tools::file_path_sans_ext()
te_codes <- paste0("te_", str_extract(file_names_te, "^\\d{3}"))
te_map <- setNames(file_names_te, te_codes)

te_list <- files_te %>%
  set_names(te_codes) %>%
  map(~ read_excel(.x) %>%
        slice(-(1:5)) %>%
        set_names(c("aa", "surname", "name", "fathers_name", "social_security", "total_grade")) %>%
        select(aa, total_grade) %>%
        mutate(across(everything(), as.numeric))
  ) %>%
  imap(~ .x %>%
         mutate(category = factor(.y))
  )
asep_te <- bind_rows(te_list)

# Bind ASEP data frames
asep <- bind_rows(asep_pe, asep_te) %>%
  rename(total_score = total_grade)

# Combine and convert map named vectors to data frame (code + label)
combined_map <- tibble(
  code = c(names(pe_map), names(te_map)),
  label = c(as.character(pe_map), as.character(te_map))
)

# Write JSON files
json_path_asep <- "asep.json"
write_json(asep, path = json_path_asep, pretty = TRUE, auto_unbox = TRUE)

json_path_map <- "combined_map.json"
write_json(combined_map_df, path = json_path_map, pretty = TRUE, auto_unbox = TRUE)

target_path <- "C:/Users/grigoris.kalampoukas/MScThesis/asep_side_gig/_site"

# Write JSON files directly to target path
write_json(asep, file.path(target_path, "asep.json"), pretty = TRUE, auto_unbox = TRUE)
write_json(combined_map, file.path(target_path, "combined_map.json"), pretty = TRUE, auto_unbox = TRUE)













