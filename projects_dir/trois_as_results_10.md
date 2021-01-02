---
layout: trois_as_post
title: "ISMIP6 projections for Antarctica"
date: 2020-09-17
---

<center><div>
<img src="{{site.url}}img/logo_ISMIP6.png" width="30%" height="30%"/>
</div></center>

The main results from the Ice Sheet Model intercomparison Project for CMIP6 (ISMIP6 ) have been published today. They include new sea-level projections to 2100 induced by mass changes of the Antarctic ice sheets. Thanks to the support of TROIS-AS, IGE has contributed to these projections.

## Historical context and previous estimates to 2100

The first three IPCC Assessment Reports (AR), written between 1990 and 2001, reported that Antarctica would gain mass throughout the 21st century, which is equivalent to a negative contribution to sea level ([Shepherd and Nowicki 2017][Shepherd17]). The evolution of the ice sheet dynamics was indeed thought to be unlikely over such relatively short time scales, and increasing snow accumulation was thought to be the main driver of future Antarctic mass gain. The AR4, in 2007, was the 1st IPCC report to report a possible sea-level contribution of the Antarctic ice-sheet dynamics, as satellite observations had started to show mass loss in West Antarctica.

In SeaRISE ([Bindschadler et al. 2013][Bindschadler13]), the ice-sheet model intercomparison project organized just before IPCC's 5th Assessment Report, a uniform basal melting anomaly was prescribed (increasing linearly from 0 to 30m/yr through the 21st century) to represented the expected behaviour of CMIP5 ocean models under RCP8.5. At the time, several models were also not able to capture grounding line motions ([Durand and Pattyn, 2015][Durand15]), and the predicted Antarctic contribution to sea level ranged between 0 and +14 cm of SLE over the 21st century ([Bindschadler et al. 2013][Bindschadler13]). By deriving the dynamic ice-sheet response from linear response functions for basal ice-shelf melting for four different Antarctic drainage regions (based on SeaRISE results), [Levermann et al. (2014)][Levermann14] found a _likely_ contribution between +4 and +21 cm of SLE over the 21st century.

Last year, the IPCC Special Report on the Ocean and Cryosphere in a Changing Climate ([SROCC, 2019][SROCC19]) estimated that under RCP8.5, Antarctica would _likely_ contribute between 3 and 28 cm SLE. This was informed by [Levermann et al. (2014)][Levermann14] as well as other studies based on individual ice sheet models (Golledge et al. [2014][Golledge14],[2019][Golledge19]; [De Conto and Pollard 2016][DeConto16]; [Bulthuis et al. 2019][Bulthuis19]), with various strategies to represent future ice-shelf melting by the ocean.

## New ISMIP6 estimates to 2100

[Seroussi et al. (2020)][Seroussi20] present the results from 18 ice sheet simulations produced by 15 international groups. The contribution of the Antarctic ice sheet in response to increased warming during this period varies between -7.8 and +30.0 cm of Sea Level Equivalent (SLE). The novelty in these projections is the close link to projections from a selection of CMIP5 models ([Barthel et al. 2020][Barthel20]; results forced by CMIP6 projections will be published later on), which explains the involvement of physical oceanographers and atmosphere scientists in ISMIP6. 

## Beyond 2100

A series of new ice-sheet model experiments [(ABUMIP; Sun et al. 2020)][Sun20] sheds new light on the importance of ice shelves (the floating termination of many Antarctic ice streams) for sea level rise. By instantaneously removing all ice shelves, Sun and colleagues find a sea level rise of +1 to +8 m in 200 years depending on the ice-sheet model. This is due to the butressing effect of ice shelves on the grounded ice flow. A few total or partial ice shelf collapses have been observed (e.g., Larsen A-B, Thwaites), and it is still a real challenge for the community to understand how and when such collapses can be triggered by air or ocean warming in more realistic scenarios. 

Using a single ice sheet model, [Garbe et al. (2020)][Garbe20] have analyzed the long-term stability of the Antarctic ice-sheet. They impose temperature perturbations that are very slow compared to the typical time scale of ice-sheet evolutions in a way to remain close to equilibrium. For a global warming of 2°C above pre-industrial levels, they find that West Antarctica is committed to partial collapse because of the marine ice-sheet instability. For warming of 6 to 9°C, more than 70% of the current ice volume would be lost, mainly due to the surface-elevation feedback affecting melt rates. Importantly, the currently observed ice-sheet configuration is not regained even if temperatures are reversed to present-day levels.

## Huge uncertainty on future melting by the ocean

For ISMIP6, no ocean models was used to provide future ocean conditions. There is indeed no representation of ice-shelf cavities in any of the CMIP5 or CMIP6 ocean components. Stand-alone ocean projections forced by CMIP5 or CMIP6 projections (e.g. [Naughten et al. 2018][Naughten18]) could have been used, but this type of models suffer from relatively strong present-day biases (e.g. cold conditions in the Amundsen Sea while much warmer conditions are observed), which makes them somewhat unfit to provide melt rates to ice-sheet models. Furthermore, stand-alone ocean models usually have a static ice-shelf geometry, which makes it difficult to extrapolate ocean conditions to an ice-sheet model for which the ice shelf geometry evolves. Finally, the time frame of ISMIP6 was too short to develop new ocean simulations. Therefore, it has been chosen to rely on a melting parameterization.

Using the MISOMIP idealized set-up under various temperature initial conditions and changes, [Favier et al. (2019)][Favier19] evaluated several ocean melting parameterizations implemented in the Elmer/Ice ice-sheet model in comparison to an ensemble of ocean-ice sheet (NEMO-Elmer/Ice) coupled simulations. They proposed a very simple formulation depending on the product of the local thermal forcing by the ice-shelf-averaged thermal forcing, which was closest to the coupled simulations. This was chosen as the ISMIP6 standard melting parameterization, but other groups were encouraged to use their own parameterizations in some of the ISMIP6 experiments. 

While it is quite simple to tune a parameterization for a single ice shelf in idealized conditions as in [Favier et al. (2019)][Favier19], it is much more difficult at the scale of Antarctica with poorly observed ocean temperatures. In ISMIP6, the choice was made to correct observational ocean temperatures and to use a single exchange velocity for all Antarctic ice sheets [(Jourdain et al. 2020)][Jourdain20]. This correction actually corrects both observational biases and biases due to the simple physical formulation of parameterized melt rates. Depending on the tuning target (mean Antarctic melt rate or melt rate near Pine Island's grounding line), future melt rates can vary by a factor of 10, with large consequences on sea level projections [(Séroussi et al. 2020)][Seroussi20]. There are currently not enough interannual ocean/melt observations and circum-Antarctic ocean models present large biases in some regions, so it is difficult to narrow the range of uncertainty on tuning parameters. Another large source of uncertainty for future projections is the ocean sub-surface warming was taken directly from the CMIP5 models that poorly capture the Antarctic continental shelf and do not represent ice shelf cavities.

[Barthel20]: https://doi.org/10.5194/tc-14-855-2020
[Bindschadler13]: https://doi.org/10.3189/2013JoG12J125
[Bulthuis19]: https://doi.org/10.5194/tc-13-1349-2019
[DeConto16]: doi:10.1038/nature17145
[Durand15]: https://doi.org/10.5194/tc-9-2043-2015
[Favier19]: https://doi.org/10.5194/gmd-12-2255-2019
[Garbe20]: https://www.nature.com/articles/s41586-020-2727-5
[Goelzer20]: https://doi.org/10.5194/tc-14-3071-2020
[Golledge14]: https://doi.org/10.1038/nature15706
[Golledge19]: https://doi.org/10.1038/s41586-019-0889-9
[Hamlington20]: https://doi.org/10.1029/2019RG000672
[Jourdain20]: https://doi.org/10.5194/tc-14-3111-2020
[Kulp19]: https://doi.org/10.1038/s41467-019-12808-z
[Lai20]: https://www.nature.com/articles/s41586-020-2627-8
[Levermann14]: https://doi.org/10.5194/esd-5-271-2014
[Lhermitte20]: https://doi.org/10.1073/pnas.1912890117
[Lipscomb20]: https://doi.org/10.5194/tc-2019-334
[Naughten18]: https://doi.org/10.1175/JCLI-D-17-0854.1
[Pattyn13]: https://doi.org/10.3189/2013JoG12J129
[Reese20]: https://doi.org/10.5194/tc-14-3097-2020
[Seroussi20]: https://doi.org/10.5194/tc-14-3033-2020
[Shepherd17]: https://doi.org/10.1038/nclimate3400
[Slater20]: https://doi.org/10.5194/tc-14-985-2020
[SROCC19]: https://www.ipcc.ch/srocc/download/
[Sadai20]: https://advances.sciencemag.org/content/advances/6/39/eaaz1169.full.pdf
[Sun20]: https://doi.org/10.1017/jog.2020.67

