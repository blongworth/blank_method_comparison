% Mass balance blank correction equations in SNICSer
% Brett Longworth
% May 7, 2020


# Roberts et al.

The MBC equation from Roberts et al. 2019 is:

$$ R_s = \frac{R_m(m_c + m_s) - R_cm_c}{m_s} $$

Where $R_s$ is the ratio of the unknown sample, $m_c$ is the mass of the contaminant, $R_m$ is the measured ratio, $R_c$ is the ratio of the contaminant, and $m_m$ is the mass of the measured sample. 

# SNICSer

The current MBC equation in snicser is:

$$ R_s = R_m + \frac{m_c(R_m - R_c)}{m_m} $$

Same terms as eqn 1 above, with $m_m$ as the mass of the measured sample (blank + unknown). This is an approximation. If $m_s$ is substituted for $m_m$ in the denominator, this eqn is the same as eqn 1.

This is represented in SNICSer as:

```
FmMassBal = FmC + (FmC - FmB) * MassB / Mass
```

Where FmC is LBC corrected Fm, FmB is the Fm of the blank/contaminant, MassB is the mass of the blank/contaminant. and Mass is the mass of the measured sample.

The DOC MBC equation, which uses $m_m - m_c$ as $m_s$ is:

$$ R_s = R_m + \frac{m_c(R_m - R_c)}{m_m - m_c} $$

With the same terms as above. Again, this is the same as eqn 1 above or eqn 2 with $m_s$ substituted.

# Zurich

These are also equvalent to the constant contamination model from ETH:

$$ R_s = \frac{R_m m_m - R_c m_c}{m_m - m_c} $$

# Error propagation

There are error propagations for eqn 1, 2, and 4, but I haven't worked through one for eqn 3.

Error propagation for Roberts et al.:

$$ \sigma_{R_s}^2 = \left[\sigma_{R_m}\frac{m_s+m_c}{m_s}\right]^2 + 
		    \left[\sigma_{R_c}\frac{m_c}{m_s}\right]^2 +
		    \left[\sigma_{m_s}\frac{R_cm_c-R_mm_c}{m_s^2}\right]^2 +
		    \left[\sigma_{m_c}\frac{R_m-R_c}{m_s}\right]^2
$$ 

Error propagation for the current snicser eqn (2) is:

$$ \sigma_{R_s}^2 = \left[\sigma_{R_m}\frac{1+m_c}{m_m}\right]^2 + 
		    \left[\sigma_{R_c}\frac{m_c}{m_m}\right]^2 + 
		    \left[\sigma_{m_m}\frac{m_c(R_m-R_c)}{m_m^2}\right]^2 + 
		    \left[\sigma_{m_c}\frac{R_m - R_c}{m_m}\right]^2$$

Error propagation for the Zurich eqn:

$$ \sigma_{R_s}^2 = \left[\sigma_{R_m}\frac{m_m}{m_m-m_c}\right]^2 +
		    \left[\sigma_{R_c}\frac{-m_c}{m_m-m_c}\right]^2 +
		    \left[\sigma_{m_m}(\frac{R_m}{m_m-m_c}-\frac{R_mm_m - R_cm_c}{(m_m-m_c)^2})\right]^2 +
		    \left[\sigma_{m_c}(\frac{R_mm_m - R_cm_c}{(m_m-m_c)^2}-\frac{R_c}{m_m-m_c})\right]^2
$$ 

# SNICSer with sample mass substitution

Mass balance:

$$ R_s = \frac{R_m m_m - R_c m_c}{m_m - m_c} $$

Error propagation for Roberts et al.:

$$ \sigma_{R_s}^2 = \left[\sigma_{R_m}\frac{m_m}{m_m-m_c}\right]^2 + 
		    \left[\sigma_{R_c}\frac{m_c}{m_m-mc}\right]^2 +
		    \left[\sqrt{\sigma_{m_m}^2+\sigma_{m_c}^2} \frac{R_cm_c-R_mm_c}{(m_m-m_c)^2}\right]^2 +
		    \left[\sigma_{m_c}\frac{R_m-R_c}{m_m-m_c}\right]^2
$$ 
