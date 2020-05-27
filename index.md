---
layout: default
---

<div>
<img src="{{site.url}}img/baniere_3.jpg" width="100%" height="100%"/>
</div>

<br

{::nomarkdown}
<div style="display:inline;text-align:left;">
<img src="{{site.baseurl}}/img/nico_4-3.jpg" width="30%" height="30%" style="float: left;" />
<div style="float:right">
CNRS Research Fellow<br>
<hr>
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
I am currently studying the interactions between the Antarctic Ice Sheet and the climate system at IGE, Grenoble, France. My main aim is to reduce uncertainty on sea level projections. Previously, I worked on tropical cyclones, the Indo-Pacific climate, and ocean-atmosphere interactions, at IRD, Nouméa, New Caledonia, and at CCRC-UNSW, Sydney, Australia. A large part of my work is based on numerical models designed to simulate some physical constituents of the climate system.

[.](/myphotos_dir/myphotos.md).

## News
{% for post in site.posts %}
   - {{ post.date | date_to_string }} » [{{ post.title }}]({{ site.baseurl }}{{ post.url }})
{% endfor %}
