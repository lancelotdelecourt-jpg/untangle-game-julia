
# generator.jl — Génération d'un graphe planaire, puis mélange

function number_of_edges(state, la_ref_du_noeud)
    # cette fonction va chek les deux bouts de chaque edges et compter le nbre de fois qu'un noeud apparait
   d = 0
    for e in state.edges 
        if e.a == la_ref_du_noeud || e.b == la_ref_du_noeud
            d += 1
        end
    end
    return d
end
# then the condition is if one or the other end has 4 links break

function can_add_edge(state,a,b)
    for i in 1:length(state.edges)
        e = state.edges[i]
        if edgescross(state,a,b,e.a,e.b) == true
            return false
        end
    end
    return true
end
    

function generate(state::GameState, n_nodes::Int; width=W, height=H, radius=R)
    # initialise variables
    empty!(state.nodes) # empty clears une array déja en place sans en changer le type
    empty!(state.edges)

    # on cree les trois premiers points
    push!(state.nodes, Node(width/3, height/3 )) # même chose que append mais que pour un seul élément, dcp plus adapté dans ce cas en plus c'est stylé
    push!(state.nodes, Node(2*width/3, height/3 ))
    push!(state.nodes, Node(width/2, 2*height/3 ))

     # On relie les 3 nœuds pour former le triangle
    push!(state.edges, Edge(1, 2))
    push!(state.edges, Edge(2, 3))
    push!(state.edges, Edge(1, 3))

 # étape deux ajouter les noeuds un par un
  pad = radius * 3
    placed = 3
    attempts = 0
    max_attempts = 500000            # garde-fou anti boucle infinie

    while placed < n_nodes && attempts < max_attempts
        attempts += 1
        i = placed + 1
        push!(state.nodes,
              Node(rand()*(width  - 2*pad) + pad,
                   rand()*(height - 2*pad) + pad))

        nbr_i = 0
        for j in 1:i-1
            # on plafonne aussi le degré du nouveau nœud (sinon hub)
            if nbr_i >= 4
                break
            end
            if number_of_edges(state, j) < 5 && can_add_edge(state, i, j)
                push!(state.edges, Edge(i, j))
                nbr_i += 1
            end
        end

        if nbr_i >= 2
            placed += 1
            attempts = 0          # on remet à zéro après un succès
        else
            pop!(state.nodes)
            filter!(e -> e.a != i && e.b != i, state.edges)  # ← le fix
        end
    end
end


     # On téléporte chaque nœud à une position aléatoire. Le graphe reste
    # planaire (une solution existe !) mais le joueur doit la retrouver.
function melange(state; W, H, R)
    n = length(state.nodes)
 
    # Centre du cercle = centre du canvas
    cx = W / 2
    cy = H / 2
 
    # Rayon du cercle : la plus petite demi-dimension, avec une marge
    # pour que les nœuds n'accrochent pas le bord.
    radius = min(W, H) / 2 - R * 3
 
    # On mélange l'ORDRE dans lequel les nœuds occupent les positions du
    # cercle. Les positions sont parfaitement réparties (angles réguliers),
    # mais le nœud i n'ira pas à la position i — il ira à order[i].
    order = shuffle(1:n)
 
    for i in 1:n
        angle = 2π * (order[i] - 1) / n
        state.nodes[i].x = cx + radius * cos(angle)
        state.nodes[i].y = cy + radius * sin(angle)
    end
end
# function set_on_circle(state; W, H, R)
#     radius = H - 2*R
#     center = [H/2, W/2]