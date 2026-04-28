# --------------------------------------------
# Convert to CSV from .dat
# Counties: Miami-Dade, Broward, Palm Beach
# Students: Undergraduate & Graduate only
# --------------------------------------------

library(ipumsr)
library(dplyr)

# --------------------------------------------
# IPUMS DATA
# --------------------------------------------

ddi <- read_ipums_ddi("usa_00002.xml")
dat_file <- file.choose()
df <- read_ipums_micro(ddi, data_file = dat_file)

colSums(is.na(df))
# --------------------------------------------
# Filtering
# --------------------------------------------
df_filtered <- df %>%
  mutate(
    # Convert to numeric
    rent = as.numeric(as.character(US2024A_RNTP)),
    puma = as.numeric(as.character(US2024A_PUMA)),
    age = as.numeric(as.character(AGE)),
    school = as.numeric(as.character(SCHOOL)),
    grade_level = as.character(US2024A_SCHG)  # Kept as character for filtering
  ) %>%
  filter(
    STATEFIP == 12,                    # Florida
    age >= 18 & age <= 30,             # College age
    school >= 2,                       # Enrolled
    grade_level %in% c("15", "16"),    # 15=Undergrad, 16=Graduate 
    rent > 0,                          # Has rent
    rent < 9999,                       # Exclude missing
    # South Florida PUMAs:
    # Miami-Dade: 0-1200, 8600-8900
    # Broward: 1300-1800, 6100-6400
    # Palm Beach: 1900-2600, 5700-6000
    (puma >= 0 & puma <= 2600) | 
      (puma >= 5700 & puma <= 6400) |
      (puma >= 8600 & puma <= 8900)
  )
# --------------------------------------------
# Counties
# --------------------------------------------
df_with_county <- df_filtered %>%
  mutate(
    county = case_when(
      # Miami-Dade PUMAs
      (puma >= 0 & puma <= 1200) | (puma >= 8600 & puma <= 8900) ~ "Miami-Dade",
      # Broward PUMAs  
      (puma >= 1300 & puma <= 1800) | (puma >= 6100 & puma <= 6400) ~ "Broward",
      # Palm Beach PUMAs
      (puma >= 1900 & puma <= 2600) | (puma >= 5700 & puma <= 6000) ~ "Palm Beach",
      TRUE ~ "Unknown"
    )
  )

# --------------------------------------------
# Adding Location Names
# --------------------------------------------
# Miami-Dade location mapping
puma_mapping <- data.frame(
  puma = c(
    101, 102, 103, 902, 903, 904, 1102, 1103, 1104, 1105, 1106, 1107, 1108, 1109, 1110, 1111,
    7302, 7105, 8601, 8602, 8603, 8605, 8606, 8607, 8608, 8610, 8611, 8613, 8614, 8615,
    8616, 8617, 8618, 8619, 8620, 8621, 8622, 8623, 8625
  ),
  location_name = c(
    "North Miami Beach & Aventura", "North Miami", "Miami Gardens", "Miami Shores",
    "Little Haiti", "Allapattah", "Miami Beach", "Coconut Grove", "Little Havana",
    "West Miami", "Doral", "Kendall West", "Kendall Lakes", "Kendall East", "Westchester",
    "South Miami & Pinecrest", "Coral Gables Area", "South Miami", "West Kendall",
    "Coral Gables East (NEAR UM!)", "Coral Gables East (NEAR UM!)",
    "Coral Gables West (NEAR UM!)", "South Miami Heights", "Kendall Sunset",
    "Kendall West", "Coral Gables Central (UM CAMPUS!)", "Olympia Heights",
    "Pinecrest", "Kendall Dadeland", "Kendall Hammocks", "Kendall Central",
    "Southwest Miami-Dade", "Kendall South", "Homestead", "Cutler Bay",
    "Palmetto Bay", "Cutler Bay South", "South Dade",
    "Coral Gables North (NEAR UM!)"
  ),
  um_distance = c(
    "Far", "Far", "Far", "Far", "Far", "Far", "Far", "Very Close", "Moderate", "Moderate",
    "Moderate", "Moderate", "Moderate", "Moderate", "Close", "Very Close", "Close", "Close",
    "Moderate", "VERY CLOSE", "VERY CLOSE", "VERY CLOSE", "Close", "Moderate", "Moderate",
    "VERY CLOSE", "Close", "Close", "Moderate", "Moderate", "Moderate", "Far", "Moderate",
    "Far", "Far", "Close", "Far", "Far", "VERY CLOSE"
  )
)

# Add locations (only for Miami-Dade)
df_final <- df_with_county %>%
  left_join(puma_mapping, by = "puma") %>%
  mutate(
    location_name = case_when(
      county == "Miami-Dade" & !is.na(location_name) ~ location_name,
      county == "Miami-Dade" ~ paste0("Miami-Dade PUMA ", puma),
      county == "Broward" ~ paste0("Broward PUMA ", puma),
      county == "Palm Beach" ~ paste0("Palm Beach PUMA ", puma),
      TRUE ~ paste0("PUMA ", puma)
    ),
    um_distance = ifelse(is.na(um_distance), "N/A", um_distance)
  )

# --------------------------------------------
# Removing unused columns
# --------------------------------------------
df_clean <- df_final %>%
  select(
    # identifiers
    SERIAL,NUMPREC, 
    # geography
     puma, county, location_name, um_distance,
    # housing info 
    GQ, VEHICLES, rent,
    # characteristics  
     age, grade_level,
    # Removed: US2024A_ELEP, US2024A_GASP, US2024A_RNTP, US2024A_WATP, HHWT, PERWT,YEAR, SAMPLE,  CBSERIAL, CLUSTER,STATEFIP, CITY, US2024A_PUMA,PERNUM,SCHOOL, school,QSCHOOL, US2024A_SCHG
  )

# --------------------------------------------
# CSV
# --------------------------------------------

write.csv(df_clean,
          "~/UM/Spring 2026/Housing - Group Project/south-florida-housing-data.csv",
          row.names = FALSE)

