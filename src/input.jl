# ─────────────────────────────────────────────────────────────────────
# input.jl — Gestion des interactions souris (drag & drop)
# ─────────────────────────────────────────────────────────────────────

"""
    pick_node(state, x, y; radius, tolerance)

Cherche un nœud dont le centre est à distance ≤ `radius + tolerance`
du point (x, y). Retourne son index ou `nothing`.

Si plusieurs nœuds sont sous le curseur (superposition), on sélectionne
le dernier (affiché au-dessus), ce qui est l'attente habituelle de l'utilisateur.
"""
function pick_node(state::GameState, x::Real, y::Real;
                   radius::Real = 14, tolerance::Real = 4)
    threshold = radius + tolerance
    # Parcours inverse : les nœuds plus récents sont dessinés au-dessus
    for i in length(state.nodes):-1:1
        n = state.nodes[i]
        if hypot(n.x - x, n.y - y) <= threshold
            return i
        end
    end
    return nothing
end

"""
    on_press!(state, x, y, canvas; radius)

Handler : clic gauche enfoncé. Sélectionne un nœud s'il y en a un sous
le curseur et enregistre l'offset pour un drag fluide.
"""
function on_press!(state::GameState, x::Real, y::Real, canvas;
                   radius::Real = 14)
    i = pick_node(state, x, y; radius)
    if i !== nothing
        n = state.nodes[i]
        state.dragging = i
        state.drag_ox  = x - n.x   # offset horizontal souris ↔ centre
        state.drag_oy  = y - n.y   # offset vertical
        draw(canvas)
    end
end

"""
    on_move!(state, x, y, canvas; width, height, radius)

Handler : mouvement de la souris. Si un nœud est en cours de drag,
on le déplace en respectant les bords (clamp).
"""
function on_move!(state::GameState, x::Real, y::Real, canvas;
                  width::Real = 800, height::Real = 600, radius::Real = 14)
    state.dragging === nothing && return

    n = state.nodes[state.dragging]
    n.x = clamp(x - state.drag_ox, radius, width  - radius)
    n.y = clamp(y - state.drag_oy, radius, height - radius)
    draw(canvas)
end

"""
    on_release!(state, canvas)

Handler : relâchement du clic. Déselectionne le nœud en cours.
"""
function on_release!(state::GameState, canvas)
    state.dragging = nothing
    draw(canvas)
end
