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

function render(ctx::CairoContext, state::GameState; radius::Real=R)
    set_source_rgb(ctx, 1, 1, 1) # crée le fond blanc, set_source_rgb est une fonction Cairo et (1,1,1) correspond au blanc en RGB
    paint(ctx) # on peint le canva

    total, crossing = countcrossings(state)

    draw_edges(ctx, state, crossing)
    draw_nodes(ctx, state, radius)
    draw_hud(ctx, total)
end

function draw_edges(ctx::CairoContext, state::GameState, crossing::Vector{Bool})
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