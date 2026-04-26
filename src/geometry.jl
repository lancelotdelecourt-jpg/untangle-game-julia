# début des fonctions : 

function segmentscross(ax, ay, bx, by, cx, cy, dx, dy) # Permet de savoir si deux vecteurs sont croisés 
    # On calcule les vecteurs de direction
    dx_ab = bx - ax
    dy_ab = by - ay
    dx_cd = dx - cx
    dy_cd = dy - cy

    # On calcule le déterminant pour vérifier si les droites sont parallèles
    
    det = dx_ab * (-dy_cd) - (-dx_cd) * dy_ab

    # Si le déterminant est proche de 0, les segments sont parallèles
    if abs(det) < 1e-10
        return false
    end
# On utilise la règle de Cramer pour trouver t et u
    # t est la position sur le segment [A,B]
    # u est la position sur le segment [C,D]
    t = ((cx - ax) * (-dy_cd) - (-dx_cd) * (cy - ay)) / det
    u = (dx_ab * (cy - ay) - (cx - ax) * dy_ab) / det

    # On vérifie si le croisement est "strict"
    # eps est une toute petite valeur pour éviter les erreurs aux extrémités
    eps = 1e-10
    return (eps < t < 1 - eps) && (eps < u < 1 - eps)
end


function edgescross(state::GameState, a, b, c, d)
    # 1. Si les arêtes partagent un nœud, elles ne se "croisent" pas pour julia mais bien pour nous
    if a == c || a == d || b == c || b == d
        return true
    end

    # 2. On récupère les coordonnées x y des Nodes correspondants aux indices
    na, nb = state.nodes[a], state.nodes[b]
    nc, nd = state.nodes[c], state.nodes[d]

    # 3. On appelle la fonction mathématique avec les coordonnées x et y
    return segmentscross(na.x, na.y, nb.x, nb.y, nc.x, nc.y, nd.x, nd.y)
end # return true si les arrêtes se croisent


function countcrossings(state::GameState)
    # 1. On compte combien il y a d'arêtes au total dans le jeu
    n = length(state.edges)
    
    # 2. On crée une liste de "vrai/faux" pour marquer les arêtes croisées
    # Au début, on met tout à 'false' (aucune n'est croisée)
    crossing = fill(false, n)
    
    # 3. On prépare un compteur pour le nombre total de croisements
    total = 0

    # 4. LA DOUBLE BOUCLE : on compare chaque arête avec les autres
    for i in 1:n            # i est l'index de la première arête
        for j in (i + 1):n  # j est l'index de la deuxième arête
         # On récupère les deux arêtes qu'on veut comparer
            e1 = state.edges[i]
            e2 = state.edges[j]
            
            # 5. On vérifie si l'arête i croise l'arête j
            if edgescross(state, e1.a, e1.b, e2.a, e2.b)
                # Si ça croise :
                total += 1          # On ajoute 1 au compteur total
                crossing[i] = true  # On marque l'arête i comme "croisée"
                crossing[j] = true  # On marque l'arête j comme "croisée"
            end
        end
    end
# 6. On renvoie les deux résultats
    return total, crossing
end