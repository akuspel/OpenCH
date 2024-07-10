package main

import "core:os"
import "core:fmt"
import "core:time"
import "core:strconv"
import "core:strings"

import win "core:sys/windows"

import SDL "vendor:sdl2"
import SDL_TTF "vendor:sdl2/ttf"

import "shared:ini"
import "aqui"


// Types
CrossHair :: struct {

    wings       :   [4]bool, // [up, down, left, right]
    center_dot  :   bool,

    w_length,
    b_thickness,
    thickness,
    gap         :   i32,

    color       :   [4]u8,
    b_color     :   [4]u8

}

// Variables
state := struct {
    options,
    paused : bool,

    lmb,
    rmb,
    mmb,
    
    shift,
    alt,
    ctrl : bool
} {
    paused = false,
    options = false
}

crosshairs : [9]string = {
    "crosshairs/default.ini",
    "crosshairs/aleksib.ini",
    "crosshairs/jl.ini",
    "crosshairs/xertion.ini",
    "crosshairs/device.ini",
    "crosshairs/donk.ini",
    "crosshairs/tree.ini",
    "crosshairs/wings.ini",
    "crosshairs/dot.ini",
}

update : bool = true

// Procedures
main :: proc() {

    // params
    get_crosshairs(context.temp_allocator)
    ch := read_ch(crosshairs[0])
    disp : [2]i32 = {win.GetSystemMetrics(win.SM_CXSCREEN), win.GetSystemMetrics(win.SM_CYSCREEN)}

    // launch SDL window
	window := SDL.CreateWindow("OpenCH", SDL.WINDOWPOS_UNDEFINED, SDL.WINDOWPOS_UNDEFINED, disp.x, disp.y, {.OPENGL, .ALWAYS_ON_TOP, .BORDERLESS})
	if window == nil {
		fmt.eprintln("Failed to create window")
		return
	}
	defer SDL.DestroyWindow(window)

    SDL.Init({})
    SDL_TTF.Init()
    r := SDL.CreateRenderer(window, 0, {.ACCELERATED})
	
    // GUI
    theme := aqui.Theme {

        s_font = 1,
        
        t_border = 2,
        t_button = 30,

        m_edge = 10,
        m_button = 3,
        m_element = 10,

        c_panel = {70, 80, 100, 255},
        c_button = {20, 50, 100, 255},
        c_highlight = {30, 100, 150, 255},
        c_press = {10, 40, 50, 255},
        c_border = {0,20,50,255},
        c_text = {200,200,255,255},

        font = SDL_TTF.OpenFont("res/fonts/Rubik-Regular.ttf", 64)
    }

    // Load UI Texts
    defer aqui.free_textures()	
	start_tick := time.tick_now()
	loop: for {
		duration := time.tick_since(start_tick)
		t := f32(time.duration_seconds(duration))
		
		// event polling
		event: SDL.Event
		for SDL.PollEvent(&event) != false {
			// #partial switch tells the compiler not to error if every case is not present
			#partial switch event.type {
			case .KEYDOWN:
				#partial switch event.key.keysym.sym {
				case .ESCAPE:
                    // labelled control flow
                    state.paused = !state.paused
                    state.options = false
                    update = true
                case .F1:
					// labelled control flow
					ch = read_ch(crosshairs[0])
                case .F2:
					// labelled control flow
					ch = read_ch(crosshairs[1])
                case .F3:
					// labelled control flow
					ch = read_ch(crosshairs[2])
                case .F4:
					// labelled control flow
					ch = read_ch(crosshairs[3])
                case .F5:
					// labelled control flow
					ch = read_ch(crosshairs[4])
                case .F6:
					// labelled control flow
					ch = read_ch(crosshairs[5])
                case .F7:
					// labelled control flow
					ch = read_ch(crosshairs[6])
                case .F8:
					// labelled control flow
					ch = read_ch(crosshairs[7])
                case .F9:
					// labelled control flow
					ch = read_ch(crosshairs[8])
                case .F12:
					// labelled control flow
					state.options = !state.options
                    state.paused = false
                    update = true

                case .LSHIFT:
                    // labelled control flow
                    state.shift = true
                case .LALT:
                    // labelled control flow
                    state.alt = true
                case .LCTRL:
                    // labelled control flow
                    state.ctrl = true
				}
            case .KEYUP:
                #partial switch event.key.keysym.sym {

                case .LSHIFT:
                    // labelled control flow
                    state.shift = false
                case .LALT:
                    // labelled control flow
                    state.alt = false
                case .LCTRL:
                    // labelled control flow
                    state.ctrl = false
                }
			case .QUIT:
				// labelled control flow
				break loop
            case .MOUSEWHEEL:

                if state.ctrl || state.alt || state.shift do update = true
                if !state.paused {
                    
                    if !state.ctrl && !state.alt && !state.shift do ch.w_length += event.wheel.y
                    if state.ctrl do ch.thickness += event.wheel.y
                    if state.alt do ch.gap += event.wheel.y
                    if state.shift do ch.b_thickness += event.wheel.y

                } else {

                    if state.ctrl do ch.color.r = u8(i32(ch.color.r) + event.wheel.y * 20)
                    if state.shift do ch.color.g = u8(i32(ch.color.g) + event.wheel.y * 20)
                    if state.alt do ch.color.b = u8(i32(ch.color.b) + event.wheel.y * 20)

                }
            case .MOUSEBUTTONDOWN:
                if event.button.button == SDL.BUTTON_LEFT do state.lmb = true
                if event.button.button == SDL.BUTTON_RIGHT do state.rmb = true
                if event.button.button == SDL.BUTTON_MIDDLE do state.mmb = true

            case .MOUSEBUTTONUP:
                if event.button.button == SDL.BUTTON_LEFT do state.lmb = false
                if event.button.button == SDL.BUTTON_RIGHT do state.rmb = false
                if event.button.button == SDL.BUTTON_MIDDLE do state.mmb = false

			}
		}

        aqui.read_input(state.lmb, state.rmb, state.mmb)

        // only update when necessary
        if update || state.options {
            update = false

            SDL.SetRenderDrawColor(r, 255, 0, 255, 255)
            SDL.RenderClear(r)
            if !state.paused {
                draw_ch(ch, disp, r)

                if state.options do draw_ui(&theme, &ch, r)
            } else {
                draw_paused(ch, r)
            }
            
            MakeWindowTransparent(window, win.RGB(255, 0, 255))
            SDL.RenderPresent(r)
        }
	}
}

MakeWindowTransparent :: proc(window : ^SDL.Window, colorKey : win.COLORREF) -> bool {
    // Get window handle (https://stackoverflow.com/a/24118145/3357935)
    wmInfo : SDL.SysWMinfo
    SDL.GetWindowWMInfo(window, &wmInfo)
    hWnd : win.HWND = win.HWND(wmInfo.info.win.window)

    // Change window type to layered (https://stackoverflow.com/a/3970218/3357935)
    if !state.paused && !state.options {
        win.SetWindowLongW(hWnd, win.GWL_EXSTYLE, win.GetWindowLongW(hWnd, win.GWL_EXSTYLE) | i32(win.WS_EX_LAYERED) | i32(win.WS_EX_TRANSPARENT))
    } else {
        win.SetWindowLongW(hWnd, win.GWL_EXSTYLE, win.GetWindowLongW(hWnd, win.GWL_EXSTYLE) &~ i32(win.WS_EX_TRANSPARENT))
    }

    // Set transparency color
    return bool(win.SetLayeredWindowAttributes(hWnd, colorKey, 0, 0x00000001))
}

draw_ui :: proc(theme : ^aqui.Theme, ch : ^CrossHair, r : ^SDL.Renderer) {

    // Draw Main Panel
    main_panel := aqui.make_control({100, 100}, {300, 560}, theme)
    aqui.draw_panel(&main_panel, theme, r)

    aqui.draw_label("Presets", {}, {60, 15}, theme, r, &main_panel, false)
    // Draw Close Button
    redtheme := theme^
    redtheme.c_button={200,10,10,255}
    redtheme.c_highlight={255,100,100,255}
    redtheme.c_press={200,10,10,255}
    
    // Draw Preset Buttons
    if aqui.draw_button({195, 0}, {15, 15}, &redtheme, r, &main_panel, text = "X") do state.options = false; update = true

    button_texts : [9]cstring = {"1", "2", "3", "4", "5", "6", "7", "8", "9"}
    for i in 0..<9 {
        if aqui.draw_button({}, {22, 30}, theme, r, &main_panel, i == 8, button_texts[i]) do ch^ = read_ch(crosshairs[i])
    }

    // Draw Save Button
    if aqui.draw_button({}, {100, 20}, theme, r, &main_panel, text = "Save Crosshair") do write_config(ch)

    // Draw Settings Panel
    settings_panel := aqui.make_control({}, {300, 450}, theme, &main_panel)
    aqui.draw_panel(&settings_panel, theme, r)
    aqui.draw_label("Settings", {}, {80, 15}, theme, r, &settings_panel)

    subpanel := theme^
    subpanel.c_border = {240, 200, 200, 255}
    size_panel := aqui.make_control({}, {140, 130}, theme, &settings_panel, false)
    part_panel := aqui.make_control({}, {140, 130}, theme, &settings_panel, true)
    aqui.draw_panel(&size_panel, &subpanel, r)
    aqui.draw_panel(&part_panel, &subpanel, r)

    // Size Panel
    aqui.draw_label("Length", {}, {40, 15}, theme, r, &size_panel, false)
    if aqui.draw_button({20, 0}, {15, 20}, theme, r, &size_panel, false, "+") do ch.w_length += 1
    if aqui.draw_button({}, {15, 20}, theme, r, &size_panel, true, "-") do ch.w_length -= 1

    aqui.draw_label("Thickness", {}, {60, 15}, theme, r, &size_panel, false)
    if aqui.draw_button({}, {15, 20}, theme, r, &size_panel, false, "+") do ch.thickness += 1
    if aqui.draw_button({}, {15, 20}, theme, r, &size_panel, true, "-") do ch.thickness -= 1
    
    aqui.draw_label("Gap", {}, {20, 15}, theme, r, &size_panel, false)
    if aqui.draw_button({40, 0}, {15, 20}, theme, r, &size_panel, false, "+") do ch.gap += 1
    if aqui.draw_button({}, {15, 20}, theme, r, &size_panel, true, "-") do ch.gap -= 1
    
    aqui.draw_label("Border", {}, {40, 15}, theme, r, &size_panel, false)
    if aqui.draw_button({20, 0}, {15, 20}, theme, r, &size_panel, false, "+") do ch.b_thickness += 1
    if aqui.draw_button({}, {15, 20}, theme, r, &size_panel, true, "-") do ch.b_thickness -= 1

    // Part Panel
    aqui.draw_label("Wings", {}, {40, 15}, theme, r, &part_panel)
    wings : [4]cstring = {"T", "B", "L", "R"}
    for i in 0..<4 {
        if aqui.draw_button({}, {15, 20}, theme, r, &part_panel, i == 3, wings[i]) do ch.wings[i] = !ch.wings[i]
    }
    if aqui.draw_button({}, {100, 25}, theme, r, &part_panel, true, "Center Dot") do ch.center_dot = !ch.center_dot

    // Color Panel
    color_panel := aqui.make_control({}, {300, 260}, theme, &settings_panel, true)
    aqui.draw_panel(&color_panel, &subpanel, r)
    
    aqui.draw_label("Crosshair Color", {}, {100, 15}, theme, r, &color_panel)
    rgb : [3]cstring = {"R", "G", "B"}
    for i in 0..<3 {
        aqui.draw_label(rgb[i], {}, {10, 20}, theme, r, &color_panel, false)
        if aqui.draw_button({}, {30, 20}, theme, r, &color_panel, false, "255") do ch.color[i] = 255
        if aqui.draw_button({}, {15, 20}, theme, r, &color_panel, false, "+") do ch.color[i] += 15
        if aqui.draw_button({}, {15, 20}, theme, r, &color_panel, false, "-") do ch.color[i] -= 15
        if aqui.draw_button({}, {15, 20}, theme, r, &color_panel, true, "0") do ch.color[i] = 0
    }

    aqui.draw_label("Border Color", {0, 20}, {80, 15}, theme, r, &color_panel)
    for i in 0..<3 {
        aqui.draw_label(rgb[i], {}, {10, 20}, theme, r, &color_panel, false)
        if aqui.draw_button({}, {30, 20}, theme, r, &color_panel, false, "255") do ch.b_color[i] = 255
        if aqui.draw_button({}, {15, 20}, theme, r, &color_panel, false, "+") do ch.b_color[i] += 15
        if aqui.draw_button({}, {15, 20}, theme, r, &color_panel, false, "-") do ch.b_color[i] -= 15
        if aqui.draw_button({}, {15, 20}, theme, r, &color_panel, true, "0") do ch.b_color[i] = 0
    }

}

draw_ch :: proc(ch : CrossHair, disp : [2]i32, renderer : ^SDL.Renderer) {

    // loop through wings
    for wing, i in ch.wings {
        if !wing do continue

        rect : SDL.Rect
        g_mod := ch.gap % 2
        t_mod := ch.thickness % 2

        switch i {
        case 0:
            rect.x = disp.x / 2 - ch.thickness / 2
            rect.y = disp.y / 2 - (ch.gap / 2 + ch.w_length)
            rect.w = ch.thickness
            rect.h = ch.w_length
        
        case 1:
            rect.x = disp.x / 2 - ch.thickness / 2
            rect.y = disp.y / 2 + ch.gap / 2 + t_mod
            rect.w = ch.thickness
            rect.h = ch.w_length
        
        case 2:
            rect.x = disp.x / 2 - (ch.gap / 2 + ch.w_length)
            rect.y = disp.y / 2 - ch.thickness / 2
            rect.w = ch.w_length
            rect.h = ch.thickness
        
        case 3:
            rect.x = disp.x / 2 + ch.gap / 2 + t_mod
            rect.y = disp.y / 2 - ch.thickness / 2
            rect.w = ch.w_length
            rect.h = ch.thickness
        }
        
        draw_border(rect, ch, renderer)
        SDL.SetRenderDrawColor(renderer, ch.color.r, ch.color.g, ch.color.b, ch.color.a)
        SDL.RenderFillRect(renderer, &rect)
    }

    // draw center dot
    if ch.center_dot {

        rect : SDL.Rect
        
        rect.x = disp.x / 2 - ch.thickness / 2
        rect.y = disp.y / 2 - ch.thickness / 2
        rect.w = ch.thickness
        rect.h = ch.thickness

        draw_border(rect, ch, renderer)
        SDL.SetRenderDrawColor(renderer, ch.color.r, ch.color.g, ch.color.b, ch.color.a)
        SDL.RenderFillRect(renderer, &rect)
    }
    
}

draw_border :: proc(rc : SDL.Rect, ch : CrossHair, renderer : ^SDL.Renderer) {

    if ch.b_thickness <= 0 do return

    rect := rc
    rect.x -= ch.b_thickness / 2
    rect.y -= ch.b_thickness / 2
    rect.w += ch.b_thickness
    rect.h += ch.b_thickness

    SDL.SetRenderDrawColor(renderer, ch.b_color.r, ch.b_color.g, ch.b_color.b, ch.b_color.a)
    SDL.RenderFillRect(renderer, &rect)
}

draw_paused :: proc(ch : CrossHair, renderer : ^SDL.Renderer) {

    rect := SDL.Rect {
        x = 10,
        y = 10,
        w = 5,
        h = 5
    }

    draw_border(rect, ch, renderer)
    SDL.SetRenderDrawColor(renderer, ch.color.r, ch.color.g, ch.color.b, ch.color.a)
    SDL.RenderFillRect(renderer, &rect)
}

get_crosshairs :: proc(alloc := context.allocator) {
    
    bytes, ok := os.read_entire_file_from_filename("crosshairs/init.txt")
    if !ok do return

    defer delete(bytes)

    keys := strings.split(string(bytes), "\r\n", context.temp_allocator)
    for i,x := 0,0; (i-x) < min(len(keys), 9); i += 1 {
        ch := keys[i]
        if len(ch) < 2 do return

        // skip comments
        if ch[0:2] == "//" {
            x += 1
            continue
        }
        
        // copy path to crosshairs
        if len(ch) > 4 do crosshairs[i - x] = strings.clone(ch, alloc)
    }
}

read_ch :: proc(path : string = "crosshairs/default.ini") -> (ch : CrossHair) {

    update = true

    ch = CrossHair {

        wings       = {true, true, true, true},
        center_dot  = true,

        w_length    = 6,
        thickness   = 2,
        b_thickness = 1,
        gap         = 6,

        color       = {100, 255, 0, 100},
        b_color     = {0, 0, 0, 255}

    }

    config, ok := get_config(path).?
    if !ok {
        return
    }
    defer ini.ini_delete(&config)

    if "features" in config {
        obj := config["features"]

        if "wings" in obj {
            for w, i in strings.split(obj["wings"], ",", context.temp_allocator) {
                if v, ok := strconv.parse_bool(w); i < 4 && ok do ch.wings[i] = v
            }
        }

        if "center_dot" in obj {
            if v, ok := strconv.parse_bool(obj["center_dot"]); ok do ch.center_dot = v
        }
    }

    if "values" in config {
        obj := config["values"]

        if "w_length" in obj {
            if v, ok := strconv.parse_i64(obj["w_length"]); ok do ch.w_length = i32(v)
        }
        if "thickness" in obj {
            if v, ok := strconv.parse_i64(obj["thickness"]); ok do ch.thickness = i32(v)
        }
        if "b_thickness" in obj {
            if v, ok := strconv.parse_i64(obj["b_thickness"]); ok do ch.b_thickness = i32(v)
        }
        if "gap" in obj {
            if v, ok := strconv.parse_i64(obj["gap"]); ok do ch.gap = i32(v)
        }
    }

    if "colors" in config {
        obj := config["colors"]

        if "color" in obj {
            for w, i in strings.split(obj["color"], ",", context.temp_allocator) {
                if v, ok := strconv.parse_i64(w); i < 4 && ok do ch.color[i] = u8(v)
            }
        }

        if "b_color" in obj {
            for w, i in strings.split(obj["b_color"], ",", context.temp_allocator) {
                if v, ok := strconv.parse_i64(w); i < 4 && ok do ch.b_color[i] = u8(v)
            }
        }
    }
    
    return

}

get_config :: proc(config_file_path: string) -> Maybe(ini.INI) {
	bytes, ok := os.read_entire_file_from_filename(config_file_path)
	if !ok {
		fmt.printf("[ERROR]: could not read %q\n", config_file_path)
		return nil
	}
	defer delete(bytes)

	config, res := ini.parse(bytes)
    using res.pos
    switch res.err {
        case .EOF:              return config
        case .IllegalToken:     fmt.printf("[ERROR]: Illegal token encountered in %q at %d:%d", config_file_path, line+1, col+1)
        case .KeyWithoutEquals: fmt.printf("[ERROR]: Key token found, but not assigned in %q at %d:%d", config_file_path, line+1, col+1)
        case .ValueWithoutKey:  fmt.printf("[ERROR]: Value token found, but not preceeded by a key token in %q at %d:%d", config_file_path, line+1, col+1)
        case .UnexpectedEquals: fmt.printf("[ERROR]: Equals sign found in an unexpected location in %q at %d:%d", config_file_path, line+1, col+1)
    }

    return nil
}

write_config :: proc(ch : ^CrossHair) {

    // Compose .ini string

    /*
    [features]
    wings = 1,1,1,1
    center_dot = 0

    [values]
    w_length = 3
    thickness = 2
    b_thickness = 0.5
    gap = 6

    [colors]
    color = "150,255,30,255"
    b_color = "0,0,0,255"
    */
    
    // Conversion Vars
    buf1 : [32]byte
    buf2 : [32]byte
    buf3 : [32]byte
    buf4 : [32]byte
    frmt := u8('f')
    bit_size := 64

    text : string = "[features]\nwings = "
    for b, i in ch.wings {
        if i < 3 do text = strings.concatenate({text, b ? "1," : "0,"}, context.temp_allocator)
        if i == 3 do text = strings.concatenate({text, b ? "1" : "0", "\ncenter_dot = "}, context.temp_allocator)
    }
    text = strings.concatenate(
        {
            text,
            ch.center_dot ? "1\n\n" : "0\n\n",
            "[values]\nw_length = ",
            string(strconv.ftoa(buf1[:], f64(ch.w_length), frmt, 0, bit_size)),
            "\nthickness = ",
            string(strconv.ftoa(buf2[:], f64(ch.thickness), frmt, 0, bit_size)),
            "\nb_thickness = ",
            string(strconv.ftoa(buf3[:], f64(ch.b_thickness), frmt, 0, bit_size)),
            "\ngap = ",
            string(strconv.ftoa(buf4[:], f64(ch.gap), frmt, 0, bit_size)),
            "\n\n[colors]\ncolor = \""
        },
        context.temp_allocator
    )
    for v, i in ch.color {
        if i < 3 do text = strings.concatenate({text, string(strconv.ftoa(buf4[:], f64(v), frmt, 0, bit_size)), ","}, context.temp_allocator)
        if i == 3 do text = strings.concatenate({text, string(strconv.ftoa(buf4[:], f64(v), frmt, 0, bit_size)), "\"\nb_color = \""}, context.temp_allocator)
    }
    for v, i in ch.b_color {
        if i < 3 do text = strings.concatenate({text, string(strconv.ftoa(buf4[:], f64(v), frmt, 0, bit_size)), ","}, context.temp_allocator)
        if i == 3 do text = strings.concatenate({text, string(strconv.ftoa(buf4[:], f64(v), frmt, 0, bit_size)), "\""}, context.temp_allocator)
    }

    text, _ = strings.replace(text, "+", "", -1, context.temp_allocator)

    fmt.println("Generated default.ini:\n----------")
    fmt.println(text)
    fmt.println("----------")

    os.write_entire_file("crosshairs/default.ini", transmute([]u8)text)
}

// GetCounterStrikeHwnd :: proc() -> (hWnd: win.HWND) {
//     EnumWindowsProc :: proc "system" (hwnd: win.HWND, lParam: win.LPARAM) -> win.BOOL {
//         context = (^runtime.Context)(uintptr(lParam))^

//         buffer: [128]win.WCHAR
//         written := win.GetWindowTextW(hwnd, &buffer[0], 128)
//         text := win.wstring_to_utf8(&buffer[0], int(written)) or_else ""
//         if strings.contains(text, "Counter-Strike") {
//             fmt.println("yesss!!!", hwnd)
//             (^win.HWND)(context.user_ptr)^ = hwnd
//             return false
//         }

//         return true
//     }

//     context.user_ptr = &hWnd
//     ctx := context
//     win.EnumWindows(EnumWindowsProc, win.LPARAM(uintptr(rawptr(&ctx))))
//     return
// }

enable_mouse_input :: proc(hwnd : win.HWND, enable : bool) {

    MouseCallback :: proc "stdcall" (hwnd : win.HWND, uMsg : u32, wParam : win.WPARAM, lParam : win.LPARAM, uIdSubclass : u32, )

}