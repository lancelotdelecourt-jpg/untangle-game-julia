module Untangle
using Gtk, Cairo, Random, JLD2

# Chargement des sous-modules (ordre important : les dépendances en premier)
include("types.jl")        # structures de données
include("geometry.jl")     # calculs de croisement (dépend de types)
include("generator.jl")    # génération du graphe (dépend de geometry)
include("render.jl")       # affichage Cairo (dépend de geometry)
include("input.jl")        # interactions souris (dépend de types)

const W       = 800   # largeur de la fenêtre en pixels
const H       = 600   # hauteur de la fenêtre en pixels
const R       = 14.0  # rayon d'un nœud en pixels 
const N_NODES = 8
export run_game

const SAVE_FILE = "save.jld2"

function save_state(state::GameState)
    jldsave(SAVE_FILE; nodes=state.nodes, edges=state.edges)
end

function load_state!(state::GameState)
    data = load(SAVE_FILE)
    state.nodes = data["nodes"]
    state.edges = data["edges"]
end

function run_game()
    # 1) État initial du jeu
    node_choices = [5, 8, 10, 15, 18, 20, 180]
    n_nodes      = Ref(N_NODES)

    state = GameState()
    generate!(state, n_nodes[], width = W, height = H, radius = R)
    solved_nodes  = Ref(deepcopy(state.nodes))
    melange!(state; W=W, H=H, R=R)
    initial_nodes = Ref(deepcopy(state.nodes))

    if isfile(SAVE_FILE)
        load_state!(state)
    end

    # 2) Fenêtre + layout vertical
    fenêtre = GtkWindow("Untangle", W, H + 40)
    vbox    = GtkBox(:v)
    push!(fenêtre, vbox)

    # 3) Barre de boutons + liste déroulante
    hbox        = GtkBox(:h)
    btn_new     = GtkButton("New Game")
    btn_restart = GtkButton("Restart")
    btn_solve   = GtkButton("Solve")
    combo       = GtkComboBoxText()
    for n in node_choices
        push!(combo, string(n))
    end
    set_gtk_property!(combo, :active, findfirst(==(N_NODES), node_choices) - 1)

    push!(hbox, combo)
    push!(hbox, btn_new)
    push!(hbox, btn_restart)
    push!(hbox, btn_solve)

    # 4) Canvas
    canvas = GtkCanvas(W, H)
    push!(vbox, hbox)
    push!(vbox, canvas)

    # 5) Callback de dessin
    @guarded draw(canvas) do c
        ctx = getgc(c)
        render(ctx, state; radius = R)
    end

    # 6) Actions des boutons
    signal_connect(combo, :changed) do _
        idx = get_gtk_property(combo, :active, Int) + 1
        n_nodes[] = node_choices[idx]
    end

    signal_connect(btn_new, :clicked) do _
        generate!(state, n_nodes[], width = W, height = H, radius = R)
        solved_nodes[] = deepcopy(state.nodes)
        melange!(state; W=W, H=H, R=R)
        initial_nodes[] = deepcopy(state.nodes)
        state.moves = 0
        draw(canvas)
    end

    signal_connect(btn_restart, :clicked) do _
        state.nodes = deepcopy(initial_nodes[])
        state.dragging = nothing
        state.moves = 0
        draw(canvas)
    end

    signal_connect(btn_solve, :clicked) do _
        state.nodes = deepcopy(solved_nodes[])
        state.dragging = nothing
        draw(canvas)
    end

    # 7) Callbacks souris
    canvas.mouse.button1press = (w, e) ->
        on_press!(state, e.x, e.y, canvas; radius = R)

    canvas.mouse.motion = (w, e) ->
        on_move!(state, e.x, e.y, canvas; width = W, height = H, radius = R)

    canvas.mouse.button1release = (w, e) ->
    begin
        state.moves += 1
        on_release!(state, canvas)
        save_state(state)
    end

    # 8) Affichage + boucle principale
    showall(fenêtre)
    signal_connect(fenêtre, :destroy) do _
        Gtk.gtk_main_quit()
    end
    Gtk.gtk_main()
end

end # module Untangle

