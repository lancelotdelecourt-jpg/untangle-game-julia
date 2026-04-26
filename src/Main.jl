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
