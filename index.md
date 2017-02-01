---
layout: default
---

![baniere1]{{site.baseurl}}/img/baniere_3.jpg)

### Nicolas C. Jourdain

## Contact

![baniere1]{{site.baseurl}}/img/photo_nico-filtered.jpg)

nicolas.jourdain@univ-grenoble-alpes.fr

IGE (Institut des Géosciences de l'Environnement, ex-LGGE)  
54, rue Molière, BP 96  F-38402 Saint-Martin d’Hères cedex, France

CNRS Research Fellow  
ARCCSS Associate Investigator


## Research Interests

I am currently studying the interactions between the cryosphere (ice-shelves, ice sheet, sea ice) and the ocean/atmosphere system, mostly focusing on the Southern Ocean. Previously, I've mainly worked on tropical cyclones, the climate of the Maritime Continent, and ocean-atmosphere interactions. A large part of my work is based on numerical models designed to simulate some physical constituents of the climate system.


## Recent posts
{% for post in site.posts %}
   - {{ post.date | date_to_string }} » [{{ post.title }}]({{ site.baseurl }}{{ post.url }})
{% endfor %}



