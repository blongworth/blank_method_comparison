# Get data for DIC LBC project

library(amstools)
library(tidyverse)
library(here)
library(blanks)

con <- conNOSAMS()
standards <- getStdTable()

wstd <- getNorm(from = as.Date("2019-01-01"), 
                recs = c(1082, 17185, 83028, 159579)) %>%
  mutate(process = purrr::map_chr(tp_num, amstools::getProcess, con),
         system = substr(wheel, 1, 5)) %>%
  filter(process == "WS") %>%
  left_join(select(standards, rec_num, fm_consensus))

write_csv(wstd, here("data/wstd.csv"))
write_csv(standards, here("data/standards.csv"))
