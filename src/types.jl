
mutable struct Node
    x::Float64
    y::Float64
end


struct Edge
    a::Int   # index du premier nœud dans state.nodes
    b::Int   # index du second nœud
end

"""
    GameState

État complet de la partie :
- `nodes`    : tous les nœuds du graphe
- `edges`    : toutes les arêtes
- `dragging` : index du nœud en cours de glissement (ou `nothing`)
- `drag_ox`, `drag_oy` : décalage souris ↔ centre du nœud
  (permet de conserver l'offset initial lors du drag)
"""
mutable struct GameState
    nodes    :: Vector{Node}
    edges    :: Vector{Edge}
    dragging :: Union{Int, Nothing}
    drag_ox  :: Float64
    drag_oy  :: Float64
end

 # état vide, aucun nœud sélectionné.

GameState() = GameState(Node[], Edge[], nothing, 0.0, 0.0)
