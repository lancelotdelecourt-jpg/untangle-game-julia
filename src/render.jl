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
    # Fond
    set_source_rgb(ctx, COLOR_BG...)
    paint(ctx)

    # Pré-calcul : quelles arêtes participent à un croisement ?
    total, crossing = count_crossings(state)

    draw_edges!(ctx, state, crossing)
    draw_nodes!(ctx, state, radius)
    draw_hud!(ctx, total)
end

"""
    draw_edges!(ctx, state, crossing)

Trace toutes les arêtes, coloriées selon leur état de croisement.
"""
function draw_edges!(ctx::CairoContext, state::GameState, crossing::BitVector)
    for (i, e) in enumerate(state.edges)
        na, nb = state.nodes[e.a], state.nodes[e.b]
        move_to(ctx, na.x, na.y)
        line_to(ctx, nb.x, nb.y)

        if crossing[i]
            set_source_rgb(ctx, COLOR_EDGE_CROSS...)
            set_line_width(ctx, 2.5)
        else
            set_source_rgb(ctx, COLOR_EDGE_OK...)
            set_line_width(ctx, 1.8)
        end
        stroke(ctx)
    end
end

"""
    draw_nodes!(ctx, state, radius)

Dessine tous les nœuds sous forme de disques avec un contour blanc.
Le nœud en cours de drag est mis en évidence (violet).
"""
function draw_nodes!(ctx::CairoContext, state::GameState, radius::Real)
    for (i, n) in enumerate(state.nodes)
        arc(ctx, n.x, n.y, radius, 0, 2π)

        # Remplissage
        if state.dragging == i
            set_source_rgb(ctx, COLOR_NODE_ACTIVE...)
        else
            set_source_rgb(ctx, COLOR_NODE...)
        end
        fill_preserve(ctx)   # conserve le chemin pour le contour

        # Contour blanc
        set_source_rgb(ctx, 1, 1, 1)
        set_line_width(ctx, 2)
        stroke(ctx)
    end
end

"""
    draw_hud!(ctx, total)

Affiche le compteur de croisements (ou un message de victoire) en
haut à gauche de la fenêtre.
"""
function draw_hud!(ctx::CairoContext, total::Int)
    set_source_rgb(ctx, COLOR_TEXT...)
    select_font_face(ctx, "Sans",
                     Cairo.FONT_SLANT_NORMAL,
                     Cairo.FONT_WEIGHT_NORMAL)
    set_font_size(ctx, 16)
    move_to(ctx, 10, 24)

    message = total == 0 ? "Bravo ! Aucun croisement !" :
                           "Croisements : $total"
    show_text(ctx, message)
end
