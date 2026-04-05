library(tidyverse)

metadata <- fromJSON(here::here("data/raw/metadata.repository.2026-04-01.json"), flatten = TRUE)
  
metadata|>  
  unnest(cols =c(associated_entities))-> metadata

metadata|>
  unnest(cols =c(annotations), names_sep = "_") ->metadata_annotations# 26 samples have extra annotation information

xml_files <-  paste0("data/raw/cliFiles/",metadata$file_id,"/", metadata$file_name)

#for extracting values from xml entries
safe_extract_all_all <- function(doc, xpath, ns, collapse = "; ") {
  nodes <- xml_find_all(doc, xpath, ns)
  
  if (length(nodes) == 0) return(NA)
  
  values <- xml_text(nodes)
  values <- values[values != ""]  # remove empty strings
  
  if (length(values) == 0) return(NA)
  
  paste(str_to_title(values), collapse = collapse)#collapse multiple values
}

parse_tcga_xml <- function(file) {
  doc <- read_xml(file)
  
  ns <- xml_ns(doc)  # automatically grabs all namespaces
  
  tibble(
    sample_id = tools::file_path_sans_ext(basename(file)),
    
    patient_barcode = safe_extract_all(doc, ".//shared:bcr_patient_barcode", ns),
    patient_uuid = safe_extract_all(doc, ".//shared:bcr_patient_uuid", ns),
    
    gender = safe_extract_all(doc, ".//shared:gender", ns),
    age = safe_extract_all(doc, ".//clin_shared:age_at_initial_pathologic_diagnosis", ns),
    
    tumor_site = safe_extract_all(doc, ".//clin_shared:tumor_tissue_site", ns),
    histology = safe_extract_all(doc, ".//shared:histological_type", ns),
    
    tumor_stage = safe_extract_all(doc, ".//shared_stage:pathologic_stage", ns),
    t_stage = safe_extract_all(doc, ".//shared_stage:pathologic_T", ns),
    n_stage = safe_extract_all(doc, ".//shared_stage:pathologic_N", ns),
    m_stage = safe_extract_all(doc, ".//shared_stage:pathologic_M", ns),
    vital_status = safe_extract_all(doc, ".//clin_shared:vital_status", ns),
    days_to_death = safe_extract_all(doc, ".//clin_shared:days_to_death", ns),
    days_to_last_followup = safe_extract_all(doc, ".//clin_shared:days_to_last_followup", ns),
    history_of_neoadjuvant_treatment = safe_extract_all(doc, ".//shared:history_of_neoadjuvant_treatment", ns),
    tumor_status = safe_extract_all(doc, ".//clin_shared:person_neoplasm_cancer_status", ns),
    surgery_type = safe_extract_all(doc, ".//paad:surgery_performed_type", ns),
    radiation_therapy = safe_extract_all(doc, ".//clin_shared:radiation_therapy", ns),
    postoperative_rx_tx = safe_extract_all(doc, ".//clin_shared:postoperative_rx_tx", ns),
    primary_therapy_outcome_success = safe_extract_all(doc, ".//clin_shared:primary_therapy_outcome_success", ns),
    therapy_type = safe_extract_all(doc, ".//rx:therapy_type", ns),
    therapy_name = safe_extract_all(doc, ".//rx:drug_name", ns),
    measure_of_response = safe_extract_all(doc, ".//clin_shared:measure_of_response", ns))
}

xml_df <- map_dfr(xml_files, parse_tcga_xml)
left_join(metadata, xml_df, by=c("entity_submitter_id" = "patient_barcode"))->xml_df1

write_tsv(xml_df1,here::here("data/processed/parsed_data.tsv"))
write_tsv(xml_df1,here::here("output/tables/parsed_data.tsv"))
