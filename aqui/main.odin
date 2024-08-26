package aqui

import "core:fmt"
import SDL "vendor:sdl2"
import SDL_TTF "vendor:sdl2/ttf"

// Types
Vector2 :: [2]i32
fVector2 :: [2]f32
Color :: [4]u8

Control :: struct {
    // basic control structure
    rec,
    pos : Vector2,
    
    h,
    v   : i32
}

Theme :: struct {

    s_font,

    t_border,
    t_button,

    bevel,

    m_edge,
    m_button,
    m_element : i32,

    c_panel,
    c_button,
    c_text,
    c_border,
    c_highlight,
    c_press : Color,

    font : ^SDL_TTF.Font
}

Text :: struct {
    tex : ^SDL.Texture,
    rect : SDL.Rect
}

// Variables
input := struct {
    lmb,        // 0 = not pressed, 1 = down, 2 = pressed, -1 = released
    rmb,
    mmb : i32,

    mpos : Vector2
} {

}

ui_text := map[cstring]Text {}

// Procedures
make_control :: proc(pos, rec : Vector2, theme : ^Theme, parent : ^Control = nil, row : bool = true) -> (ct : Control) {

    ct.pos = pos
    ct.rec = rec

    if parent != nil {
        ct.pos = parent.pos + {
            max(parent.h + pos.x, theme.m_edge),
            max(parent.v + pos.y, theme.m_edge)
        }

        ct.rec.x = min(rec.x, parent.rec.x - (ct.pos.x - parent.pos.x) - theme.m_edge)
        ct.rec.y = min(rec.y, parent.rec.y - (ct.pos.y - parent.pos.y) - theme.m_edge)
    
        if !row {
            parent.h = ct.rec.x + ct.pos.x - parent.pos.x + theme.m_element
        } else {
            parent.v = ct.rec.y + ct.pos.y - parent.pos.y + theme.m_element; parent.h = 0
        }
    }

    return
}

row :: proc(control : ^Control, theme : ^Theme) {

    control.h = 0
    control.v += theme.m_element
}

draw_panel :: proc(panel : ^Control, theme : ^Theme, r : ^SDL.Renderer) {

    rect : SDL.Rect = {
        x = panel.pos.x,
        y = panel.pos.y,
        w = panel.rec.x,
        h = panel.rec.y
    }

    draw_border(rect, theme, r)
    SDL.SetRenderDrawColor(r, theme.c_panel.r, theme.c_panel.g, theme.c_panel.b, theme.c_panel.a)
    render_bevel_rect(r, &rect, theme)
}

draw_border :: proc(rc : SDL.Rect, theme : ^Theme, r : ^SDL.Renderer) {

    if theme.t_border <= 0 do return

    rect := rc
    rect.x -= theme.t_border
    rect.y -= theme.t_border
    rect.w += 2 * theme.t_border
    rect.h += 2 * theme.t_border

    SDL.SetRenderDrawColor(r, theme.c_border.r, theme.c_border.g, theme.c_border.b, theme.c_border.a)
    render_bevel_rect(r, &rect, theme)
}

draw_button :: proc(pos, rec : Vector2, theme : ^Theme, r : ^SDL.Renderer, parent : ^Control = nil, row : bool = true, text : cstring = "", scale : i32 = 1) -> bool {

    has_parent := parent != nil

    rect : SDL.Rect = {
        x = has_parent ? parent.pos.x + max(parent.h + pos.x, theme.m_edge) : pos.x,
        y = has_parent ? parent.pos.y + max(parent.v + pos.y, theme.m_edge) : pos.y
    }
    rect.w = has_parent ? min(rec.x, parent.rec.x - (rect.x - parent.pos.x) - theme.m_edge) : rec.x
    rect.h = has_parent ? min(rec.y, parent.rec.y - (rect.y - parent.pos.y) - theme.m_edge) : rec.y

    if has_parent {
        if !row {
            parent.h = rect.w + rect.x - parent.pos.x + theme.m_element
        } else {
            parent.v = rect.h + rect.y - parent.pos.y + theme.m_element; parent.h = 0
        }
    }

    hovering := input.mpos.x > rect.x && input.mpos.x < rect.x + rect.w && input.mpos.y > rect.y && input.mpos.y < rect.y + rect.h
    
    draw_border(rect, theme, r)

    if hovering && input.lmb == 1 {
        SDL.SetRenderDrawColor(r, theme.c_press.r, theme.c_press.g, theme.c_press.b, theme.c_press.a)
    } else if hovering {
        SDL.SetRenderDrawColor(r, theme.c_highlight.r, theme.c_highlight.g, theme.c_highlight.b, theme.c_highlight.a)
    } else {
        SDL.SetRenderDrawColor(r, theme.c_button.r, theme.c_button.g, theme.c_button.b, theme.c_button.a)
    }
    render_bevel_rect(r, &rect, theme)

    trect := rect
    trect.x += theme.m_button
    trect.y += theme.m_button
    trect.w -= 2 * theme.m_button
    trect.h -= 2 * theme.m_button
    if text != "" do draw_text(text, {rect.x, rect.y}, scale, theme, r, &trect)

    return hovering && input.lmb == 2
}

draw_slider :: proc(val, vmin, vmax : i32, pos, rec : Vector2, theme : ^Theme, r : ^SDL.Renderer, parent : ^Control = nil, row : bool = true) -> i32 {
    
    has_parent := parent != nil

    rect : SDL.Rect = {
        x = has_parent ? parent.pos.x + max(parent.h + pos.x, theme.m_edge) : pos.x,
        y = has_parent ? parent.pos.y + max(parent.v + pos.y, theme.m_edge) : pos.y
    }
    rect.w = has_parent ? min(rec.x, parent.rec.x - (rect.x - parent.pos.x) - theme.m_edge) : rec.x
    rect.h = has_parent ? min(rec.y, parent.rec.y - (rect.y - parent.pos.y) - theme.m_edge) : rec.y

    if has_parent {
        if !row {
            parent.h = rect.w + rect.x - parent.pos.x + theme.m_element
        } else {
            parent.v = rect.h + rect.y - parent.pos.y + theme.m_element; parent.h = 0
        }
    }

    hovering := input.mpos.x > rect.x && input.mpos.x < rect.x + rect.w && input.mpos.y > rect.y && input.mpos.y < rect.y + rect.h
    
    draw_border(rect, theme, r)

    SDL.SetRenderDrawColor(r, theme.c_button.r / 2, theme.c_button.g / 2, theme.c_button.b / 2, theme.c_button.a)
    render_bevel_rect(r, &rect, theme)
    
    slider := rect
    slider.x += theme.m_button
    slider.y += theme.m_button
    slider.w -= 2 * theme.m_button
    slider.h -= 2 * theme.m_button

    p := clamp(f32(val-vmin) / f32(vmax-vmin), 0, 1)
    np := p
    
    if hovering && input.lmb == 1 {
        SDL.SetRenderDrawColor(r, theme.c_press.r, theme.c_press.g, theme.c_press.b, theme.c_press.a)

        np = min(max(f32(input.mpos.x - slider.x), 0) / f32(slider.w), 1)
        p = np
    } else if hovering {
        SDL.SetRenderDrawColor(r, theme.c_highlight.r, theme.c_highlight.g, theme.c_highlight.b, theme.c_highlight.a)
    } else {
        SDL.SetRenderDrawColor(r, theme.c_button.r, theme.c_button.g, theme.c_button.b, theme.c_button.a)
    }
    slider.w = i32(p * f32(slider.w))
    render_bevel_rect(r, &slider, theme)

    return hovering && input.lmb == 1 ? vmin + i32(np * f32(vmax-vmin)) : val
}

draw_area_picker :: proc(hue : f32, val, vmin, vmax, pos, rec : Vector2, theme : ^Theme, r : ^SDL.Renderer, parent : ^Control = nil, row : bool = true) -> Vector2 {
    
    has_parent := parent != nil

    rect : SDL.Rect = {
        x = has_parent ? parent.pos.x + max(parent.h + pos.x, theme.m_edge) : pos.x,
        y = has_parent ? parent.pos.y + max(parent.v + pos.y, theme.m_edge) : pos.y
    }
    rect.w = has_parent ? min(rec.x, parent.rec.x - (rect.x - parent.pos.x) - theme.m_edge) : rec.x
    rect.h = has_parent ? min(rec.y, parent.rec.y - (rect.y - parent.pos.y) - theme.m_edge) : rec.y

    if has_parent {
        if !row {
            parent.h = rect.w + rect.x - parent.pos.x + theme.m_element
        } else {
            parent.v = rect.h + rect.y - parent.pos.y + theme.m_element; parent.h = 0
        }
    }

    hovering := input.mpos.x > rect.x && input.mpos.x < rect.x + rect.w && input.mpos.y > rect.y && input.mpos.y < rect.y + rect.h
    
    draw_border(rect, theme, r)
    
    nrect := rect

    nrect.x += theme.m_button
    nrect.y += theme.m_button
    nrect.w -= 2 * theme.m_button
    nrect.h -= 2 * theme.m_button

    pointer : SDL.Rect = {
        x = nrect.x,
        y = nrect.y,
        w = 10,
        h = 10,
    }
    pcol : Color
    
    p : fVector2
    p.x = clamp(f32(val.x-vmin.x) / f32(vmax.x-vmin.x), 0, 1)
    p.y = clamp(f32(val.y-vmin.y) / f32(vmax.y-vmin.y), 0, 1)
    np := p
    
    if hovering && input.lmb == 1 {
        pcol = theme.c_press

        np.x = min(max(f32(input.mpos.x - nrect.x), 0) / f32(nrect.w), 1)
        np.y = min(max(f32(input.mpos.y - nrect.y), 0) / f32(nrect.h), 1)
        p = np
    } else if hovering {
        pcol = theme.c_highlight
    } else {
        pcol = theme.c_button
    }

    col := hsv_to_rgb(hue, p.x, 1 - p.y)
    SDL.SetRenderDrawColor(r, col.r, col.g, col.b, col.a)
    render_bevel_rect(r, &rect, theme)

    res : Vector2 = {20,10}
    w, h : i32
    w = rect.w / res.x
    h = rect.h / res.y
    for x in 0..<res.x {
        for y in 0..<res.y {
            
            tcol := hsv_to_rgb(hue, f32(x)/f32(res.x - 1), 1 - f32(y)/f32(res.y - 1))
            trec := SDL.Rect {
                x = rect.x + x*w,
                y = rect.y + y*h,
                w = w,
                h = h
            }
            SDL.SetRenderDrawColor(r, tcol.r, tcol.g, tcol.b, tcol.a)
            SDL.RenderFillRect(r, &trec)

        }
    }

    SDL.SetRenderDrawColor(r, pcol.r, pcol.g, pcol.b, pcol.a)
    pointer.x += i32(p.x * f32(nrect.w)) - pointer.w / 2
    pointer.y += i32(p.y * f32(nrect.h)) - pointer.h / 2
    render_bevel_rect(r, &pointer, theme)
    
    val := vmin + {i32(np.x * f32(vmax.x-vmin.x)), i32(np.y * f32(vmax.y-vmin.y))}
    return hovering && input.lmb == 1 ? val : val
}

draw_label :: proc(text : cstring, pos, rec : Vector2, theme : ^Theme, r : ^SDL.Renderer, parent : ^Control = nil, row : bool = true) {

    has_parent := parent != nil

    rect : SDL.Rect = {
        x = has_parent ? parent.pos.x + max(parent.h + pos.x, theme.m_edge) : pos.x,
        y = has_parent ? parent.pos.y + max(parent.v + pos.y, theme.m_edge) : pos.y
    }
    rect.w = has_parent ? min(rec.x, parent.rec.x - (rect.x - parent.pos.x) - theme.m_edge) : rec.x
    rect.h = has_parent ? min(rec.y, parent.rec.y - (rect.y - parent.pos.y) - theme.m_edge) : rec.y

    if has_parent {
        if !row {
            parent.h = rect.w + rect.x - parent.pos.x + theme.m_element
        } else {
            parent.v = rect.h + rect.y - parent.pos.y + theme.m_element; parent.h = 0
        }
    }

    if text != "" do draw_text(text, {rect.x, rect.y}, 1, theme, r, &rect)
}

// INPUT
read_input :: proc(lmb, rmb, mmb : bool) {
    
    // Get Mouse Position
    SDL.GetMouseState(&input.mpos.x, &input.mpos.y)

    // Get Input States
    input_state(lmb, &input.lmb)
    input_state(rmb, &input.rmb)
    input_state(mmb, &input.mmb)
    // if input.rmb != 0 do fmt.println(rmb, input.rmb)

    input_state :: proc(pressed : bool, state : ^i32) {
        if pressed {
            if state^ == 2 do state^ = 1
            if state^ < 1 do state^ = 2
        } else {
            if state^ == -1 do state^ = 0
            if state^ > 0 do state^ = -1
        }
    }
}

create_text :: proc(str : cstring, theme : ^Theme, r : ^SDL.Renderer) -> Text {

    surface := SDL_TTF.RenderText_Solid(theme.font, str, {theme.c_text.r, theme.c_text.g, theme.c_text.b, theme.c_text.a})
    defer SDL.FreeSurface(surface)

    texture := SDL.CreateTextureFromSurface(r, surface)

    dest_rect : SDL.Rect
    SDL_TTF.SizeText(theme.font, str, &dest_rect.w, &dest_rect.h)

    dest_rect.w *= theme.s_font
    dest_rect.h *= theme.s_font

    return {tex = texture, rect = dest_rect}
}

draw_text :: proc(str : cstring, pos : Vector2, scale : i32, theme : ^Theme, r : ^SDL.Renderer, rect : ^SDL.Rect = nil) {

    if !(str in ui_text) {
        ui_text[str] = create_text(str, theme, r)
    }

    text := ui_text[str]
    text.rect.x = pos.x
    text.rect.y = pos.y
    text.rect.w *= scale
    text.rect.h *= pos.y

    SDL.RenderCopy(r, text.tex, nil, rect == nil ? &text.rect : rect)
}

free_textures :: proc() {

    for key in ui_text {
        SDL.DestroyTexture(ui_text[key].tex)
    }
}

render_bevel_rect :: proc(r : ^SDL.Renderer, rect : ^SDL.Rect, theme : ^Theme) {

    if theme.bevel <= 0 {
        SDL.RenderFillRect(r, rect)
        return
    }

    b := theme.bevel
    smallest := min(theme.bevel * 2, rect.w, rect.h)
    if smallest != theme.bevel * 2 do b = smallest / 2

    rects : [2]SDL.Rect
    for i in 0..<2 {
        rects[i].x = i == 0 ? rect.x : rect.x + b
        rects[i].y = i == 1 ? rect.y : rect.y + b
        rects[i].w = i == 0 ? rect.w : rect.w - 2*b
        rects[i].h = i == 1 ? rect.h : rect.h - 2*b
    }

    ra : [^]SDL.Rect = raw_data(rects[:])

    SDL.RenderFillRects(r, ra, 2)

}