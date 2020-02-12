R project for looking at the impact of changes to the blank correction methods.

Looking at:

1. Mass balance correction for all samples
2. Large blank average from wheel instead of long-term average for small samples
3. Total_mass instead of target_mass
4. Subtracting mass of blank from total or target mass to get mass of unknown
5. New vs old parameters for mass balance correction

Use data from snics_results, which has norm_fm as the uncorrected Fm, and all
parameters necessary for blank correction.

Use blank correction functions from SNICSer in amstools.
