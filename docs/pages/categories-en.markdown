---
layout: page
title: Categories
permalink: /categories/
lang: en
---

{% assign lang = site.active_lang %}


{% for categoryIdx in (0..site.category_list[lang].size) %}
{% if categoryIdx != site.category_list[lang].size %}
### {{ site.category_list[lang][categoryIdx] }}

<ul class="post-list">
{% for post in site.posts %}
{% for category in post.categories %}
{% if category == site.category_list["en"][categoryIdx] %}
    <li>
        <a class="post-link" href="{{ post.url | relative_url }}"> {{ post.title | escape }} </a>
    </li>
{% endif %}
{% endfor %}
{% endfor %}


</ul>
{% endif %}
{% endfor %}