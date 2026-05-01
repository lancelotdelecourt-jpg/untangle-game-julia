# ─────────────────────────────────────────────────────────────────────
# render.jl — Dessin du plateau avec Cairo
# ─────────────────────────────────────────────────────────────────────

using Cairo

function render(ctx::CairoContext, state::GameState; radius::Real=R)
    set_source_rgb(ctx, 1.00, 1.00, 1.00) # blanc (fond)
    paint(ctx)

    total, crossing = countcrossings(state)

    draw_edges(ctx, state, crossing)
    draw_nodes(ctx, state, radius)
    draw_hud(ctx, total, state.moves)
end

function draw_edges(ctx::CairoContext, state::GameState, crossing::Vector{Bool})
    for (i, e) in enumerate(state.edges)
        na = state.nodes[e.a]
        nb = state.nodes[e.b]

        move_to(ctx, na.x, na.y)
        line_to(ctx, nb.x, nb.y)

        if crossing[i]
            set_source_rgb(ctx, 0.85, 0.20, 0.20) # rouge (arête qui croise)
            set_line_width(ctx, 2.5)
        else
            set_source_rgb(ctx, 0.10, 0.55, 0.35) # vert (arête libre)
            set_line_width(ctx, 1.8)
        end

        stroke(ctx)
    end
end

function draw_nodes(ctx::CairoContext, state::GameState, R::Real)
    for (i, n) in enumerate(state.nodes)
        arc(ctx, n.x, n.y, R, 0, 2π)

        if i == state.dragging
            set_source_rgb(ctx, 0.33, 0.29, 0.72) # violet (nœud glissé)
        else
            set_source_rgb(ctx, 0.09, 0.37, 0.65) # bleu (nœud normal)
        end

        fill_preserve(ctx)

        set_source_rgb(ctx, 1.00, 1.00, 1.00) # blanc (contour)
        set_line_width(ctx, 2.0)
        stroke(ctx)
    end
end

function draw_hud(ctx::CairoContext, total::Int, moves::Int)
    set_source_rgb(ctx, 0.20, 0.20, 0.20) # gris foncé (texte)
    set_font_size(ctx, 18)

    move_to(ctx, 10, 24)
    if total == 0
        show_text(ctx, "Bravo ! Aucun croisement :)  --  Coups : $moves")
    else
        show_text(ctx, "Croisements : $total  --  Coups : $moves")
    end
end
