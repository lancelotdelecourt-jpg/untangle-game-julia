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
    distance = √((x - node.x)² + (y - node.y)²)
    result = nothing
    for i in 1:length(state.nodes)
        n = state.node[i]
        if distance <= radius + tolerance
            result = i
        end
    end
    return result
end

   
"""
    on_press!(state, x, y, canvas; radius)

Handler : clic gauche enfoncé. Sélectionne un nœud s'il y en a un sous
le curseur et enregistre l'offset pour un drag fluide.
"""
function on_press!(state::GameState, x::Real, y::Real, canvas;
                   radius::Real = 14)
  
"""
    on_move!(state, x, y, canvas; width, height, radius)

Handler : mouvement de la souris. Si un nœud est en cours de drag,
on le déplace en respectant les bords (clamp).
"""
function on_move!(state::GameState, x::Real, y::Real, canvas;
                  width::Real = 800, height::Real = 600, radius::Real = 14)
  

"""
    on_release!(state, canvas)

Handler : relâchement du clic. Déselectionne le nœud en cours.
"""
function on_release!(state::GameState, canvas)
    state.dragging = nothing
    draw(canvas)
end
