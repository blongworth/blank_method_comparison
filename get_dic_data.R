# Get data for DIC LBC project

library(amstools)
library(tidyverse)
library(here)
library(blanks)

con <- conNOSAMS()
standards <- getStdTable()

getWS <- function(recnum) {
  db <- conNOSAMS()
  query <- glue::glue_sql("SELECT wheel, wheel_pos, sample_name,
                             tp_date_pressed, target.tp_num, target.rec_num,
                             target.osg_num, gf_devel, gf_test, ws_r_d,
                             ws_method_num, ws_line_num, ws_strip_date,
                             ws_comments, ws_comment_code,
                             norm_ratio, int_err, ext_err, fm_corr, 
                             sig_fm_corr, dc13, total_umols_co2, sig_tot_umols
                          FROM snics_results
                          JOIN target ON snics_results.tp_num = target.tp_num
                          JOIN graphite ON target.osg_num = graphite.osg_num
                          JOIN dc13 ON snics_results.tp_num = dc13.tp_num
                          LEFT JOIN water_strip ON graphite.ws_num = water_strip.ws_num
                          WHERE target.rec_num IN ({recnums*})",
                          recnums = recnum,
                          .con = db
  )
  
  recs <- odbc::dbSendQuery(db, query)
  data <- odbc::dbFetch(recs)
  odbc::dbClearResult(recs)
  data
}

wstd <- getWS(c(1082, 17185, 83028, 159579)) %>%
  mutate(process = purrr::map_chr(tp_num, amstools::getProcess, con),
         system = substr(wheel, 1, 5)) %>%
  filter(process == "WS") %>%
  left_join(select(standards, rec_num, fm_consensus))

write_csv(wstd, here("data/wstd.csv"))
write_csv(standards, here("data/standards.csv"))