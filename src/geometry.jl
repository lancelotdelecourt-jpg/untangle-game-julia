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
function segments_cross
"""
    edges_cross(state, a, b, c, d) -> Bool

Teste si l'arête (a,b) croise l'arête (c,d) dans le graphe.
Les arêtes partageant un nœud ne sont jamais considérées comme croisées.
"""
function edges_cross

"""
    count_crossings(state) -> (total, crossing)

Parcourt toutes les paires d'arêtes et compte combien se croisent.

Retourne :
- `total`    : nombre total de paires d'arêtes qui se croisent
- `crossing` : vecteur booléen, `crossing[i] = true` si l'arête i
               participe à au moins un croisement (sert au coloriage)
"""
function count_crossings(state::GameState)
  

    return total, crossing
end
