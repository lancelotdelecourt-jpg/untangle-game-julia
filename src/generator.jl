# ─────────────────────────────────────────────────────────────────────
# generator.jl — Génération d'un graphe planaire, puis mélange
# ─────────────────────────────────────────────────────────────────────

"""
    can_add_edge(state, a, b) -> Bool

Vérifie qu'on peut ajouter l'arête (a,b) sans croiser aucune arête
déjà présente dans `state.edges`.
"""
function can_add_edge(state::GameState, a::Int, b::Int)
    for e in state.edges
        edges_cross(state, a, b, e.a, e.b) && return false
    end
    return true
end

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
function generate!(state::GameState, n_nodes::Int;
                   width::Real = 800, height::Real = 600, radius::Real = 14)
    empty!(state.nodes)
    empty!(state.edges)

    # Set pour éviter les doublons d'arêtes (paires stockées en (min, max))
    edge_set = Set{Tuple{Int,Int}}()

    # ── Étape 1 : Triangle de base ───────────────────────────────────
    push!(state.nodes, Node(width/2,    height/4))      # sommet 1 : haut centre
    push!(state.nodes, Node(width/4,    3height/4))     # sommet 2 : bas gauche
    push!(state.nodes, Node(3width/4,   3height/4))     # sommet 3 : bas droite

    push!(state.edges, Edge(1, 2))
    push!(state.edges, Edge(2, 3))
    push!(state.edges, Edge(1, 3))

    push!(edge_set, (1, 2), (2, 3), (1, 3))

    # ── Étape 2 : ajout itératif des nœuds suivants ──────────────────
    pad = radius * 3   # marge par rapport aux bords de la fenêtre

    for _ in 4:n_nodes
        new_node = Node(
            rand() * (width  - 2pad) + pad,
            rand() * (height - 2pad) + pad
        )
        push!(state.nodes, new_node)
        new_i = length(state.nodes)

        # On essaie de connecter le nouveau nœud à tous les précédents
        for j in 1:new_i-1
            key = minmax(new_i, j)   # normalise l'ordre (petit, grand)
            key ∈ edge_set && continue

            if can_add_edge(state, new_i, j)
                push!(edge_set, key)
                push!(state.edges, Edge(new_i, j))
            end
        end
    end

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
function scramble!(state::GameState;
                   width::Real = 800, height::Real = 600, radius::Real = 14)
    pad = radius * 3
    for n in state.nodes
        n.x = rand() * (width  - 2pad) + pad
        n.y = rand() * (height - 2pad) + pad
    end
    return state
end
