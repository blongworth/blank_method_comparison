# Get data for DIC LBC project

library(amstools)
library(tidyverse)
library(here)
library(odbc)
library(glue)

wheels <- c("CFAMS020620", "CFAMS021120", "CFAMS021320", 
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
con <- conNOSAMS()

# Function to pull subset of data
getBCWheel <- function(table, wheels) {
  query <- glue_sql("SELECT wheel, wheel_pos, target.tp_num, rec_num,
                       ss, sample_name, norm_method, sample_type, total_umols_co2,
                       norm_ratio, fm_corr, sig_fm_corr, lg_blk_fm, sig_lg_blk_fm,
                       fm_mb_corr, sig_fm_mb_corr 
                     FROM {`table`}
                     JOIN target ON {`table`}.tp_num = target.tp_num
                     JOIN dc13_test ON {`table`}.tp_num = dc13_test.tp_num
                     WHERE wheel in ({wheels*})",
                    table = table,
                    wheels = wheels,
                    .con = con)
  dbGetQuery(con, query) %>%
    mutate(table = table,
           process = map_chr(tp_num, getProcess, con))
}

# Get the data
data <- map_dfr(c("snics_results", "snics_results_test"), getBCWheel, wheels)

# Write to a file
write_csv(data, here("data/SNICSer_blank_compare.csv"))
