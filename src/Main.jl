module Untangle
using Gtk, Cairo, Random

# Chargement des sous-modules (ordre important : les dépendances en premier)
include("types.jl")        # structures de données
include("geometry.jl")     # calculs de croisement (dépend de types)
include("generator.jl")    # génération du graphe (dépend de geometry)
include("render.jl")       # affichage Cairo (dépend de geometry)
include("input.jl")        # interactions souris (dépend de types)

# ── Constantes globales du jeu ───────────────────────────────────────
const W       = 800   # largeur de la fenêtre en pixels
const H       = 600   # hauteur de la fenêtre en pixels
const R       = 14.0  # rayon d'un nœud en pixels 
const N_NODES = 8     # nombre de nœuds dans le graphe
const N_EDGES = 11    # nombre d'arêtes dans le graphe

export run_game
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


"""
    run_game()

Point d'entrée : crée la fenêtre, génère un graphe, branche les
callbacks souris et lance la boucle GTK.
"""
function run_game()
    # 1) État initial du jeu
    state = GameState()
    generate!(state, N_NODES, width = W, height = H, radius = R)

    # 2) Fenêtre + canvas
    fenêtre    = GtkWindow("Untangle", W, H)
    canvas = GtkCanvas(W, H)
    push!(fenêtre, canvas)

    # 3) Callback de dessin (appelé à chaque redraw)
    @guarded draw(canvas) do c
        ctx = getgc(c)
        render(ctx, state; radius = R)
    end

    # 4) Callbacks souris
    canvas.mouse.button1press = (w, e) -> # e = évenement souris
        on_press!(state, e.x, e.y, canvas; radius = R)

    canvas.mouse.motion = (w, e) ->
        on_move!(state, e.x, e.y, canvas;width  = W, height = H, radius = R)

    canvas.mouse.button1release = (w, e) ->
        on_release!(state, canvas)

    # 5) Affichage + boucle principale
    showall(fenêtre)
    signal_connect(fenêtre, :destroy) do _
        Gtk.gtk_quit()
    end
    Gtk.gtk_main()
end

end # module Untangle
