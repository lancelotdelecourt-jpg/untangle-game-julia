# ─────────────────────────────────────────────────────────────────────
# generator.jl — Génération d'un graphe planaire, puis mélange
# ─────────────────────────────────────────────────────────────────────

"""
    can_add_edge(state, a, b) -> Bool

Vérifie qu'on peut ajouter l'arête (a,b) sans croiser aucune arête
déjà présente dans `state.edges`.
"""
function can_add_edge
"""
    generate!(state, n_nodes; width, height, radius)

Remplit `state` avec un graphe planaire (= sans croisements) de `n_nodes`
nœuds, puis mélange aléatoirement les positions pour créer le puzzle.

Algorithme :
1. On part d'un triangle de base (3 nœuds, 3 arêtes) — trivialement planaire.
2. On ajoute les nœuds suivants un par un à des positions aléatoires,
   et on essaie de les connecter à tous les nœuds existants ; on ne
   conserve que les arêtes qui ne croisent rien (→ reste planaire).
3. Une fois le graphe construit, on "scramble" les positions : le joueur
   doit retrouver une disposition sans croisement par drag-and-drop.
"""
function generate!(

    # ── Étape 3 : scramble ────────────────────────────────────────────
    # On téléporte chaque nœud à une position aléatoire. Le graphe reste
    # planaire (une solution existe !) mais le joueur doit la retrouver.
    scramble!(state; width, height, radius)

    return state
end

"""
    scramble!(state; width, height, radius)

Repositionne aléatoirement tous les nœuds dans la fenêtre, en respectant
une marge par rapport aux bords.
"""
function scramble!
