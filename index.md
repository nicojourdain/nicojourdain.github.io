---
layout: default
---

![baniere1]({{site.baseurl}}/img/baniere_3.jpg)

{::nomarkdown}
<div style="display:inline;text-align:left;">
<img src="{{site.baseurl}}/img/photo_nico-filtered.jpg" style="float: left;" />
<div style="float:right">
CNRS Research Fellow<br>
ARCCSS Associate Investigator<br>
<hr>
<mailto:nicolas.jourdain@univ-grenoble-alpes.fr><br>
<a href="mailto:nicolas.jourdain@univ-grenoble-alpes.fr">nicolas.jourdain@univ-grenoble-alpes.fr</a><br>
<hr>
<b>Office:</b><br>
IGE (Institut des Géosciences de l'Environnement, ex-LGGE)<br>
54 rue Molière<br>
Saint-Martin d’Hères, France<br>
<hr>
<b>Postal address:</b><br>
IGE – Université Grenoble Alpes<br>
CS 40 700<br>
F-38058 Grenoble cedex 9<br>
France<br>
<hr>
</div>
</div>
<div style="clear:both"/>
{:/}


## Research Interests

I am currently studying the interactions between the cryosphere (ice-shelves, ice sheet, sea ice) and the ocean/atmosphere system, mostly focusing on the Southern Ocean. Previously, I've mainly worked on tropical cyclones, the climate of the Maritime Continent, and ocean-atmosphere interactions. A large part of my work is based on numerical models designed to simulate some physical constituents of the climate system.


## Recent posts
{% for post in site.posts %}
   - {{ post.date | date_to_string }} » [{{ post.title }}]({{ site.baseurl }}{{ post.url }})
{% endfor %}
