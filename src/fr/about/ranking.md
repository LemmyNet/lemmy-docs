# Tendances / Chaud / Meilleur algorithme de tri (algorithme de tri)

## Objectifs

- Au cours de la journée, les nouveaux messages et les commentaires devraient se trouver en tête de liste, afin de pouvoir être soumis au vote.
- Après un jour ou deux, le facteur temps devrait disparaître.
- Utilisez une échelle logarithmique, car les votes ont tendance à faire boule de neige, et donc les 10 premiers votes sont tout aussi importants que les 100 suivants.

## Implémentations

### Reddit

Ne tient pas compte de la durée de vie du fil de discussion, [ce qui donne aux premiers commentaires un avantage écrasant sur les derniers] (https://minimaxir.com/2016/11/first-comment/), l'effet étant encore pire dans les petites communautés. Les nouveaux commentaires sont regroupés au bas du fil de discussion, ce qui a pour effet de tuer la discussion et de faire de chaque fil de discussion une course au commentaire précoce.  Cela diminue la qualité de la conversation et récompense les commentaires répétitifs et les spams.

### Hacker News

Bien qu'il soit de loin supérieur à l'implémentation de Reddit en ce qui concerne la décroissance des scores dans le temps, l'algorithme de classement de [Hacker News] (https://medium.com/hacking-and-gonzo/how-hacker-news-ranking-algorithm-works-1d9b0cf2c08d) n'utilise pas d'échelle logarithmique pour les scores.

### Lemmy

Contrebalance l'effet boule de neige des votes au fil du temps avec une échelle logarithmique. Annule l'avantage inhérent aux premiers commentaires tout en garantissant que les votes comptent toujours sur le long terme, sans nuire aux commentaires populaires plus anciens.

```
Rank = ScaleFactor * log(Max(1, 3 + Score)) / (Time + 2)^Gravity

Score = Upvotes - Downvotes
Time = time since submission (in hours)
Gravity = Decay gravity, 1.8 is default
```
- Lemmy utilise le même algorithme de `Rank` ci-dessus, en deux sortes : `Active`, et `Hot`.
  - Actif" utilise les votes du message, et le temps du dernier commentaire (limité à deux jours).
  - `Hot` utilise les votes du message, et l'heure de publication du message.
- Utilisez Max(1, score) pour vous assurer que tous les commentaires sont affectés par la dégradation du temps.
- Ajoutez 3 au score, pour que tout ce qui a moins de 3 downvotes semble nouveau. Sinon, tous les nouveaux commentaires resteraient à zéro, près du fond.
- Le signe et l'abs du score sont nécessaires pour traiter le log des scores négatifs.
- Un facteur d'échelle de 10k permet d'obtenir le rang sous forme de nombre entier.

Un graphique du rang sur 24 heures, des scores de 1, 5, 10, 100, 1000, avec un facteur d'échelle de 10k.

![](rank_algorithm.png)

#### Comptage des utilisateurs actifs

Lemmy affiche également le nombre d'utilisateurs actifs de votre site et de ses communautés. Ceux-ci sont comptés au cours du dernier jour, de la dernière semaine, du dernier mois et des six derniers mois, et sont mis en cache au démarrage de Lemmy, ainsi que toutes les heures.

Un utilisateur actif est quelqu'un qui a posté ou commenté sur notre instance ou notre communauté au cours de la dernière période donnée. Pour le décompte des sites, seuls les utilisateurs locaux sont comptés. Pour les comptes de la communauté, les utilisateurs fédérés sont inclus.
