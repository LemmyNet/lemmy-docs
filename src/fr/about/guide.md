# Guide de Lemmy

Commencez à taper...

- `@nom_utilisateur` pour obtenir une liste de noms d'utilisateurs.
- `!a_communauté` pour obtenir une liste de communautés.
- `:emoji` pour obtenir une liste d'emojis.

## Triage

*Applique aux messages et aux commentaires*.

Type | Description
--- | ---
Actif | Tendance triée en fonction du score et de l'heure du commentaire le plus récent.
Hot | Tendance de tri basée sur le score et l'heure de création du message.
Nouveau | Les éléments les plus récents.
Plus de commentaires | Les messages avec le plus de commentaires.
Nouveaux commentaires | Les messages avec les commentaires les plus récents, IE un tri de style forum.
Top | Les éléments les mieux notés dans la période donnée.

Pour plus de détails, consultez le [Classement des messages et des commentaires] (ranking.md).

## Modération / Administration

Toutes les actions de modération et d'administration sur les utilisateurs sont effectuées sur les commentaires ou les messages, en cliquant sur l'icône à 3 points "Plus".

Cela inclut :

- Ajouter / Supprimer des modérateurs ou des administrateurs.
- Supprimer / Restaurer des commentaires.
- Bannir / Débannir des utilisateurs.

Toutes les actions d'administration sur les communautés sont effectuées sur la barre latérale de la communauté. Actuellement, cela ne comprend que la suppression et la restauration des communautés.

## Markdown Guide

Tapez | ou | ... pour obtenir
--- | --- | ---
\*Italique\* | \_Italique\_  | _Italique_ 
\*\*Gras\*\* | \_\_Gras\_\_ | **Gras** 
\# Rubrique 1 | Rubrique 1 <br> ========= | <h4>Rubrique 1</h4>
\## Rubrique 2 | Rubrique 2 <br>--------- | <h5>Rubrique 2</h5>
\[lien\](http://a.com) | \[lien\]\[1\]<br>⋮ <br>\[1\]: http://b.org | [lien](https://commonmark.org/) 
!\[Image\](http://url/a.png) | !\[Image\]\[1\]<br>⋮ <br>\[1\]: http://url/b.jpg | ![Markdown](https://commonmark.org/help/images/favicon.png) 
\> Citation en bloc | | <blockquote>Citation en bloc</blockquote>
\* Liste <br>\* Liste <br>\* Liste | \- Liste <br>\- Liste <br>\- Liste <br> | *   Liste <br>*   Liste <br>*   Liste <br>
1\. Un <br>2\. Deux <br>3\. Trois | 1) Un<br>2) Deux<br>3) Trois | 1.  Une<br>2.  Deux<br>3.  Trois
Règle horizontale <br>\--- | Règle horizontale<br>\*\*\* | Règle horizontale  <br><hr>
\`Code Inline\` avec des backticks | |`Code Inline` avec des backticks 
\`\`\`<br>\# bloc de code <br>print '3 backticks ou'<br>print 'retrait de 4 espaces' <br>\`\`\` | ····\# bloc de code<br>····print '3 backticks ou'<br>····print 'retrait de 4 espaces' | \# bloc de code <br>print '3 backticks ou'<br>print 'retrait de 4 espaces'
::: spoiler caché ou trucs nsfw<br>*un tas de spoilers ici*<br>::: | | <details><summary> spoiler caché ou trucs nsfw </summary><p><em>un tas de spoilers ici</em></p></details>
Certains texte \~indice\~ | | Certains texte <sub>indice</sub>
Quelques texte ^indice^ | | Quelques texte <sup>indice</sup>

[Tutoriel CommonMark](https://commonmark.org/help/tutorial/)

