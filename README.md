R project for looking at the impact of changes to the blank correction methods.

There are several related projects here. DIC_Blanks* looks at the effect of
using a DIC-based large blank correction on the quality of water secondaries.
blank_method_comparison* looks at the effect of manually applying the new blank
corrections below. SNICSer_compare* compares production wheels with the same
wheels analysed by a new version of SNICSer in a test environment. There are
ancillary scripts to pull the relevant data.

Looking at:

1. Mass balance correction for all samples
2. Large blank average from wheel instead of long-term average for small samples
3. Total_mass instead of target_mass
4. Subtracting mass of blank from total or target mass to get mass of unknown
5. New vs old parameters for mass balance correction

Use data from snics_results, which has norm_fm as the uncorrected Fm, and all
parameters necessary for blank correction.

Use blank correction functions from SNICSer in amstools.
