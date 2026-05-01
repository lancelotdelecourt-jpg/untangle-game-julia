# untangle-game-julia

première étape: générer un graphe planaire.
algoritme: 
- on génére 3 points et on les relies entre eux.
- on crée un nouveau point aléatoirement. il va chercher à se lier à d'autres points
    - si le point auquel il cherche à se lier a déjà 4 arrêtes; pas de liaison possible
    - si le point crée une intersection en se liant; pas de liaison possible
    - si le point n'a pas réussi au minimum à créer 2 liaisons; delete point et on réessaye ailleur aléatoirement

après n points on s'arrête
- on mélanges les points et on les places sur un cercle
    - on mélange l'ordre dans lequel les points vont occuper le cercle
    - on place les points sur le cercle suivant cet ordre aléatoire
