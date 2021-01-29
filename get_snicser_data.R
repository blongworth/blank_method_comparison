# Get data for DIC LBC project

library(amstools)
library(tidyverse)
library(here)
library(odbc)
library(glue)
library(readxl)

# skip CFAMS020620, something weird with fm_corr, even though all params seem right

wheels <- c("CFAMS021120", "CFAMS021820", "CFAMS022620", "CFAMS031020", "CFAMS060420", "USAMS030520") 

## Get contents of snics_results and snics_results_test for all test wheels

#### Pull and save all data for wheels
whdata <- getWheel(wheels) %>%
  mutate(table = "snics_results")
whdatat <- getWheel(wheels, test = TRUE) %>%
  mutate(table = "snics_results_test")
whdata <- rbind(whdata, whdatat)
write_csv(whdata, here("data/MBC_compare_snics_results.csv"))

#### Get subset of data for analysis

# Function to pull subset of data needed for blank corr
getBCWheel <- function(wheels, test = FALSE) {
  con <- conNOSAMS()
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

# add R and MR calculations
data <- data %>% 
  mutate(fm_mb_corr_r = doMBC(fm_corr, fm_cont, 
                                 mass, mass_cont), 
         sig_fm_mb_corr_r = doMBCerr(fm_corr, fm_cont, 
                               mass, mass_cont, 
                               sig_fm_corr, fm_cont_err, 
                               sig_mass, mass_cont_err)) 

mrdata <- read_excel(here("data/CFAMS03102 MBC Test Results.xlsx"), skip = 3, col_names = FALSE) %>%
  .[c(1, 2, 25, 26)] %>%
  rename(wheel = "...1",
         wheel_pos = "...2",
         fm_mb_corr_mr = "...25",
         sig_fm_mb_corr_mr= "...26")

mrdata0604 <- read_excel(here("data/CFAMS060420MRResults.xlsx"), skip = 6, col_names = FALSE) %>%
  .[c(1, 3, 27, 28)] %>%
  rename(wheel = "...1",
         wheel_pos = "...3",
         fm_mb_corr_mr = "...27",
         sig_fm_mb_corr_mr= "...28")

mrdata <- rbind(mrdata, mrdata0604)
data <- data %>% 
  left_join(mrdata)

# Add consensus data

# get consensus values
cons <- getStdTable() %>%
  select(rec_num, fm_consensus)

# merge with data by tp. 
data <- data %>% 
  left_join(cons, by = "rec_num") %>%
  mutate(Fm_reported = ifelse(is.na(fm_mb_corr), fm_corr, fm_mb_corr),
         sig_Fm_reported = ifelse(is.na(sig_fm_mb_corr), sig_fm_corr, sig_fm_mb_corr),
         normFm = normFm(Fm_reported, fm_consensus),
         sigma = sigma(Fm_reported, fm_consensus, sig_Fm_reported))

# Write to a file
write_csv(data, here("data/SNICSer_blank_compare.csv"))
