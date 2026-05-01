
function action_new(state::GameState, canvas)
    generate(state, N_NODES, N_EDGES)
    draw(canvas)
end

function action_restart(state::GameState, canvas)
    # Pour chaque nœud, on restaure son (x, y) depuis initial_positions
    for (i, (x, y)) in enumerate(state.initial_positions)
        state.nodes[i].x = x
        state.nodes[i].y = y
    end
    draw(canvas)
end

function action_solve(parent_window)
    info_dialog("La fonction 'Solve' n'est pas encore implémentée.", parent_window)
end

function on_press(state::GameState, x::Real, y::Real, canvas; radius::Real=R) # x et y positions de la souris
    for (i, nodes) in enumerate(state.nodes) # on parcourt tous les noeuds dans enumerate et pour chaque noeud, on a le noeud lui-même et son numéro
        distance = √((x - nodes.x)^2 + (y - nodes.y)^2)
        if  distance <= radius + 4 # si la distance entre le centre du noeud et la position de la souris est inférieure à R + 4 pixels, alors on considère que le noeud a été cliqué
            state.dragging = i # on mémorise le numéro du nœud qu'on est en train d'attraper
            state.drag_ox  = x - nodes.x # on mémorise le décalage entre la souris et le centre du nœud, en horizontal (ox) et vertical (oy).
            state.drag_oy  = y - nodes.y # nodes.x et nodes.y sont les coordonnées du centre du nœud et x,y sont les coordonnées de la souris au moment du clic
            break # quand on a trouvé un noeud assez proche de la souris, on arrête de chercher un autre noeud
        end
    end
end

function on_move(state::GameState, x::Real, y::Real, canvas; width::Real=W, height::Real=H, radius::Real=R)
    state.dragging === nothing && return # si on a pas de noeud sélectionné, on ne fait rien, le state.dragging vient d'en haut, c'est le numéro du noeud sélectionné
    nodes = state.nodes[state.dragging] # on récupère le nœud qu'on est en train de déplacer, grâce à son numéro mémorisé dans state.dragging
    nodes.x = clamp(x - state.drag_ox, radius, width - radius) # clamp est une fonction de Julia. clamp(x,y,z) avec x la valeur à limiter, y la limite inférieure et z la limite supérieure
    nodes.y = clamp(y - state.drag_oy, radius, height - radius) # le -state.drag_ox et -state.drag_oy permettent de maintenir le même décalage entre la souris et le centre du nœud
                                                 # pendant le déplacement, pour que le nœud ne "saute" pas sous la souris. Donc pour sélectionner un noeud, on ne doit pas
                                                 # cliquer exactement dessus, et le decalage que l'on crée est conservé pendant le déplacement
    draw(canvas) # on redessine pour voir le déplacement du noeud
end

function on_release(state::GameState, canvas)
    state.dragging = nothing # la fonction on_release permet de relacher le nœud qu'on était en train de déplacer, en mettant state.dragging à nothing
    draw(canvas)
end
