# Install gfdata main branch
remove.packages("gfdata")
# remotes::install_github("pbs-assess/gfdata")
remotes::install_github("pbs-assess/gfdata", ref = "trials")

# Get survey ssids
ssids <- gfdata::get_ssids() |>
  dplyr::rename_with(tolower)

# What colnames?
colnames(ssids)

# What rows?
jrows <- ssids |> 
  dplyr::filter(stringr::str_detect(survey_series_desc, "jig|Jig"))
jrows
# # A tibble: 6 × 3
# survey_series_id survey_series_desc           survey_abbrev
# <dbl>            <chr>                        <chr>        
# 82               Jig Survey - 4B Stat Area 12 OTHER        
# 83               Jig Survey - 4B Stat Area 13 OTHER        
# 84               Jig Survey - 4B Stat Area 15 OTHER        
# 85               Jig Survey - 4B Stat Area 16 OTHER        
# 86               Jig Survey - 4B Stat Area 18 OTHER        
# 87               Jig Survey - 4B Stat Area 19 OTHER

# What ssids?
jids <- jrows |> dplyr::pull(survey_series_id)
jids
# 82 83 84 85 86 87

# Point 0: Why do many fishing events appear doubled?
# - Suspect some fishing events appear in two survey_series_ids
# - Quick fix: select unique fishing_event_ids
# - Longer fix: why do some jig survey events show twice?


# What questions?
# 1. How many fishing event ids lacked lat/lon? Three.
# 2. How many lingcod age structures were aged? Zero but 177 requested
# 3. How many dogfish?
# 4. How many dogfish length and sex?

# Get species
spc <- gfdata::get_species()
colnames(spc)

# Lingcod
spl <- spc |> 
  dplyr::select(
    species_code,
    species_common_name,
    species_science_name
  ) |>
  dplyr::filter(stringr::str_detect(species_common_name, "lingcod")) |>
  dplyr::filter(species_science_name == "ophiodon elongatus") |>
  dplyr::pull(species_code)
spl # "467"

# Dogfish
spd <- spc |> 
  dplyr::select(
    species_code,
    species_common_name,
    species_science_name
  ) |>
  dplyr::filter(stringr::str_detect(species_common_name, "dogfish"))  |>
  dplyr::filter(species_science_name == "squalus suckleyi") |>
  dplyr::pull(species_code)
spd # "044"

# Question 1: How many fishing event ids lacked lat/lon? Three

# Get survey sets
s2 <- gfdata::get_survey_sets2(species = spl, ssid = jids)

# What columns?
colnames(s2)

# How many rows?
nrow(s2) # 2989

# How many unique fising_event_ids?
length(unique(s2$fishing_event_id)) # 1572

# Use unique fishing event ids (assumes duplicates equivalent for wanted into)
s2u <- s2 |>
  dplyr::distinct(fishing_event_id, .keep_all = TRUE)

# How many rows?
nrow(s2u) # 1572

# How many lacked lat/lon?
length(which(is.na(s2u$latitude) | is.na(s2u$longitude))) # 3

# How many fishing_event_ids lacked lat/lon? 
s2u |>
  dplyr::filter(is.na(latitude) | is.na(longitude)) |>
  dplyr::pull(fishing_event_id) |>
  unique()
# 272124 272125 272126

# Question 2: How many lingcod age structures were aged? 0 but 177 requested

# Get survey samples
sa <- gfdata::get_survey_samples(species = spl, ssid = jids)

# What columns?
colnames(sa)

# How many rows?
nrow(sa) # 750

# How many unique ids?
length(unique(sa$fishing_event_id)) # 385
length(unique(sa$sample_id)) # 385
length(unique(sa$specimen_id)) # 750

# Shows up twice, 6 lingcod in each
tibble::view(s2[which(s2$fishing_event_id == 271731),])
# - ssid: 82, 83

tibble::view(sa[which(sa$fishing_event_id == 271731),])
# - 5 rows
# - ssid: 83



# How many ages?
sum(sa$age_specimen_collected) # 331
length(which(!is.na(sa$age))) # 0 (177 ages requested #100096)

# Compare to SCLDDE? Compare to ageing request?



# Question 3: How many dogfish?

# Get hook data
hd <- gfdata::get_ll_hook_data(species = spd, ssid = jids)

# What columns?
colnames(hd)

# How many rows?
nrow(hd) # 0

# Try survey sets?
ssd <- gfdata::get_survey_sets2(species = spd, ssid = jids)

# What columns?
colnames(ssd)

# How many rows?
nrow(ssd) # 2989

# How many dogfish?
sum(ssd$catch_count) # 1804

# For comparison, how many lingcod?
sum(s2$catch_count) # 1691






tibble::view(s2)



# Get survey samples
ssa <- gfdata::get_survey_samples(species = spl, ssid = jids)


colnames(ssa)



# Get longline hook data
h1 <- gfdata::get_ll_hook_data(species = spl, ssid = jids)

# What colnames?
colnames(h1)





# Get survey sets
s1 <- gfdata::get_survey_sets(species = spl, ssid = jids)








