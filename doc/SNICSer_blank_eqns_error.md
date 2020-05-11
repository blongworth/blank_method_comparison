% Blank corrections in SNICSer
% Brett Longworth
% March 7, 2019

Snicser performs blank corrections for all samples routinely processed at
NOSAMS. Two different corrections are performed, a large blank correction
for all samples and a mass balance correction for samples under 100 ug and
all DOC samples.

# Large Blank

The large blank correction subtracts a single blank value from all samples
proportional to their fraction modern. It assumes that samples with Fm of
the large blank should be corrected to 0 and that samples with Fm the same
as the OX-I standard need no correction since they are normalized to
a standard that (presumably contains the same blank.

For large samples the value of FmB is determined by averaging the blanks on the
wheel. For small samples, the value is taken from a historical average. We
typically use three types of large blanks: acetanalide, C-1 or TIRI-F, and
a watson blank. The acetanalide blank is used to correct organic samples and
DOC, the C-1 or TIRI-F to correct HY, WS, and GS process types, and the Watson
blank to correct Watson samples. 

SNICSer will include all samples marked B in the blank table, so alternative
samples may be used for LBC. Checked samples are used for the correction, and
samples flagged "B" larger than 150ug and with a DB consensus value < 0.002
will be checked by default.

The large blank correction is performed for all samples. When applying
a mass balance correction, the large-blank-corrected value is used for the
measured fraction modern in the mass-balance equation.

The correction uses this equation:

$$ R_s = R_m - \frac{R_b(R_{ox}-R_m)}{R_{ox}} $$

Where $R_s$ is the ratio of the unknown sample, $R_m$ is the measured ratio, $R_b$ is the ratio of the blank, and $R_{ox}$ is the ratio of the normalizing standard.

and this snicser function:

```
LargeBlankCorrected = Fm - FmB * (FmS - Fm) / FmS
```

Where Fm is the measured Fm, FmB is the Fm of the blank, and FmS is the Fm of the normalizing standard.

Error propagation for the large blank uses this equation:

$$ \sigma_{R_s}^2=\left[\sigma_{R_m}\left(1+\frac{R_b}{R_{ox}}\right)\right]^2 + \left[\sigma_{R_b}\frac{R_m - R_{ox}}{R_{ox}}\right]^2$$

And this function:

```
SigLargeBlankCorrected = SigFm ^ 2 * (1 + FmB / FmS) ^ 2 + 
	SigFmB ^ 2 * ((Fm - FmS) / FmS) ^ 2

If SigLargeBlankCorrected > 0 
	Then SigLargeBlankCorrected = SigLargeBlankCorrected ^ 0.5
```

# Mass Balance Correction

The blank correction for small samples and DOC assumes that there is
a contaminant with constant mass and fraction modern added to the samples
during processing. It is assumed that this contaminant is a component of
the measured sample and that the fm of the sample can be determined using
a mass balance mixing model. 

The mass and fraction modern of the contaminant are determined by running
modern and dead samples of varying sizes and fitting a mass balance curve.
These values are assumed to be stable over time and are checked and
adjusted as necessary. The contaminant and sample parameters are retrieved
from the dc13 table in the NOSAMS DB and are stored per-sample. The
graphite mass (graphite_umols_co2) is used for small samples, and the
total mass (total_umols_co2) is used for DOC samples. 

The correction is done using this equation:

$$ R_s = R_m + \frac{m_c(R_m - R_c)}{m_m} $$

Where $R_s$ is the ratio of the unknown sample, $m_c$ is the mass of the contaminant, $R_m$ is the measured ratio, $R_c$ is the ratio of the contaminant, and $m_m$ is the mass of the measured sample.

and this snicser function:

```
FmMassBal = FmC + (FmC - FmB) * MassB / Mass
```

Where FmC is LBC corrected Fm, FmB is the Fm of the blank/contaminant, MassB is the mass of the blank/contaminant. and Mass is the mass of the measured sample.

Error propagation is done with the following equation:

$$ \sigma_{R_s}^2 = \left[\sigma_{R_m}\frac{1+m_c}{m_m}\right]^2 + \left[\sigma_{m_m}\frac{m_c(R_m-R_c)}{m_m^2}\right]^2 + \left[\sigma_{R_c}\frac{m_c}{m_m}\right]^2 + \left[\sigma_{m_c}\frac{R_m - R_c}{m_m}\right]^2$$

And this snicser function:

```
If M <= Mb Then Return 42 ' flag anomalous situation

SigFmMassBal = SigFmC ^ 2 * (1 + Mb / M) ^ 2 + 
SigMass ^ 2 * ((FmC - FmB) * Mb / M ^ 2) ^ 2 + 
SigFmB ^ 2 * (Mb / M) ^ 2 + 
SigMassB ^ 2 * ((FmC - FmB) / M) ^ 2 

If SigFmMassBal > 0 Then SigFmMassBal = SigFmMassBal ^ 0.5
```

