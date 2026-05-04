#Requires AutoHotkey v2.0

#Include utils.ahk
#Include timers.ahk

_cfg(cfg, name, default) {
    if !IsObject(cfg)
        return default
    if (cfg is Map)
        return cfg.Has(name) ? cfg[name] : default
    if (cfg.HasOwnProp(name))
        return cfg.%name%
    return default
}

_fmtColor(c) {
    return (c is Number) ? Format("{:06X}", c) : c
}

_vec(params*) {
    if (params.Length == 1)
        return params[1]
    if (params.Length == 2)
        return Vector(params[1], params[2])
    return Vector(0, 0)
}

ArraysEqual(arr1, arr2) {
    if !(arr1 is Array) || !(arr2 is Array)
        return false
    if (arr1.Length != arr2.Length)
        return false
    for idx, val in arr1 {
        other := arr2[idx]
        if (IsObject(val) && IsObject(other)) {
            if (!ArraysEqual(val, other))
                return false
        } else if (val != other) {
            return false
        }
    }
    return true
}

class Vector {
    __New(vec_x, vec_y) {
        this.x := vec_x
        this.y := vec_y
    }

    add(params*) {
        v := _vec(params*)
        return Vector(this.x + v.x, this.y + v.y)
    }

    sub(other) {
        return Vector(this.x - other.x, this.y - other.y)
    }

    swap() {
        return Vector(this.y, this.x)
    }
}

_build_side_outline(name, vec_pos, vec_size, sides, bold, border, color, alpha) {
    ol_r := sides[1], ol_l := sides[3]
    size_w := vec_size.x
    size_h := vec_size.y
    border2 := border * 2
    ol_sum := ol_r + ol_l
    ol_cond := ol_sum = 2 ? 0 : (ol_sum = 0 ? border2 : border)

    layout := [
        [vec_pos.add(-bold, -border), Vector(bold, size_h + border2)],
        [vec_pos.add(-bold + (ol_r ? 0 : bold - border), -bold), Vector(size_w + bold * ol_sum + ol_cond, bold)],
        [vec_pos.add(size_w, -border), Vector(bold, size_h + border2)],
        [vec_pos.add(-bold + (ol_r ? 0 : bold - border), size_h), Vector(size_w + bold * ol_sum + ol_cond, bold)]
    ]

    elements := []
    for i, val in sides
        if (val)
            elements.Push(Line(name "_ol_" A_Index, layout[i][1], layout[i][2], {color: color, alpha: alpha}))
    return elements
}

_build_corner_outline(name, vec_pos, vec_size, bold, len, color, alpha) {
    size_w := vec_size.x
    size_h := vec_size.y

    layout := [
        [vec_pos.add(-bold, 0), Vector(bold, len)],
        [vec_pos.add(-bold, size_h - len), Vector(bold, len)],
        [vec_pos.add(-bold, -bold), Vector(len + bold, bold)],
        [vec_pos.add(size_w - len, -bold), Vector(len + bold, bold)],
        [vec_pos.add(size_w, 0), Vector(bold, len)],
        [vec_pos.add(size_w, size_h - len), Vector(bold, len)],
        [vec_pos.add(-bold, size_h), Vector(len + bold, bold)],
        [vec_pos.add(size_w - len, size_h), Vector(len + bold, bold)]
    ]

    elements := []
    for i, val in layout
        elements.Push(Line(name "_ol_" A_Index, layout[i][1], layout[i][2], {color: color, alpha: alpha}))
    return elements
}

class Text {
    __New(name, vec_pos, vec_size, theme, Config := unset) {
        cfg := IsSet(Config) ? Config : ""

        this.name := "txt_" name
        this.pos := vec_pos
        this.size := vec_size
        this.theme := theme
        this.controls := Map()

        this.mtl := _cfg(cfg, "margin", 2)
        this.mbr := this.mtl + this.mtl

        this.gui := Gui("+AlwaysOnTop -Caption +LastFound -SysMenu +ToolWindow -DPIScale +E0x20")
        this.gui.MarginX := 0
        this.gui.MarginY := 0
        this.gui.BackColor := "000000"
        WinSetTransColor("000000", this.gui.Hwnd)
    }

    new_text(control_name, body, prop, category, Config := unset) {
        cfg := IsSet(Config) ? Config : ""
        fit_x := _cfg(cfg, "fit_x", 0)
        fit_y := _cfg(cfg, "fit_y", 0)

        category := StrLower(category)
        prop := StrLower(Trim(prop))

        if (prop = "" || prop = "auto")
            prop := "center xs ym0"
        else if (prop = "left")
            prop := "left xs ym0"
        else if (prop = "right")
            prop := "right xs ym0"
        else if (RegExMatch(prop, "auto"))
            prop := RegExReplace(prop, "auto", "center")
        else if (!RegExMatch(prop, "(\+?center|\+?left|\+?right)"))
            prop := "center " prop

        fontName := this.theme.%category%
        fontSize := this.theme.%category "SZ"%
        fontColor := this.theme.%category "Col"%

        this.gui.SetFont("s" fontSize " q5", fontName)
        ctl := this.gui.Add("Text", prop " w" (this.size.x - this.mbr) " BackgroundTrans 0x200 c" fontColor, body)

        this.controls[control_name] := Map(
            "control", ctl,
            "body",    body,
            "font",    fontName,
            "fontSZ",  fontSize,
            "fontCol", fontColor,
            "fit_x",   fit_x,
            "fit_y",   fit_y
        )
    }

    edit_text(control_name, new_text) {
        cobj := this.controls[control_name]
        cobj["control"].Text := new_text
        cobj["body"] := new_text
    }

    edit_color(control_name, new_color) {
        cobj := this.controls[control_name]
        cobj["control"].SetFont("c" new_color)
        cobj["fontCol"] := new_color
    }

    get_size(control_name) {
        cobj := this.controls[control_name]
        cobj["control"].GetPos(, , &w, &h)
        return [w, h]
    }

    get_control(name) {
        return this.controls[name]
    }

    get_controls() {
        return this.controls
    }

    measure(control_name) {
        cobj := this.controls[control_name]
        textBody := cobj["body"]
        fontName := cobj["font"]
        fontSize := "s" cobj["fontSZ"]

        static DT_FLAGS := 0x0520
        static WM_GETFONT := 0x31

        tmp := Gui()
        if (fontSize != "" || fontName != "")
            tmp.SetFont(fontSize, fontName)
        h := tmp.Add("Text")
        HFONT := SendMessage(WM_GETFONT, 0, 0, h.Hwnd)
        HDC := DllCall("User32.dll\GetDC", "Ptr", h.Hwnd, "Ptr")
        DllCall("Gdi32.dll\SelectObject", "Ptr", HDC, "Ptr", HFONT)
        rect := Buffer(16, 0)
        DllCall("User32.dll\DrawText", "Ptr", HDC, "Str", textBody, "Int", -1, "Ptr", rect, "UInt", DT_FLAGS)
        DllCall("User32.dll\ReleaseDC", "Ptr", h.Hwnd, "Ptr", HDC)
        tmp.Destroy()

        width := NumGet(rect, 8, "Int")
        height := NumGet(rect, 12, "Int")
        return [width + 1, height]
    }

    new_pos(params*) {
        this.pos := _vec(params*)
        this.show()
    }

    move(params*) {
        this.pos := this.pos.add(params*)
        this.show()
    }

    new_size(params*) {
        this.size := _vec(params*)
        this._refit_controls()
        this.show()
    }

    resize(params*) {
        this.size := this.size.add(params*)
        this._refit_controls()
        this.show()
    }

    _refit_controls() {
        for name in this.controls {
            cobj := this.controls[name]
            w := cobj["fit_x"] != 0 ? this.size.x - this.mbr : unset
            h := cobj["fit_y"] != 0 ? this.size.y - this.mbr : unset
            if (IsSet(w) && IsSet(h))
                cobj["control"].Move(, , w, h)
            else if (IsSet(w))
                cobj["control"].Move(, , w)
            else if (IsSet(h))
                cobj["control"].Move(, , , h)
        }
    }

    show() {
        this.gui.Show("x" (this.pos.x + this.mtl) " y" (this.pos.y + this.mtl) " w" (this.size.x - this.mbr) " h" (this.size.y - this.mbr) " NoActivate")
    }

    hide() {
        this.gui.Hide()
    }

    __Delete() {
        this.gui.Destroy()
    }
}

class Picture {
    __New(ui_name, name, vec_pos, vec_size, Config := unset) {
        cfg := IsSet(Config) ? Config : ""

        this.name := ui_name
        this.pos := vec_pos
        this.size := vec_size

        this.bgCol := _cfg(cfg, "color", 0x151515)
        this.bgAlp := _cfg(cfg, "alpha", 255)
        this.add_x := _cfg(cfg, "x", 0)
        this.add_y := _cfg(cfg, "y", 0)

        bgStr := _fmtColor(this.bgCol)

        this.gui := Gui("+AlwaysOnTop -Caption +LastFound -SysMenu +ToolWindow -DPIScale +E0x20")
        this.gui.MarginX := 0
        this.gui.MarginY := 0
        this.gui.BackColor := bgStr

        if (this.bgAlp != 255)
            WinSetTransparent(this.bgAlp, this.gui.Hwnd)
        else
            WinSetTransColor(bgStr, this.gui.Hwnd)

        path := A_ScriptDir "\pictures\" name
        this.picture := this.gui.Add("Picture", "w" this.size.x " h" this.size.y " x" this.add_x " y" this.add_y " AltSubmit BackgroundTrans", path)

        this.hwnd := this.gui.Hwnd
    }

    show() {
        this.gui.Show("x" this.pos.x " y" this.pos.y " w" this.size.x " h" this.size.y " NoActivate")
    }

    hide() {
        this.gui.Hide()
    }

    new_pos(params*) {
        this.pos := _vec(params*)
        this.show()
    }

    move(params*) {
        this.pos := this.pos.add(params*)
        this.show()
    }

    new_size(params*) {
        this.size := _vec(params*)
        this.show()
    }

    resize(params*) {
        this.size := this.size.add(params*)
        this.show()
    }

    get_hwnd() {
        return this.hwnd
    }

    __Delete() {
        this.gui.Destroy()
    }
}

class Line {
    __New(name, vec_pos, vec_size, Config := unset) {
        cfg := IsSet(Config) ? Config : ""

        this.name := name
        this.pos := vec_pos
        this.size := vec_size

        this.bgCol := _cfg(cfg, "color", 0x151515)
        this.bgAlp := _cfg(cfg, "alpha", 255)
        this.border := _cfg(cfg, "border", 0)
        this.blur := _cfg(cfg, "blur", 0)
        this.noBG := _cfg(cfg, "no_bg", 0)
        this._blur_applied := false

        opts := "+AlwaysOnTop -Caption +LastFound -SysMenu +ToolWindow -DPIScale +E0x20"
        if (this.border)
            opts .= " +Border"

        this.gui := Gui(opts)
        this.gui.MarginX := 0
        this.gui.MarginY := 0
        this.gui.BackColor := this.noBG ? "151515" : _fmtColor(this.bgCol)

        if (this.blur)
            WinSetTransColor("151515", this.gui.Hwnd)
        else
            WinSetTransparent(this.noBG ? 0 : this.bgAlp, this.gui.Hwnd)

        this.hwnd := this.gui.Hwnd
    }

    new_pos(params*) {
        this.pos := _vec(params*)
        this.show()
    }

    move(params*) {
        this.pos := this.pos.add(params*)
        this.show()
    }

    new_size(params*) {
        this.size := _vec(params*)
        this.show()
    }

    resize(params*) {
        this.size := this.size.add(params*)
        this.show()
    }

    get_hwnd() {
        return this.hwnd
    }

    _set_blur(hWnd) {
        WCA_ACCENT_POLICY := 19
        ACCENT_ENABLE_BLURBEHIND := 3

        accent := Buffer(16, 0)
        NumPut("UInt", ACCENT_ENABLE_BLURBEHIND, accent, 0)

        padding := A_PtrSize == 8 ? 4 : 0
        data := Buffer(4 + padding + A_PtrSize + 4 + padding, 0)
        NumPut("UInt", WCA_ACCENT_POLICY, data, 0)
        NumPut("Ptr", accent.Ptr, data, 4 + padding)
        NumPut("UInt", accent.Size, data, 4 + padding + A_PtrSize)

        DllCall("SetWindowCompositionAttribute", "Ptr", hWnd, "Ptr", data)
    }

    show() {
        x := this.pos.x + (this.blur && this.border ? -1 : 0)
        y := this.pos.y + (this.blur && this.border ? -1 : 0)
        this.gui.Show("x" x " y" y " w" this.size.x " h" this.size.y " NoActivate")

        if (this.blur && !this._blur_applied) {
            this._set_blur(this.hwnd)
            this._blur_applied := true
        }
    }

    hide() {
        this.gui.Hide()
    }

    __Delete() {
        this.gui.Destroy()
    }
}

class Slider {
    __New(name, vec_pos, vec_size, min, max, val, Config := unset) {
        cfg := IsSet(Config) ? Config : ""

        this.name := name
        this.pos := vec_pos
        this.size := vec_size

        this.color := _cfg(cfg, "color", 0x879CD4)
        this.bgCol := _cfg(cfg, "bgCol", 0x191920)
        this.olCol := _cfg(cfg, "olCol", 0xADADAD)
        this.olAlp := _cfg(cfg, "olAlp", 255)
        this.border := _cfg(cfg, "border", 0)
        this.outline := _cfg(cfg, "ol", [0, 0, 0, 0])
        this.outline_sz := _cfg(cfg, "ol_sz", 2)

        this.outline_elements := []
        this.min := min
        this.max := max
        this.val := Ceil((val - min) / (max - min) * 100)

        for i, v in this.outline
            this.outline[i] := Ceil(Abs(this.outline[i])) != 0 ? 1 : 0
        this.border := Ceil(Abs(this.border)) != 0 ? 1 : 0

        opts := "+AlwaysOnTop -Caption +LastFound -SysMenu +ToolWindow -DPIScale +E0x20"
        if (this.border)
            opts .= " +Border"

        this.gui := Gui(opts)
        this.gui.MarginX := 0
        this.gui.MarginY := 0
        this.gui.BackColor := "FFFFFF"
        WinSetTransColor("FFFFFF", this.gui.Hwnd)

        this.progress := this.gui.Add("Progress", "x0 y0 w" this.size.x " h" this.size.y " c" _fmtColor(this.color) " Background" _fmtColor(this.bgCol), this.val)

        this._draw_outline(vec_pos, vec_size)

        this.hwnd := this.gui.Hwnd
    }

    run(Config := unset) {
        cfg := IsSet(Config) ? Config : ""
        this.min := _cfg(cfg, "min", this.min)
        this.max := _cfg(cfg, "max", this.max)
        start := _cfg(cfg, "ext", -1)

        lostTime := 0
        if (start != -1)
            lostTime := MeasureTime(start)

        duration := this.max - this.min - lostTime
        steps := 100
        stepSize := duration / steps
        inc := 1

        if (stepSize <= 0)
            return

        while (15.6 >= stepSize) {
            stepSize := stepSize * 2
            inc := inc * 2
        }

        this._tickInc := inc
        this._tickCount := 1
        stepSize := stepSize * 0.94

        boundTick := ObjBindMethod(this, "_tick")
        SetTimer boundTick, stepSize
        Critical
        if (start != -1)
            lSleep(this.max - this.min, start)
        else
            lSleep(this.max - this.min)
        Critical "Off"
        SetTimer boundTick, 0
    }

    _tick() {
        this._tickCount += this._tickInc
        this.progress.Value := Clamp(this._tickCount, 0, 100)
    }

    reset(Config := unset) {
        cfg := IsSet(Config) ? Config : ""
        this.min := _cfg(cfg, "min", this.min)
        this.max := _cfg(cfg, "max", this.max)
        this.progress.Value := 0
    }

    set(val) {
        new_val := Ceil((val - this.min) / (this.max - this.min) * 100)
        this.progress.Value := Clamp(new_val, 0, 100)
    }

    _has_outline() {
        return !ArraysEqual(this.outline, [0, 0, 0, 0])
    }

    new_pos(new_pos) {
        delta := new_pos.sub(this.pos)
        for idx, element in this.outline_elements
            element.move(delta)
        this.pos := new_pos
        this.show()
    }

    move(add_pos*) {
        for idx, element in this.outline_elements
            element.move(add_pos*)
        this.pos := this.pos.add(add_pos*)
        this.show()
    }

    new_size(new_size*) {
        new_w := new_size.Length == 1 ? new_size[1].x : new_size[1]
        new_sz := Vector(new_w, this.size.y)

        if (this._has_outline()) {
            this.outline_elements := []
            this._draw_outline(this.pos, new_sz)
        }

        this.size := new_sz
        this.progress.Move(, , this.size.x, this.size.y)
        this.show()
    }

    resize(add_size*) {
        delta_w := add_size.Length == 1 ? add_size[1].x : add_size[1]
        new_sz := Vector(this.size.x + delta_w, this.size.y)

        if (this._has_outline()) {
            this.outline_elements := []
            this._draw_outline(this.pos, new_sz)
        }

        this.size := new_sz
        this.progress.Move(, , this.size.x, this.size.y)
        this.show()
    }

    get_hwnd() {
        return this.hwnd
    }

    _draw_outline(vec_pos, vec_size) {
        border := this.border ? 1 : 0
        this.outline_elements := _build_side_outline(this.name, vec_pos, vec_size, this.outline, this.outline_sz, border, this.olCol, this.olAlp)
    }

    show() {
        x := this.pos.x + (this.border ? -1 : 0)
        y := this.pos.y + (this.border ? -1 : 0)
        this.gui.Show("x" x " y" y " w" this.size.x " h" this.size.y " NoActivate")

        for idx, element in this.outline_elements
            element.show()
    }

    hide() {
        this.gui.Hide()
        for idx, element in this.outline_elements
            element.hide()
    }

    __Delete() {
        this.gui.Destroy()
    }
}

class Window {
    __New(name, x, y, w, h, theme, Config := unset) {
        cfg := IsSet(Config) ? Config : ""
        vec_pos := Vector(x, y)
        vec_size := Vector(w, h)

        this.name := name
        this.pos := vec_pos
        this.size := vec_size
        this.theme := theme

        no_bg := _cfg(cfg, "no_bg", 0)
        margin := _cfg(cfg, "margin", 2)
        this.border := _cfg(cfg, "border", 0)
        this.blur := _cfg(cfg, "blur", 0)
        theme.alpBG := _cfg(cfg, "alpha", theme.alpBG)
        this.bgCol := _cfg(cfg, "bgCol", theme.winBG)

        this.picture := _cfg(cfg, "pic", "")
        add_x := _cfg(cfg, "pmx", 0)
        add_y := _cfg(cfg, "pmy", 0)

        this.outline_cl := _cfg(cfg, "ol_col", this.theme.winOL)
        this.outline_al := _cfg(cfg, "ol_alp", this.theme.alpOL)
        this.outline := _cfg(cfg, "ol", [0, 0, 0, 0])
        this.outline_sz := _cfg(cfg, "ol_sz", 2)
        this.outline_len := _cfg(cfg, "ol_len", Ceil(Min(vec_size.x, vec_size.y) * 0.22))

        if (this.outline != "corner")
            for i, val in this.outline
                this.outline[i] := Ceil(Abs(this.outline[i])) != 0 ? 1 : 0

        this.border := Ceil(Abs(this.border)) != 0 ? 1 : 0
        this.outline_len := Clamp(this.outline_len, 0, Ceil(Min(vec_size.x, vec_size.y) * 0.5))

        if (this.blur)
            this.blur_window := Line(name "_blur", vec_pos, vec_size, {color: this.bgCol, alpha: theme.alpBG, no_bg: no_bg, blur: this.blur, border: this.border})

        if (this.picture != "")
            this.window := Picture("pic_" name, this.picture, vec_pos, vec_size, {color: this.bgCol, alpha: theme.alpBG, x: add_x, y: add_y})
        else
            this.window := Line(name, vec_pos, vec_size, {color: this.bgCol, alpha: theme.alpBG, no_bg: no_bg})

        this.text_window := Text(name, vec_pos, vec_size, theme, {margin: margin})

        this.outline_elements := []
        this.sliders := Map()

        this._redraw_outline(vec_pos, vec_size)
    }

    new_slider(name, vec_pos, vec_size, min, max, cur, Config := unset) {
        cfg := IsSet(Config) ? Config : ""
        this.sliders[this.name "_" name] := Slider(this.name "_" name, this.pos.add(vec_pos), vec_size, min, max, cur, cfg)
    }

    new_text(control_name, body, prop, category, Config := unset) {
        cfg := IsSet(Config) ? Config : ""
        this.text_window.new_text(control_name, body, prop, category, cfg)
    }

    slider(name) {
        return this.sliders[this.name "_" name]
    }

    text() {
        return this.text_window
    }

    get_size() {
        return this.window.size
    }

    get_controls() {
        return this.text_window.get_controls()
    }

    get_hwnd() {
        return this.window.get_hwnd()
    }

    edit_text(control_name, new_text) {
        this.text_window.edit_text(control_name, new_text)
    }

    edit_color(control_name, new_color) {
        this.text_window.edit_color(control_name, new_color)
    }

    measure(control_name) {
        return this.text_window.measure(control_name)
    }

    _has_side_outline() {
        return this.outline is Array && !ArraysEqual(this.outline, [0, 0, 0, 0])
    }

    _has_outline() {
        return this.outline == "corner" || this._has_side_outline()
    }

    _redraw_outline(vec_pos, vec_size) {
        if (this.outline == "corner")
            this.outline_elements := _build_corner_outline(this.name, vec_pos, vec_size, this.outline_sz, this.outline_len, this.outline_cl, this.outline_al)
        else if (this._has_side_outline()) {
            border := this.blur ? this.border : 0
            this.outline_elements := _build_side_outline(this.name, vec_pos, vec_size, this.outline, this.outline_sz, border, this.outline_cl, this.outline_al)
        } else
            this.outline_elements := []
    }

    new_pos(new_pos*) {
        target := _vec(new_pos*)
        delta := target.sub(this.window.pos)

        for idx, element in this.sliders
            element.move(delta)

        if (this.blur)
            this.blur_window.move(delta)

        for idx, element in this.outline_elements
            element.move(delta)

        this.window.move(delta)
        this.text_window.move(delta)
    }

    move(add_pos*) {
        if (this.blur)
            this.blur_window.move(add_pos*)

        for i, element in this.outline_elements
            element.move(add_pos*)

        this.window.move(add_pos*)
        this.text_window.move(add_pos*)

        for idx, element in this.sliders
            element.move(add_pos*)
    }

    new_size(new_size*) {
        target_size := _vec(new_size*)

        if (this._has_outline()) {
            this._redraw_outline(this.window.pos, target_size)
            for idx, element in this.outline_elements
                element.show()
        }

        if (this.blur)
            this.blur_window.new_size(target_size)

        this.window.new_size(target_size)
        this.text_window.new_size(target_size)

        for idx, element in this.sliders
            element.new_size(Vector(target_size.x - (element.pos.x - this.pos.x) * 2, target_size.y))
    }

    resize(add_size*) {
        delta := _vec(add_size*)
        new_sz := this.window.size.add(delta)

        if (this._has_outline()) {
            this._redraw_outline(this.window.pos, new_sz)
            for idx, element in this.outline_elements
                element.show()
        }

        if (this.blur)
            this.blur_window.resize(delta)

        this.window.resize(delta)
        this.text_window.resize(delta)

        for idx, element in this.sliders
            element.resize(delta)
    }

    show() {
        if (this.blur)
            this.blur_window.show()

        this.window.show()
        this.text_window.show()

        for idx, element in this.outline_elements
            element.show()

        for idx, element in this.sliders
            element.show()
    }

    hide() {
        if (this.blur)
            this.blur_window.hide()

        this.window.hide()
        this.text_window.hide()

        for idx, element in this.outline_elements
            element.hide()

        for idx, element in this.sliders
            element.hide()
    }

    __Delete() {
        this.window.__Delete()
        this.text_window.__Delete()

        if (this.blur)
            this.blur_window.__Delete()

        for idx, element in this.outline_elements
            element.__Delete()

        for idx, element in this.sliders
            element.__Delete()
    }
}

class Ui {
    __New(theme) {
        this.theme := theme
        this.windows := Map()
    }

    new_window(name, x, y, w, h, Config := unset) {
        cfg := IsSet(Config) ? Config : ""
        return this.windows[name] := Window(name, x, y, w, h, this.theme, cfg)
    }

    get_window(name) {
        return this.windows[name]
    }

    show() {
        for name, window_obj in this.windows
            window_obj.show()
    }

    hide() {
        for name, window_obj in this.windows
            window_obj.hide()
    }

    __Delete() {
        for name, window_obj in this.windows
            window_obj.__Delete()
    }
}
