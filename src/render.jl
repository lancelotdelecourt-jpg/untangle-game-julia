# ─────────────────────────────────────────────────────────────────────
# render.jl — Dessin du plateau avec Cairo
# ─────────────────────────────────────────────────────────────────────

using Cairo

# Palette de couleurs (RGB 0..1)
const COLOR_BG          = (1.00, 1.00, 1.00)   # blanc (fond)
const COLOR_EDGE_OK     = (0.10, 0.55, 0.35)   # vert  (arête libre)
const COLOR_EDGE_CROSS  = (0.85, 0.20, 0.20)   # rouge (arête qui croise)
const COLOR_NODE        = (0.09, 0.37, 0.65)   # bleu  (nœud normal)
const COLOR_NODE_ACTIVE = (0.33, 0.29, 0.72)   # violet (nœud glissé)
const COLOR_TEXT        = (0.20, 0.20, 0.20)   # gris foncé (texte)

"""
    render(ctx, state; radius)

Dessine l'état complet du jeu sur le contexte Cairo :
- fond blanc
- arêtes (vertes si OK, rouges si croisées)
- nœuds (bleus, violet si sélectionné)
- compteur de croisements en haut à gauche
"""
function render(ctx::CairoContext, state::GameState; radius::Real = 14)
  

"""
    draw_edges!(ctx, state, crossing)

Trace toutes les arêtes, coloriées selon leur état de croisement.
"""
function draw_edges!(ctx::CairoContext, state::GameState, crossing::BitVector)
   
"""
    draw_nodes!(ctx, state, radius)

Dessine tous les nœuds sous forme de disques avec un contour blanc.
Le nœud en cours de drag est mis en évidence (violet).
"""
function draw_nodes!(ctx::CairoContext, state::GameState, radius::Real)
   
"""
    draw_hud!(ctx, total)

Affiche le compteur de croisements (ou un message de victoire) en
haut à gauche de la fenêtre.
"""
function draw_hud!(ctx::CairoContext, total::Int)
    set_source_rgb(ctx, COLOR_TEXT...)
   
end
