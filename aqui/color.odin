package aqui

import "core:math"

// Procedures
hsv_to_rgb :: proc(h, s, v : f32) -> (col : Color) {

    hue := h / 360
    sat := s / 100
    val := v / 100

    i := i32(h * 6)
    f := h * 6 - f32(i)
    p := v * (1 - s)
    q := v * (1 - f * s)
    t := v * (1 - (1 - f) * s)

    switch i % 6 {
    case 0:
        col = fcol_to_ucol(v, t, p)
    case 1:
        col = fcol_to_ucol(q, v, p)
    case 2:
        col = fcol_to_ucol(p, v, t)
    case 3:
        col = fcol_to_ucol(p, q, v)
    case 4:
        col = fcol_to_ucol(t, p, v)
    case 5:
        col = fcol_to_ucol(v, p, q)
    }

    return
}

rgb_to_hsv :: proc(col : Color) -> (h, s, v : f32) {

    r := f32(col.r) / 255
    g := f32(col.g) / 255
    b := f32(col.b) / 255

    cmax := max(r, g, b)
    cmin := min(r, g, b)
    d := cmax - cmin
    
    // Value
    v = cmax

    if d == 0 do return

    // Hue
    rc := (cmax-r) / d
    gc := (cmax-g) / d
    bc := (cmax-b) / d

    h = cmax == r ? 0 + bc-gc : (
        cmax == g ? 2 + rc-bc : 4 + gc-rc
    )
    h = math.mod_f32(h/6, 1)

    // Saturation
    s = d/cmax

    return
}

fcol_to_ucol :: proc(r, g, b : f32, a : f32 = 1) -> Color {

    return Color {
        u8(r * 255),
        u8(g * 255),
        u8(b * 255),
        u8(a * 255)
    }
}