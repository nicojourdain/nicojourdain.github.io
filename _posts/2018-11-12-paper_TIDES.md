---
layout: post
title: "Influence of tides on ice-shelf melting"
date: 2018-11-12
---

Tides influence the ocean temperature and salinity in many ways, in particular in Antarctic seas. **Tidal processes affect ice-shelf melting either by changing ocean temperatures seaward of the ice shelves (through tidal vertical mixing or residual currents), or by directly affecting heat exchanges at the ocean/ice-shelf interface**. 

Tidal vertical mixing is caused by vertical shear, as tidal currents rub upon the seafloor, and by the breaking of internal tidal waves generated by the interaction of barotropic tidal currents with steep topography. Tides not only induce mixing but also generate a mean residual circulation through the Stokes drift and non-linear dynamics. Both vertical mixing and residual currents can affect thermal exchanges over the Antarctic continental shelves. 

Within ice shelf cavities, tides primarily affect ice/ocean interactions by increasing velocities and therefore turbulent heat exchanges near the ice base. The extra melting caused by tides induces an additional buoyancy-driven residual circulation, which in turn can increase ice-shelf melting. Estimating the relative importance of each of these tidal processes is a prerequisite for better prescribing or parameterizing the effect of tides on ice shelf cavities. 

Understanding the interplay between all these processes is important because it tells how tidal effects should be precribed in the climate models that do not explicitly represent tides. In [our new paper][2] (non-edited version available [here][6]), we consider the example of the Amundsen Sea, and run numerous [NEMO][3] regional simulations to analyse the multiple effects of tides on ice-shelf melting. 

<center><div>
<img src="{{site.url}}projects_dir/img/paper_TIDES_AMU12_Fig1.png" width="75%" height="75%"/>
</div></center>
*Simulated area including 7 ice shelves (from Getz to Abbot), the Dotson-Getz Trough (DGT) and the Western and Eastern Pine Island Troughs (PITW and PITE respectively). The blue contour indicates the ice sheet edge, while the gray to black contours indicate isobaths). Shadings indicate the barotropic stram function (the difference between 2 points on the map gives the ocean transport in millions of m3/s through the corresponding vertical section).*

In [our study][2], we show that diurnal tides produce strong tidal velocities over the continental shelf break. Steep topography indeed generates tidal waves that cannot propagate away from their generation site that are poleward of the critical latitude (where inertial frequency equals tidal frequency and beyond which tidal waves do not propagate freely). These strong currents enhance vertical mixing over the continental shelf break. We also bring evidence for a significant residual circulation that flows westward along the continental shelf break and southward in Dotson-Getz Trough (see figure below). 

<center><div>
<img src="{{site.url}}projects_dir/img/paper_TIDES_AMU12_Fig5.png" width="75%" height="75%"/>
</div></center>
*Barotropic stream function of the tidal residual circulation in the absence of ocean stratification and ice shelf melting (the difference between 2 points on the map gives the ocean transport in millions of m3/s through the corresponding vertical section).*

While these processes can be identified seaward of the ice shelves, they do not affect ocean temperatures to a significant extent and have therefore little effects on ice-shelf melting. By contrast, **tidal velocities in ice shelf cavities strengthen ocean turbulence near the ice base, and therefore enhance melting underneath all the ice shelves of the Amundsen Sea**. The cold meltwater produced by tides slightly cools the ocean waters at the ice-sehlf base, which cancels approximately a third of the melt increase that would occur in response to enhanced turbulence.  

Overall, **the representation of tides in our regional simulations enhances ice-shelf melting, with weakest effects for Pine Island (+1%) and Thwaites (+8%) and strongest effects for Dotson (+30%), Cosgrove (+34%) and Abbot (+39%)**. The relatively weak tidal effect on Pine Island and Thwaites is likely due to the thick water column that makes the resonnant quarter wavelength much larger than the typical horizontal cavity size. By contrast, the Amundsen cavities with shallower water columns tend to be resonnant for semi-diurnal tides. The strong sensitivity of the tidal effect to the water column thickness shows that the aforementioned numbers have to be considered carefully because of the high uncertainty on bathymetry and ice-shelf drafts.

These results indicate that **including tidal velocities into the equation of the turbulent heat flux is a good approach to account for tide-induced melting in ocean models that do not explicitly represent tides**. It is nonetheless important to keep the horizontal patterns of tidal velocities, and prescribing uniform tidal velocities leads to large errors. Overall, we find that prescribibg 66% of the tidal velocity from a barotropic tidal model reproduces remarkably well tide-induced melting.

The work leading to this publication was supported by the [TROIS AS][4] ANR project and the simulations were run on the occigen supercomputer at [CINES][5].

# Reference
Jourdain, N. C., Molines, J.-M., Le Sommer, J., Mathiot, P., Chanut, J., de Lavergne, C. and Madec, G. (2018). Simulating or prescribing the influence of tides on the Amundsen Sea ice shelves. _Ocean Modelling, in press_. [doi/10.1016/j.ocemod.2018.11.001][2]. Non-edited version available [here][6].


[1]: https://doi.org/10.1002/2016RG000546
[2]: https://doi.org/10.1016/j.ocemod.2018.11.001
[3]: http://www.nemo-ocean.eu
[4]: https://nicojourdain.github.io/projects_dir/trois_as 
[5]: https://www.cines.fr/en/
[6]: https://mycore.core-cloud.net/index.php/s/xC37G9OAo4U4qiP
