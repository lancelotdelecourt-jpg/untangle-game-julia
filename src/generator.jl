
# generator.jl — Génération d'un graphe planaire, puis mélange

function can_add_edge(state,a,b)
    for i in 1:length(state.edges)
        e = state.edges[i]
        if edgescross(state,a,b,e.a,e.b) == true
            return false
        end
    end
    return true
end
    

function generate!( state :: GameState, n_nodes::Int, n_edges::Int)
    # initialise variables
    empty!(state.nodes) # empty clears une array déja en place sans en changer le type
    empty!(state.edges)

    # on cree les trois premiers points
    push!(state.nodes, Node(W/3, H/3 )) # même chose que append mais que pour un seul élément, dcp plus adapté dans ce cas en plus c'est stylé
    push!(state.nodes, Node(2*W/3, H/3 ))
    push!(state.nodes, Node(W/2, 2*H/3 ))

     # On relie les 3 nœuds pour former le triangle
    push!(state.edges, Edge(1, 2))
    push!(state.edges, Edge(2, 3))
    push!(state.edges, Edge(1, 3))

 # étape deux ajouter les noeuds un par un
    pad = R*3 
    for i in 4:n_nodes
        new_node = Node(
            rand()*(W - 2*pad) + pad,
            rand()*(H - 2*pad) + pad)
        
        push!(state.nodes, new_node)
        # pour chaque noeud créé essayer de faire le plus de liaison possible sans 
        #croiser de liaison déjà faite
        for j in 1: length(state.nodes)-1
        new_edge = Edge(i,j)
            if can_add_edge(state,i,j) == true
                push!(state.edges,new_edge)
            end
        end
    end
end
    # On téléporte chaque nœud à une position aléatoire. Le graphe reste
    # planaire (une solution existe !) mais le joueur doit la retrouver.
 function melange!(state; W, H, R)
    pad = R*3
    for i in 1:length(state.nodes)
           e = state.nodes[i]
            e.x = rand()*(W - 2*pad) + pad
            e.y = rand()*(H - 2*pad) + pad
     end
end
melange!(state; W,H,R)


