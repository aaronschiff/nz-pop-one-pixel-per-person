# Process raw data from nz.stat

# -----------------------------------------------------------------------------
# Setup
rm(list = ls())
library(readr)
library(tidyr)
library(dplyr)
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# Read data and basic cleaning
dat = read_csv("TABLECODE8028_Data_59bc480a-7885-457f-a901-4f48d202596a.csv")
names(dat) = tolower(names(dat))
dat = dat %>%
  rename(ethnicity = `ethnic groups (detailed)`, 
         age_group = `age group`)
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# Filter data
dat_cleaned = dat %>%
  filter(value > 0, 
         area != "Total, Regional Council Areas") %>%
  select(-flags)
# -----------------------------------------------------------------------------


# ----------------------------------------------------------------------------
# Clean up ethnicities

# Remove "only" from the single ethnicity ones
replaceEthnicity = function(d, old_e, new_e) {
  d[d$ethnicity == old_e, "ethnicity"] = new_e
  return(d)
}
dat_cleaned = replaceEthnicity(dat_cleaned, "European Only", "European")
dat_cleaned = replaceEthnicity(dat_cleaned, "Maori Only", "Maori")
dat_cleaned = replaceEthnicity(dat_cleaned, "Pacific Peoples Only", "Pacific Peoples")
dat_cleaned = replaceEthnicity(dat_cleaned, "Asian Only", "Asian")
dat_cleaned = replaceEthnicity(dat_cleaned, "Middle Eastern/Latin American/African Only", "MELAA")
dat_cleaned = replaceEthnicity(dat_cleaned, "Other Ethnicity Only", "Other")

# Change all instances of Middle Eastern/Latin American/African to MELAA
dat_cleaned$ethnicity = gsub("Middle Eastern/Latin American/African", "MELAA", dat_cleaned$ethnicity)
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# Clean up regions, age groups and sex
dat_cleaned$area = gsub(" Region", "", dat_cleaned$area)
dat_cleaned$age_group = gsub(" Years", "", dat_cleaned$age_group)
dat_cleaned$sex = gsub("Male", "M", dat_cleaned$sex)
dat_cleaned$sex = gsub("Female", "F", dat_cleaned$sex)
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# Write results
write_csv(dat_cleaned, "nz-pop-cleaned.csv")

region_order = tibble(region = c("Northland",
                                 "Auckland", 
                                 "Waikato", 
                                 "Bay of Plenty", 
                                 "Gisborne", 
                                 "Hawke's Bay", 
                                 "Taranaki", 
                                 "Manawatu-Wanganui", 
                                 "Wellington", 
                                 "Tasman", 
                                 "Nelson", 
                                 "Marlborough", 
                                 "West Coast", 
                                 "Canterbury", 
                                 "Otago", 
                                 "Southland", 
                                 "Area Outside"), 
                      region_short_name = c("NTL", 
                                            "AUK", 
                                            "WKI", 
                                            "BOP", 
                                            "GIS", 
                                            "HKB", 
                                            "TKI", 
                                            "MWT", 
                                            "WGN", 
                                            "TAS", 
                                            "NSN", 
                                            "MHB", 
                                            "WTC", 
                                            "CAN", 
                                            "OTA", 
                                            "STL", 
                                            "OUT"))

# Pop by ethnicity by region, ordered as above
dat_cleaned %>%
  rename(region = area) %>% 
  group_by(region, ethnicity) %>%
  summarise(pop = sum(value)) %>%
  right_join(region_order) %>% 
  write_csv("nz-pop-by-region-ethnicity.csv") %>%
  ungroup()


# -----------------------------------------------------------------------------
