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













        
function on_press(state::GameState, x::Real, y::Real, R::Real,canvas) # x et y positions de la souris
    for (i, nodes) in enumerate(state.nodes) # on parcourt tous les noeuds dans enumerate et pour chaque noeud, on a le noeud lui-même et son numéro
        distance = √((x - nodes.x)² + (y - nodes.y)²)
        if  distance <= R + 4 # si la distance entre le centre du noeud et la position de la souris est inférieure à R + 4 pixels, alors on considère que le noeud a été cliqué
            state.dragging = i # on mémorise le numéro du nœud qu'on est en train d'attraper
            state.drag_ox  = x - nodes.x # on mémorise le décalage entre la souris et le centre du nœud, en horizontal (ox) et vertical (oy).
            state.drag_oy  = y - nodes.y # nodes.x et nodes.y sont les coordonnées du centre du nœud et x,y sont les coordonnées de la souris au moment du clic
            break # quand on a trouvé un noeud assez proche de la souris, on arrête de chercher un autre noeud
        end
    end
end

function on_move(state::GameState, x::Real, y::Real,R::Real, W::Real, H::Real, canvas)
    state.dragging === nothing && return # si on a pas de noeud sélectionné, on ne fait rien, le state.dragging vient d'en haut, c'est le numéro du noeud sélectionné
    nodes = state.nodes[state.dragging] # on récupère le nœud qu'on est en train de déplacer, grâce à son numéro mémorisé dans state.dragging
    nodes.x = clamp(x - state.drag_ox, R, W - R) # clamp est une fonction de Julia. clamp(x,y,z) avec x la valeur à limiter, y la limite inférieure et z la limite supérieure
    nodes.y = clamp(y - state.drag_oy, R, H - R) # le -state.drag_ox et -state.drag_oy permettent de maintenir le même décalage entre la souris et le centre du nœud
                                                 # pendant le déplacement, pour que le nœud ne "saute" pas sous la souris. Donc pour sélectionner un noeud, on ne doit pas
                                                 # cliquer exactement dessus, et le decalage que l'on crée est conservé pendant le déplacement
    draw(canvas) # on redessine pour voir le déplacement du noeud
end

function on_release(state::GameState, canvas)
    state.dragging = nothing # la fonction on_release permet de relacher le nœud qu'on était en train de déplacer, en mettant state.dragging à nothing
    draw(canvas)
end










function render(ctx::CairoContext, state::GameState)
    set_source_rgb(ctx, 1, 1, 1) # crée le fond blanc, set_source_rgb est une fonction Cairo et (1,1,1) correspond au blanc en RGB
    paint(ctx) # on peint le canva

    total, crossing = count_crossings(state)

    draw_edges(ctx, state, crossing)
    draw_nodes(ctx, state, radius)
    draw_hud(ctx, total)
end

function draw_edges(ctx::CairoContext, state::GameState, crossing::BitVector)
    for (i, e) in enumerate(state.edges)
        # On récupère les deux nœuds reliés par cette arête
        na = state.nodes[e.a]
        nb = state.nodes[e.b]

        # On trace le trait entre les deux nœuds
        move_to(ctx, na.x, na.y)
        line_to(ctx, nb.x, nb.y)

        # Rouge si croisement, vert sinon
        if crossing[i]
            set_source_rgb(ctx, 0.85, 0.2, 0.2)  # rouge
            set_line_width(ctx, 2.5)
        else
            set_source_rgb(ctx, 0.1, 0.55, 0.35) # vert
            set_line_width(ctx, 1.8)
        end

        stroke(ctx) # on rend le trait visible
    end
end

function draw_nodes(ctx::CairoContext, state::GameState, R::Real)
    for (i, n) in enumerate(state.nodes)

        # On dessine un cercle centré sur le nœud
        arc(ctx, n.x, n.y, R, 0, 2π)

        # Violet si on le déplace, bleu sinon
        if i == state.dragging
            set_source_rgb(ctx, 0.6, 0.2, 0.8)  # violet
        else
            set_source_rgb(ctx, 0.2, 0.4, 0.85) # bleu
        end

        fill_preserve(ctx) # on remplit le cercle ET on garde son contour

        # Contour blanc autour du nœud
        set_source_rgb(ctx, 1, 1, 1)
        set_line_width(ctx, 2.0)
        stroke(ctx)
    end
end

function draw_hud(ctx::CairoContext, total::Int)
    set_source_rgb(ctx, COLOR_TEXT...)

    # Position du texte : coin haut gauche
    move_to(ctx, 10, 24)
    set_font_size(ctx, 18)

    # Message selon le nombre de croisements
    if total == 0
        show_text(ctx, "Bravo ! Aucun croisement 🎉")
    else
        show_text(ctx, "Croisements : $total")
    end
end
