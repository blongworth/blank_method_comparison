# Get data for DIC LBC project

library(amstools)
library(tidyverse)
library(here)
library(odbc)
library(glue)

wheels <- c("CFAMS020620", "CFAMS021120", 
            "CFAMS021820", "CFAMS022620", "CFAMS031020") 

## Get data

#### Pull and save all data for wheels
whdata <- getWheel(wheels) %>%
  mutate(table = "snics_results")
whdatat <- getWheel(wheels, test = TRUE) %>%
  mutate(table = "snics_results_test")
whdata <- rbind(whdata, whdatat)
write_csv(whdata, here("data/results.csv"))

#### Get subset of data

# Function to pull subset of data needed for blank corr
getBCWheel <- function(wheels, test = FALSE) {
  if (test) {
    query <- glue_sql("SELECT wheel, wheel_pos, target.tp_num, rec_num,
                         ss, sample_name, norm_method, sample_type, total_umols_co2,
                         sig_tot_umols, mass_cont, mass_cont_err, fm_cont, fm_cont_err,
                         norm_ratio, fm_corr, sig_fm_corr, lg_blk_fm, sig_lg_blk_fm,
                         fm_mb_corr, sig_fm_mb_corr 
                       FROM snics_results_test
                       JOIN target ON snics_results_test.tp_num = target.tp_num
                       JOIN dc13_test ON snics_results_test.tp_num = dc13_test.tp_num
                       WHERE wheel in ({wheels*})",
                      wheels = wheels,
                      .con = con)
  } else {
    query <- glue_sql("SELECT wheel, wheel_pos, target.tp_num, rec_num,
                         ss, sample_name, norm_method, sample_type, total_umols_co2,
                         sig_tot_umols, mass_cont, mass_cont_err, fm_cont, fm_cont_err,
                         norm_ratio, fm_corr, sig_fm_corr, lg_blk_fm, sig_lg_blk_fm,
                         fm_mb_corr, sig_fm_mb_corr 
                       FROM snics_results
                       JOIN target ON snics_results.tp_num = target.tp_num
                       JOIN dc13 ON snics_results.tp_num = dc13.tp_num
                       WHERE wheel in ({wheels*})",
                      wheels = wheels,
                      .con = con)
  }
  
  con <- conNOSAMS()
  dbGetQuery(con, query) %>%
    mutate(mass = total_umols_co2 * 12.015,
           sig_mass = sig_tot_umols * 12.015,
           process = map_chr(tp_num, getProcess, con))
}

# Get the data
data <- getBCWheel(wheels, test = FALSE) %>%
  mutate(table = "snics_results")
datat <- getBCWheel(wheels, test = TRUE) %>%
  mutate(table = "snics_results_test")
data <- rbind(data, datat)

# Write to a file
write_csv(data, here("data/SNICSer_blank_compare.csv"))
