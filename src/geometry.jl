# ─────────────────────────────────────────────────────────────────────
# geometry.jl — Détection des croisements entre segments
# ─────────────────────────────────────────────────────────────────────

"""
    segments_cross(ax, ay, bx, by, cx, cy, dx, dy) -> Bool

Indique si le segment [A,B] croise strictement le segment [C,D].

Méthode : on résout l'équation paramétrique
    A + t·(B-A) = C + u·(D-C)
Le croisement existe si et seulement si 0 < t < 1 et 0 < u < 1.

Les petits epsilons (1e-10) évitent les faux positifs aux extrémités
(deux arêtes qui partagent un nœud ne doivent pas compter comme croisées).
"""
function segments_cross(ax, ay, bx, by, cx, cy, dx, dy)
    # Vecteurs directeurs des deux segments
    d1x, d1y = bx - ax, by - ay
    d2x, d2y = dx - cx, dy - cy

    # Déterminant : si nul, les segments sont parallèles → pas de croisement
    denom = d1x * d2y - d1y * d2x
    abs(denom) < 1e-10 && return false

    # Paramètres t et u le long des deux segments
    t = ((cx - ax) * d2y - (cy - ay) * d2x) / denom
    u = ((cx - ax) * d1y - (cy - ay) * d1x) / denom

    # Croisement strict à l'intérieur des deux segments
    return 1e-10 < t < 1 - 1e-10 && 1e-10 < u < 1 - 1e-10
end

"""
    edges_cross(state, a, b, c, d) -> Bool

Teste si l'arête (a,b) croise l'arête (c,d) dans le graphe.
Les arêtes partageant un nœud ne sont jamais considérées comme croisées.
"""
function edges_cross(state::GameState, a::Int, b::Int, c::Int, d::Int)
    # Arêtes adjacentes (qui partagent un nœud) → ignorées
    (a == c || a == d || b == c || b == d) && return false

    na, nb = state.nodes[a], state.nodes[b]
    nc, nd = state.nodes[c], state.nodes[d]

    return segments_cross(na.x, na.y, nb.x, nb.y,
                          nc.x, nc.y, nd.x, nd.y)
end

"""
    count_crossings(state) -> (total, crossing)

Parcourt toutes les paires d'arêtes et compte combien se croisent.

Retourne :
- `total`    : nombre total de paires d'arêtes qui se croisent
- `crossing` : vecteur booléen, `crossing[i] = true` si l'arête i
               participe à au moins un croisement (sert au coloriage)
"""
function count_crossings(state::GameState)
    n = length(state.edges)
    crossing = falses(n)
    total = 0

    # Double boucle sur les paires (i, j) avec i < j pour ne pas compter deux fois
    for i in 1:n, j in i+1:n
        ei, ej = state.edges[i], state.edges[j]
        if edges_cross(state, ei.a, ei.b, ej.a, ej.b)
            crossing[i] = true
            crossing[j] = true
            total += 1
        end
    end

    return total, crossing
end
