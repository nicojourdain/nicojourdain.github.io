---
layout: post
title: "Assessing sub-ice-shelf melt parameterizations"
date: 2019-05-24
---

In this [new paper in GMD][1] led by Lionel Favier, we present the new Elmer/Ice-NEMO ice-ocean coupled model, and we use it to evaluate sub-ice-shelf melt parameterizations implemented in Elmer/Ice. These parameterizations include simple linear or quadratic functions of the thermal forcing, [solutions of simplified box models][5], and [emulations of box models][6].

![]({{site.url}}projects_dir/img/Favier_2019_Fig1.png)
*Schematic of the coupled interactions between NEMO and Elmer/Ice.* 

We use the idealized [MISOMIP][2] configuration, and we prescribe 2 constant temperature scenarios (a warm and a cold), and 4 warming scenarios over 100 years as shown below.

<center><div>
<img src="{{site.url}}projects_dir/img/Favier_2019_Fig3a.png" width="50%" height="50%"/>
</div></center>
*Vertical temperature profiles corresponding to the idealized ocean warming scenarios*

The parameterized melt rate patterns are all very different from those simulated by NEMO. 

![]({{site.url}}projects_dir/img/Favier_2019_Fig4.png)
*Initial melt rates obtained with a warm temperature profile and simple parameterizations (1st column), box parameterizations (2nd column), plume parameterizations (3rd column) and the Elmer/Ice-NEMO ice-ocean coupled model (4th column).*

It is nonetheless difficult to anticipate the effect on ice dynamics because, depending where it occurs, localised melting can either have very little effect on the dynamics or accelerate ice flow in regions far from the melt perturbation ([Reese et al 2018][3]). Therefore, the best way to evaluate the parameterizations is through the ice flow response.

![]({{site.url}}projects_dir/img/Favier_2019_Fig6.png)
*Mean global sea level contribution in 100 years under 4 warming scenarios, for all the parameterizations (colors) and the coupled model (grey shading).*

The plume parameterisation underestimates the contribution to sea level when forced by the warming scenarios. The box parameterisation compares fairly well to the coupled results in general and gives the best results using five boxes. For simple scalings, the comparison to the coupled framework shows that a quadratic dependency to thermal forcing is required, as opposed to linear. In addition, the quadratic dependency is improved when melting depends on both local and nonlocal, i.e. averaged over the ice shelf, thermal forcing. The results of both the box and the two quadratic parameterisations fall within or close to the coupled model uncertainty. 

This study was funded by the [TROIS AS][4] ANR project and the ISOCLINE IDEX-IRS project, and the simulations were run on the occigen supercomputer at CINES.

# Reference
Favier, L., Jourdain, N. C., Jenkins, A., Merino, N., Durand, G., Gagliardini, O., Gillet-Chaulet, F., and Mathiot, P. (2019). Assessment of Sub-Shelf Melting Parameterisations Using the Ocean-Ice Sheet Coupled Model NEMO(v3.6)-Elmer/Ice(v8.3), _Geoscientific Model Development_, [doi:10.5194/gmd-2019-26](https://doi.org/10.5194/gmd-2019-26).

[1]: https://www.geosci-model-dev-discuss.net/gmd-2019-26/
[2]: https://www.geosci-model-dev.net/9/2471/2016/
[3]: https://www.nature.com/articles/s41558-017-0020-x
[4]: http://nicojourdain.github.io/projects_dir/trois_as
[5]: https://www.the-cryosphere.net/12/1969/2018/
[6]: https://www.the-cryosphere.net/12/49/2018/
