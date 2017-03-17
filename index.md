---
layout: default
---

![baniere1]({{site.baseurl}}/img/baniere_3.jpg)

## Contact

|                                                         | <mailto:nicolas.jourdain@univ-grenoble-alpes.fr>           |
| ![myface]({{site.baseurl}}/img/photo_nico-filtered.jpg) | IGE (Institut des Géosciences de l'Environnement, ex-LGGE) |
|                                                         | 54, rue Molière, Saint-Martin d’Hères, France              |

{::nomarkdown}
<div style="float:left" markdown="1">
![myface]({{site.baseurl}}/img/photo_nico-filtered.jpg)
</div>
<div style="float:right" markdown="1">
<mailto:nicolas.jourdain@univ-grenoble-alpes.fr>
IGE (Institut des Géosciences de l'Environnement, ex-LGGE)
54, rue Molière, Saint-Martin d’Hères, France
</div>
<div style="clear:both"/>
{:/}

CNRS Research Fellow  
ARCCSS Associate Investigator


## Research Interests

I am currently studying the interactions between the cryosphere (ice-shelves, ice sheet, sea ice) and the ocean/atmosphere system, mostly focusing on the Southern Ocean. Previously, I've mainly worked on tropical cyclones, the climate of the Maritime Continent, and ocean-atmosphere interactions. A large part of my work is based on numerical models designed to simulate some physical constituents of the climate system.


## Recent posts
{% for post in site.posts %}
   - {{ post.date | date_to_string }} » [{{ post.title }}]({{ site.baseurl }}{{ post.url }})
{% endfor %}
