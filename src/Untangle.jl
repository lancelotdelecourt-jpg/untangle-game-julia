module Untangle

# ─────────────────────────────────────────────────────────────────────
# Untangle.jl — Module principal : assemble et lance le jeu
# ─────────────────────────────────────────────────────────────────────

using Gtk, Cairo, Random

# Chargement des sous-modules (ordre important : les dépendances en premier)
include("types.jl")        # structures de données
include("geometry.jl")     # calculs de croisement (dépend de types)
include("generator.jl")    # génération du graphe (dépend de geometry)
include("render.jl")       # affichage Cairo (dépend de geometry)
include("input.jl")        # interactions souris (dépend de types)

# ── Constantes globales du jeu ───────────────────────────────────────
const WINDOW_WIDTH  = 800
const WINDOW_HEIGHT = 600
const NODE_RADIUS   = 14.0
const N_NODES       = 8

export run_game

"""
    run_game()

Point d'entrée : crée la fenêtre, génère un graphe, branche les
callbacks souris et lance la boucle GTK.
"""
function run_game()
    # 1) État initial du jeu
    state = GameState()
    generate!(state, N_NODES;
              width  = WINDOW_WIDTH,
              height = WINDOW_HEIGHT,
              radius = NODE_RADIUS)

    # 2) Fenêtre + canvas
    win    = GtkWindow("Untangle", WINDOW_WIDTH, WINDOW_HEIGHT)
    canvas = GtkCanvas(WINDOW_WIDTH, WINDOW_HEIGHT)
    push!(win, canvas)

    # 3) Callback de dessin (appelé à chaque redraw)
    @guarded draw(canvas) do c
        ctx = getgc(c)
        render(ctx, state; radius = NODE_RADIUS)
    end

    # 4) Callbacks souris
    canvas.mouse.button1press = (w, e) ->
        on_press!(state, e.x, e.y, canvas; radius = NODE_RADIUS)

    canvas.mouse.motion = (w, e) ->
        on_move!(state, e.x, e.y, canvas;
                 width  = WINDOW_WIDTH,
                 height = WINDOW_HEIGHT,
                 radius = NODE_RADIUS)

    canvas.mouse.button1release = (w, e) ->
        on_release!(state, canvas)

    # 5) Affichage + boucle principale
    showall(win)
    signal_connect(win, :destroy) do _
        Gtk.gtk_quit()
    end
    Gtk.gtk_main()
end

end # module Untangle
