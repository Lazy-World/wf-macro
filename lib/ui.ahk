;; ui.ahk - always-on-top overlay widgets built from layered, click-through Guis.
;; Every Gui is unnamed and addressed by its hwnd, so names never collide.
;;   hud := new UiWindow("hud", new UiVector(20, 20), new UiVector(160, 40), UiDefaultTheme(), {"blur": 1, "outline": "corner"})
;;   hud.new_text("hp", "100", "main").show()
;;   hud.move_by(10, 0).resize_to(200, 40)
;;   hud.destroy()
;; Shared by UiText, UiPicture, UiLine, UiSlider, UiWindow and UiStatusWindow:
;;   move_to(x, y) / move_to(vec)     move_by(dx, dy) / move_by(vec)
;;   resize_to(w, h) / resize_to(vec) resize_by(dw, dh) / resize_by(vec)
;;   show(), hide(), destroy(), hwnd(); fields pos, size, visible (read only)
;; Setters keep visibility: a hidden widget only stores its new geometry.
;; destroy() is final and idempotent, later calls on the object do nothing.
;; Functions with locals start with `local` (force-local mode), so a script's top-level `global x, h, ...`
;; cannot leak into them; class names are globals too and are declared where used.
;; Every class carries the Ui prefix: class names are script-wide globals in v1, and a plain
;; `window := ...` in a script would otherwise overwrite the class.
#include %A_LineFile%\..\core.ahk

UiBaseStyle() {
    return "+AlwaysOnTop -Caption +LastFound -SysMenu +ToolWindow -DPIScale +E0x20"
}

; -> a fresh copy of the default theme; new_text categories are keys of fonts
UiDefaultTheme() {
    return {bg_color: "151515", bg_alpha: 170, outline_color: "879CD4", outline_alpha: 255
        , fonts: {menu_icon: {name: "menu_font", size: 15, color: "f7f2d2"}
                , title:     {name: "Helvetica", size: 13, color: "ff68b5"}
                , main:      {name: "Helvetica", size: 13, color: "White"}
                , accent:    {name: "Helvetica", size: 13, color: "FFF6BD"}
                , info:      {name: "Helvetica", size: 13, color: "FFF6BD"}}}
}

; [pos, size] of the [left, top, right, bottom] edges around a rect.
; Top and bottom span the side edges that are drawn (ol_left / ol_right = 1).
UiEdgeOutlineLayout(vec_pos, vec_size, bold, ol_left, ol_right, border) {
    local
    global UiVector
    ol_sum := ol_left + ol_right
    span_x := vec_pos.x - bold + (ol_left ? 0 : bold - border)
    span_w := vec_size.x + bold * ol_sum + border * (2 - ol_sum)
    side_h := vec_size.y + border * 2

    return [ [vec_pos.add(-bold, -border), new UiVector(bold, side_h)]                 ; left
           , [new UiVector(span_x, vec_pos.y - bold), new UiVector(span_w, bold)]       ; top
           , [vec_pos.add(vec_size.x, -border), new UiVector(bold, side_h)]           ; right
           , [new UiVector(span_x, vec_pos.y + vec_size.y), new UiVector(span_w, bold)] ] ; bottom
}

class UiVector {
    __new(x, y) {
        this.x := x
        this.y := y
    }

    ; add(vec) or add(dx, dy) -> new UiVector
    add(params*) {
        local
        global UiVector
        if (params.Length() = 1)
            return new UiVector(this.x + params[1].x, this.y + params[1].y)
        return new UiVector(this.x + params[1], this.y + params[2])
    }

    copy() {
        local
        global UiVector
        return new UiVector(this.x, this.y)
    }

    swap() {
        local
        global UiVector
        return new UiVector(this.y, this.x)
    }
}

;; UiElement - base of every widget: geometry, visibility and lifetime.
;; A widget calls _init(), stores its Gui hwnd in _h and implements _draw() (show the Gui at pos/size).
;; _parts() lists the child widgets that follow show / hide / destroy (outline Lines by default).
;; _set(pos, size) is the one geometry update; _update() reacts to it.
class UiElement {
    static _dpi := DllCall("SetThreadDpiAwarenessContext", "Ptr", -3, "Ptr")

    move_to(params*) {
        return this._set(this._vec(params), this.size)
    }

    move_by(params*) {
        return this._set(this.pos.add(this._vec(params)), this.size)
    }

    resize_to(params*) {
        return this._set(this.pos, this._vec(params))
    }

    resize_by(params*) {
        return this._set(this.pos, this.size.add(this._vec(params)))
    }

    show() {
        if (this._alive) {
            this.visible := true
            this._show()
        }
        return this
    }

    hide() {
        if (this._alive) {
            this.visible := false
            this._hide()
        }
        return this
    }

    destroy() {
        if !this._alive
            return
        this._alive := false
        this.visible := false
        this._destroy()
    }

    hwnd() {
        return this._h
    }

    __Delete() {
        this.destroy()
    }

    _init(name, vec_pos, vec_size) {
        this.name := name
        this.pos := this._vec([vec_pos])
        this.size := this._vec([vec_size])
        this.visible := false
        this._alive := true
        this._lines := []
    }

    ; Unchanged geometry is a no-op, so containers may pass it on freely
    _set(vec_pos, vec_size) {
        local
        if (this._alive && (vec_pos.x != this.pos.x || vec_pos.y != this.pos.y || vec_size.x != this.size.x || vec_size.y != this.size.y)) {
            old_pos := this.pos, old_size := this.size
            this.pos := vec_pos.copy(), this.size := vec_size.copy()
            this._update(old_pos, old_size)
        }
        return this
    }

    _update(old_pos, old_size) {
        if this.visible
            this._draw()
    }

    _parts() {
        return this._lines
    }

    _show() {
        local
        if this._h
            this._draw()
        for _, part in this._parts()
            part.show()
    }

    _hide() {
        local
        if (h := this._h)
            Gui, %h%: Hide
        for _, part in this._parts()
            part.hide()
    }

    _destroy() {
        local
        if (h := this._h)
            Gui, %h%: Destroy
        for _, part in this._parts()
            part.destroy()
        this._lines := []
    }

    ; Fits the outline Lines to segments [[pos, size], ...]: moves the existing ones, creates or destroys the difference
    _sync_lines(segments, config) {
        local
        global UiLine
        if !this._alive
            return
        while (this._lines.Length() > segments.Length())
            this._lines.Pop().destroy()
        for i, seg in segments {
            if (i <= this._lines.Length()) {
                this._lines[i]._set(seg[1], seg[2])
            } else {
                line := this._lines[i] := new UiLine(this.name ".outline" i, seg[1], seg[2], config)
                if this.visible
                    line.show()
            }
        }
    }

    _edge_segments(flags, bold, border) {
        local
        layout := UiEdgeOutlineLayout(this.pos, this.size, bold, flags[1], flags[3], border)
        segments := []
        for i, on in flags
            if on
                segments.Push(layout[i])
        return segments
    }

    ; New base-style Gui that stays the Last Found Window; the thread's default Gui is left as it was
    _new_gui(options := "") {
        local
        prev := A_DefaultGui
        Gui, New, % UiBaseStyle() " " options " +Hwndh"
        Gui, %h%: Margin, 0, 0
        try Gui, %prev%: Default
        catch
            Gui, 1: Default
        return h
    }

    ; (x, y) or (vec) -> new UiVector. Blanks are rejected: Gui Show with an empty w never returns.
    _vec(params) {
        local
        global UiVector
        if (params.Length() = 1 && IsObject(params[1]))
            x := params[1].x, y := params[1].y
        else if (params.Length() = 2)
            x := params[1], y := params[2]
        if x is number
            if y is number
                return new UiVector(x, y)
        throw Exception("Expected (x, y) numbers or a UiVector", -2)
    }

    ; Outline spec -> normalized copy: [left, top, right, bottom] as 0/1, or "corner"
    _flags(outline) {
        local
        if (outline = "corner")
            return outline
        flags := []
        Loop 4
            flags.Push(outline[A_Index] ? 1 : 0)
        return flags
    }

    _clone(obj) {
        local
        copy := obj.Clone()
        for k, v in copy
            if IsObject(v)
                copy[k] := this._clone(v)
        return copy
    }
}

;; UiLine - plain coloured rectangle; with blur it is the blur-behind layer of a UiWindow.
;;   bar := new UiLine("bar", new UiVector(0, 0), new UiVector(100, 2), {"color": "879CD4"}).show()
;; config: color "151515", alpha 255, border 0, blur 0, no_bg 0
class UiLine extends UiElement {
    __new(name, vec_pos, vec_size, config := "") {
        local
        this._init(name, vec_pos, vec_size)
        this.color  := ValueOr(config.color, "151515")
        this.alpha  := ValueOr(config.alpha, 255)
        this.border := ValueOr(config.border, 0) ? 1 : 0
        this.blur   := ValueOr(config.blur, 0) ? 1 : 0
        this.no_bg  := ValueOr(config.no_bg, 0) ? 1 : 0

        bg := this.no_bg ? "151515" : this.color
        this._h := h := this._new_gui(this.border ? "+Border" : "")
        Gui, %h%: Color, % bg
        if this.blur
            WinSet, TransColor, % bg
        else
            WinSet, Transparent, % this.no_bg ? 0 : this.alpha
    }

    _draw() {
        local
        h := this._h
        d := this.blur && this.border ? -1 : 0
        Gui, %h%: Show, % "x" this.pos.x + d " y" this.pos.y + d " w" this.size.x " h" this.size.y " NoActivate"
        if this.blur
            this._set_blur(h)
    }

    ; Blur behind the window via SetWindowCompositionAttribute (by qwerty12 and jNizM)
    _set_blur(hwnd) {
        local
        static WCA_ACCENT_POLICY := 19, ACCENT_ENABLE_BLURBEHIND := 3
        size := VarSetCapacity(accent, 16, 0)
        NumPut(ACCENT_ENABLE_BLURBEHIND, accent, 0, "UInt")
        VarSetCapacity(data, 3 * A_PtrSize, 0)
        NumPut(WCA_ACCENT_POLICY, data, 0, "UInt")
        NumPut(&accent, data, A_PtrSize, "Ptr")
        NumPut(size, data, 2 * A_PtrSize, "UInt")
        DllCall("SetWindowCompositionAttribute", "Ptr", hwnd, "Ptr", &data)
    }
}

;; UiText - transparent text layer; pos/size is the outer rect, controls sit inside the margin.
;;   txt := new UiText("t", new UiVector(0, 0), new UiVector(120, 25), UiDefaultTheme())
;;   txt.new_text("hp", "100", "main", "left x10 ym").show()
;; prop: "" / "auto" (centered), "left", "right" or raw Gui options (alignment defaults to center).
;; config: margin 2. new_text config: fit_x, fit_y (follow the layer's width / height on resize).
class UiText extends UiElement {
    static _key := "010101" ; transparency key, never a font colour (black text stays visible)

    __new(name, vec_pos, vec_size, theme := "", config := "") {
        local
        this._init(name, vec_pos, vec_size)
        this.theme := IsObject(theme) ? theme : UiDefaultTheme()
        this.margin := ValueOr(config.margin, 2)
        this.controls := {}

        this._h := h := this._new_gui()
        Gui, %h%: Color, % this._key
        WinSet, TransColor, % this._key
    }

    new_text(control_name, body, category, prop := "", config := "") {
        local
        if !this._alive
            return this
        font := this.theme.fonts[category]
        if !IsObject(font)
            throw Exception("Unknown font category: " category, -1)
        if this.controls.HasKey(control_name)
            throw Exception("Control already exists: " control_name, -1)

        h := this._h
        Gui, %h%: Font, % "s" font.size " q5", % font.name
        Gui, %h%: Add, Text, % this._placement(prop) " w" this.size.x - 2 * this.margin " BackgroundTrans 0x200 HwndhCtl c" font.color, % body
        this.controls[control_name] := {control: hCtl, body: body, font: font.name, font_size: font.size, color: font.color
            , fit_x: ValueOr(config.fit_x, 0), fit_y: ValueOr(config.fit_y, 0)}
        return this
    }

    edit_text(control_name, text) {
        local
        ctl := this.get_control(control_name)
        if (this._alive) {
            h := this._h
            GuiControl, %h%:, % ctl.control, % text
            ctl.body := text
        }
        return this
    }

    edit_color(control_name, color) {
        local
        ctl := this.get_control(control_name)
        if (this._alive) {
            GuiControl, % this._h ": +c" color, % ctl.control
            ctl.color := color
        }
        return this
    }

    ; -> {control (hwnd), body, font, font_size, color, fit_x, fit_y}
    get_control(control_name) {
        if !this.controls.HasKey(control_name)
            throw Exception("Unknown control: " control_name, -2)
        return this.controls[control_name]
    }

    ; -> [w, h] of the control
    get_size(control_name) {
        local
        ctl := this.get_control(control_name)
        if !this._alive
            return [0, 0]
        h := this._h
        GuiControlGet, c, %h%: Pos, % ctl.control
        return [cW, cH]
    }

    ; -> [w, h] of the control's text drawn on one line in its own font (plain GDI, no Gui involved)
    measure(control_name) {
        local
        static WM_GETFONT := 0x31, DT_CALCRECT_SINGLELINE_NOCLIP := 0x520
        ctl := this.get_control(control_name)
        if !this._alive
            return [0, 0]
        hdc := DllCall("GetDC", "Ptr", ctl.control, "Ptr")
        font := DllCall("SendMessage", "Ptr", ctl.control, "UInt", WM_GETFONT, "Ptr", 0, "Ptr", 0, "Ptr")
        prev := DllCall("SelectObject", "Ptr", hdc, "Ptr", font, "Ptr")
        VarSetCapacity(rect, 16, 0)
        DllCall("DrawText", "Ptr", hdc, "Str", ctl.body, "Int", -1, "Ptr", &rect, "UInt", DT_CALCRECT_SINGLELINE_NOCLIP)
        DllCall("SelectObject", "Ptr", hdc, "Ptr", prev, "Ptr")
        DllCall("ReleaseDC", "Ptr", ctl.control, "Ptr", hdc)
        return [NumGet(rect, 8, "Int") + 1, NumGet(rect, 12, "Int")]
    }

    _placement(prop) {
        prop := Trim(prop)
        if (prop = "" || prop = "auto")
            return "center xs ym0"
        if (prop = "left" || prop = "right")
            return prop " xs ym0"
        if InStr(prop, "auto")
            return StrReplace(prop, "auto", "center")
        return RegExMatch(prop, "i)\b(center|left|right)\b") ? prop : "center " prop
    }

    _update(old_pos, old_size) {
        local
        if (this.size.x != old_size.x || this.size.y != old_size.y) {
            h := this._h
            for _, ctl in this.controls {
                fit := (ctl.fit_x ? " w" this.size.x - 2 * this.margin : "") (ctl.fit_y ? " h" this.size.y - 2 * this.margin : "")
                if (fit != "")
                    GuiControl, %h%: Move, % ctl.control, % fit
            }
        }
        base._update(old_pos, old_size)
    }

    _draw() {
        local
        h := this._h
        m := this.margin
        Gui, %h%: Show, % "x" this.pos.x + m " y" this.pos.y + m " w" Max(0, this.size.x - 2 * m) " h" Max(0, this.size.y - 2 * m) " NoActivate"
    }
}

;; UiPicture - image layer; file is absolute or relative to A_ScriptDir "\pictures\".
;;   pic := new UiPicture("logo", "logo.png", new UiVector(0, 0), new UiVector(64, 64)).show()
;; config: color "151515", alpha 255 (255 = color is transparent), x 0, y 0 (image offset)
class UiPicture extends UiElement {
    __new(name, file, vec_pos, vec_size, config := "") {
        local
        this._init(name, vec_pos, vec_size)
        this.file  := RegExMatch(file, "^(?:[A-Za-z]:[\\/]|\\\\)") ? file : A_ScriptDir "\pictures\" file
        this.color := ValueOr(config.color, "151515")
        this.alpha := ValueOr(config.alpha, 255)

        this._h := h := this._new_gui()
        Gui, %h%: Color, % this.color
        if (this.alpha != 255)
            WinSet, Transparent, % this.alpha
        else
            WinSet, TransColor, % this.color
        Gui, %h%: Add, Picture, % "x" ValueOr(config.x, 0) " y" ValueOr(config.y, 0) " w" this.size.x " h" this.size.y " AltSubmit BackgroundTrans HwndhPic", % this.file
        this._pic := hPic
    }

    _update(old_pos, old_size) {
        local
        if (this.size.x != old_size.x || this.size.y != old_size.y) {
            h := this._h
            GuiControl, %h%:, % this._pic, % "*w" this.size.x " *h" this.size.y " " this.file
        }
        base._update(old_pos, old_size)
    }

    _draw() {
        local
        h := this._h
        Gui, %h%: Show, % "x" this.pos.x " y" this.pos.y " w" this.size.x " h" this.size.y " NoActivate"
    }
}

;; UiSlider - progress bar with optional edge outlines.
;;   bar := new UiSlider("cd", new UiVector(0, 0), new UiVector(100, 5), 0, 10, 3).show()
;;   bar.set(7)              ; value in [min, max] -> 70%
;;   bar.run(1500)           ; fill 0..100% over 1500 ms (blocks), default duration max - min
;;   bar.reset()             ; back to 0%
;; config: color "879CD4", bg_color "191920", outline [l, t, r, b], outline_color "ADADAD",
;; outline_alpha 255, outline_size 2, border 0
class UiSlider extends UiElement {
    __new(name, vec_pos, vec_size, min, max, val, config := "") {
        local
        this._init(name, vec_pos, vec_size)
        this.min := min
        this.max := max
        this.color         := ValueOr(config.color, "879CD4")
        this.bg_color      := ValueOr(config.bg_color, "191920")
        this.outline       := this._flags(config.outline)
        this.outline_color := ValueOr(config.outline_color, "ADADAD")
        this.outline_alpha := ValueOr(config.outline_alpha, 255)
        this.outline_size  := ValueOr(config.outline_size, 2)
        this.border        := ValueOr(config.border, 0) ? 1 : 0

        this._h := h := this._new_gui(this.border ? "+Border" : "")
        Gui, %h%: Color, FFFFFF
        WinSet, TransColor, FFFFFF ; also hides the white edge of the unthemed Progress control
        Gui, %h%: Add, Progress, % "x0 y0 w" this.size.x " h" this.size.y " c" this.color " Background" this.bg_color " HwndhBar"
            , % Clamp(this._percent(val), 0, 100)
        this._bar := hBar
        this._sync_outline()
    }

    ; Fills 0..100% over duration_ms (blank = max - min) counted from start (a Now() value, blank = now).
    ; Blocks until done and always ends at 100%.
    run(duration_ms := "", start := "") {
        local
        duration_ms := ValueOr(duration_ms, this.max - this.min)
        start := ValueOr(start, Now())
        if (duration_ms > 0) {
            tick := ObjBindMethod(this, "_fill_since", start, duration_ms)
            SetTimer, % tick, 15
            this._fill_since(start, duration_ms)
            if ((left := start + duration_ms - Now()) > 0)
                Wait(left)
            SetTimer, % tick, Delete
        }
        return this._fill(100)
    }

    reset(min := "", max := "") {
        this.min := ValueOr(min, this.min)
        this.max := ValueOr(max, this.max)
        return this._fill(0)
    }

    set(val) {
        return this._fill(this._percent(val))
    }

    _percent(val) {
        if (this.max = this.min)
            return val >= this.max ? 100 : 0
        return Ceil((val - this.min) / (this.max - this.min) * 100)
    }

    _fill_since(start, duration_ms) {
        this._fill(Since(start) / duration_ms * 100)
    }

    _fill(percent) {
        local
        if (this._alive) {
            h := this._h
            GuiControl, %h%:, % this._bar, % Clamp(Round(percent), 0, 100)
        }
        return this
    }

    _sync_outline() {
        this._sync_lines(this._edge_segments(this.outline, this.outline_size, this.border)
            , {color: this.outline_color, alpha: this.outline_alpha})
    }

    _update(old_pos, old_size) {
        local
        if (this.size.x != old_size.x || this.size.y != old_size.y) {
            h := this._h
            GuiControl, %h%: Move, % this._bar, % "w" this.size.x " h" this.size.y
        }
        this._sync_outline()
        base._update(old_pos, old_size)
    }

    _draw() {
        local
        h := this._h
        d := this.border ? -1 : 0
        Gui, %h%: Show, % "x" this.pos.x + d " y" this.pos.y + d " w" this.size.x " h" this.size.y " NoActivate"
    }
}

;; UiWindow - layered panel: optional blur layer, background (UiLine or UiPicture), text layer,
;; outline and sliders, all kept on one geometry.
;;   w := new UiWindow("hud", new UiVector(20, 20), new UiVector(160, 40), theme, {"blur": 1, "outline": [0, 0, 0, 1]})
;;   w.new_text("hp", "100", "main")
;;   w.new_slider("cd", new UiVector(4, 30), new UiVector(152, 5), 0, 100, 0) ; pos relative to the window
;;   w.show()
;; Sliders keep their offset on move and their left/right margins on resize.
;; config: no_bg 0, margin 2, border 0, blur 0, alpha theme.bg_alpha, bg_color theme.bg_color,
;; picture "", picture_x 0, picture_y 0, outline [left, top, right, bottom] or "corner",
;; outline_color / outline_alpha (theme), outline_size 2, outline_len (corner arm, default 22% of the short side)
class UiWindow extends UiElement {
    __new(name, vec_pos, vec_size, theme := "", config := "") {
        local
        global UiLine, UiPicture, UiText
        this._init(name, vec_pos, vec_size)
        this.theme := IsObject(theme) ? this._clone(theme) : UiDefaultTheme()
        this.no_bg         := ValueOr(config.no_bg, 0) ? 1 : 0
        this.margin        := ValueOr(config.margin, 2)
        this.border        := ValueOr(config.border, 0) ? 1 : 0
        this.blur          := ValueOr(config.blur, 0) ? 1 : 0
        this.alpha         := ValueOr(config.alpha, this.theme.bg_alpha)
        this.bg_color      := ValueOr(config.bg_color, this.theme.bg_color)
        this.picture       := ValueOr(config.picture, "")
        this.outline       := this._flags(config.outline)
        this.outline_color := ValueOr(config.outline_color, this.theme.outline_color)
        this.outline_alpha := ValueOr(config.outline_alpha, this.theme.outline_alpha)
        this.outline_size  := ValueOr(config.outline_size, 2)
        this.outline_len   := ValueOr(config.outline_len, "")
        this.sliders := {}, this._slider_rel := {}

        if this.blur
            this.blur_window := new UiLine(name ".blur", this.pos, this.size
                , {color: this.bg_color, alpha: this.alpha, no_bg: this.no_bg, blur: 1, border: this.border})
        if (this.picture != "")
            this.window := new UiPicture(name ".picture", this.picture, this.pos, this.size
                , {color: this.bg_color, alpha: this.alpha, x: ValueOr(config.picture_x, 0), y: ValueOr(config.picture_y, 0)})
        else
            this.window := new UiLine(name ".bg", this.pos, this.size, {color: this.bg_color, alpha: this.alpha, no_bg: this.no_bg})
        this.text_window := new UiText(name ".text", this.pos, this.size, this.theme, {margin: this.margin})
        this._sync_outline()
    }

    new_text(control_name, body, category, prop := "", config := "") {
        this.text_window.new_text(control_name, body, category, prop, config)
        return this
    }

    edit_text(control_name, text) {
        this.text_window.edit_text(control_name, text)
        return this
    }

    edit_color(control_name, color) {
        this.text_window.edit_color(control_name, color)
        return this
    }

    measure(control_name) {
        return this.text_window.measure(control_name)
    }

    ; -> the new UiSlider; vec_pos is relative to the window, an existing slider of that name is replaced
    new_slider(name, vec_pos, vec_size, min, max, val, config := "") {
        local
        global UiSlider
        if !this._alive
            return
        if this.sliders.HasKey(name)
            this.sliders[name].destroy()
        s := this.sliders[name] := new UiSlider(this.name "." name, this.pos.add(this._vec([vec_pos])), vec_size, min, max, val, config)
        this._slider_rel[name] := this._rel(s, this.pos, this.size)
        if this.visible
            s.show()
        return s
    }

    slider(name) {
        return this.sliders[name]
    }

    text() {
        return this.text_window
    }

    controls() {
        return this.text_window.controls
    }

    hwnd() {
        return this.window.hwnd()
    }

    ; outline: [left, top, right, bottom] flags or "corner".
    ; vec_pos / vec_size (optional) move / resize the window in the same, single outline update.
    set_outline(outline, vec_pos := "", vec_size := "") {
        this.outline := this._flags(outline)
        this._set(IsObject(vec_pos) ? vec_pos : this.pos, IsObject(vec_size) ? vec_size : this.size)
        this._sync_outline() ; no-op when _set already synced it
        return this
    }

    _layers() {
        return this.blur ? [this.blur_window, this.window, this.text_window] : [this.window, this.text_window]
    }

    ; layers, outline, sliders: also the show / hide / destroy order
    _parts() {
        local
        parts := this._layers()
        parts.Push(this._lines*)
        for _, s in this.sliders
            parts.Push(s)
        return parts
    }

    _update(old_pos, old_size) {
        local
        global UiVector
        for _, layer in this._layers()
            layer._set(this.pos, this.size)
        this._sync_outline()
        for name, s in this.sliders {
            r := this._slider_rel[name]
            if (s.pos.x != old_pos.x + r[1] || s.pos.y != old_pos.y + r[2] || s.size.x != Max(0, old_size.x - r[1] - r[3]))
                r := this._slider_rel[name] := this._rel(s, old_pos, old_size) ; the slider was moved / resized directly
            s._set(this.pos.add(r[1], r[2]), new UiVector(Max(0, this.size.x - r[1] - r[3]), s.size.y))
        }
    }

    ; [dx, dy, right margin] of a slider in a window at pos/size; kept so a width clamped to 0 can grow back
    _rel(s, pos, size) {
        return [s.pos.x - pos.x, s.pos.y - pos.y, size.x - (s.pos.x - pos.x) - s.size.x]
    }

    _destroy() {
        base._destroy()
        this.sliders := {}, this._slider_rel := {}
    }

    _sync_outline() {
        local
        segments := this.outline = "corner" ? this._corner_segments()
            : this._edge_segments(this.outline, this.outline_size, this.blur ? this.border : 0)
        this._sync_lines(segments, {color: this.outline_color, alpha: this.outline_alpha})
    }

    _corner_segments() {
        local
        global UiVector
        p := this.pos, w := this.size.x, h := this.size.y, bold := this.outline_size
        len := Clamp(ValueOr(this.outline_len, Ceil(Min(w, h) * 0.22)), 0, Ceil(Min(w, h) * 0.5))

        return [ [p.add(-bold, 0), new UiVector(bold, len)]                 ; left top
               , [p.add(-bold, h - len), new UiVector(bold, len)]           ; left bottom
               , [p.add(-bold, -bold), new UiVector(len + bold, bold)]      ; top left
               , [p.add(w - len, -bold), new UiVector(len + bold, bold)]    ; top right
               , [p.add(w, 0), new UiVector(bold, len)]                     ; right top
               , [p.add(w, h - len), new UiVector(bold, len)]               ; right bottom
               , [p.add(-bold, h), new UiVector(len + bold, bold)]          ; bottom left
               , [p.add(w - len, h), new UiVector(len + bold, bold)] ]      ; bottom right
    }
}

;; UiManager - a set of UiWindows sharing one theme, keyed by name.
;;   gui := new UiManager()         ; blank theme = UiDefaultTheme()
;;   gui.new_window("hud", new UiVector(20, 20), new UiVector(160, 40), {"blur": 1}).new_text("hp", "100", "main")
;;   gui.show()
class UiManager {
    __new(theme := "") {
        this.theme := IsObject(theme) ? theme : UiDefaultTheme()
        this.windows := {}
        this._alive := true
    }
    ; -> the new UiWindow; an existing window of that name is destroyed and replaced
    new_window(name, vec_pos, vec_size, config := "") {
        local
        global UiWindow
        if !this._alive
            return
        if this.windows.HasKey(name)
            this.windows[name].destroy()
        return this.windows[name] := new UiWindow(name, vec_pos, vec_size, this.theme, config)
    }

    get_window(name) {
        return this.windows[name]
    }

    show() {
        local
        for _, w in this.windows
            w.show()
        return this
    }

    hide() {
        local
        for _, w in this.windows
            w.hide()
        return this
    }

    destroy() {
        local
        for _, w in this.windows
            w.destroy()
        this.windows := {}, this._alive := false
    }

    __Delete() {
        this.destroy()
    }
}

;; UiStatusWindow - facade over UiWindow: a header with an icon on top and a body "<label>: <value>" under it.
;;   status := new UiStatusWindow(x, y, "HILDR")   ; build + show with UiDefaultTheme()
;;   status.text := "GO"                         ; body -> "HILDR: GO"
;;   cur := status.text                          ; read the value
;;   status.reset()                              ; body -> "HILDR: off"
;;   status.suspended := true                    ; header -> "suspended"
;; Several macros stack up via place(slot, last): the header belongs to slot 1, bodies go below it
;; in slot order with side outlines, the last one is closed by a bottom outline.
;; pos is the stack origin (header top-left), size is (width, body height).
;; opt overrides {w: 120, h: 25, head_h: 22, gap: 4, icon: "D", idle: "off", style: "accent", color: "",
;; show: true, name: auto, theme: UiDefaultTheme()}; opt.config is a raw UiWindow config merged over the body defaults.
class UiStatusWindow extends UiElement {
    static _n := 0

    __new(x, y, label := "", opt := "") {
        local
        global UiStatusWindow, UiVector, UiWindow
        theme := IsObject(opt.theme) ? opt.theme : UiDefaultTheme()
        name := opt.name != "" ? opt.name : "status" (++UiStatusWindow._n)
        this._init(name, new UiVector(x, y), new UiVector(ValueOr(opt.w, 120), ValueOr(opt.h, 25)))
        this._gap := ValueOr(opt.gap, 4)
        this._head_h := ValueOr(opt.head_h, 22)
        this._icon := ValueOr(opt.icon, "D")
        this._idle := ValueOr(opt.idle, "off")
        this._suspended := false
        this._slot := 0 ; not placed yet
        this._last := true

        this.head := new UiWindow(name ".head", this.pos, new UiVector(this.size.x, this._head_h), theme
            , {margin: 2, blur: 1, outline: [0, 1, 0, 0]})
        this.head.new_text("icon", this._icon, "menu_icon", "auto")

        this.win := new UiWindow(name, new UiVector(x, this._body_y(1)), this.size, theme, this._config(opt.config))
        this.win.new_text("key", label != "" ? label ":" : "", "main", "left x10 ym")
        this.win.new_text("value", this._idle, ValueOr(opt.style, "accent"), "left x" (10 + this.win.measure("key")[1] + 4) " yp")
        if (opt.color != "")
            this.win.edit_color("value", opt.color)

        if ValueOr(opt.show, true)
            this.place(1)
    }

    text {
        get {
            return this.label("value")
        }
        set {
            this.label("value", value)
            return value
        }
    }

    suspended {
        get {
            return this._suspended
        }
        set {
            this._suspended := value ? true : false
            this.head.edit_text("icon", this._suspended ? "suspended" : this._icon)
            return value
        }
    }

    reset() {
        this.text := this._idle
        return this
    }

    ; slot 1 = top body (it also shows the header); last closes the stack. Shows the stack.
    place(slot, last := true) {
        last := last ? true : false
        if (slot != this._slot || last != this._last) {
            this._slot := slot, this._last := last
            this._layout()
        }
        return this.show()
    }

    color(hex) {
        this.win.edit_color("value", hex)
        return this
    }

    ; label(name) -> text of a body control; label(name, text) sets it
    label(name, params*) {
        if (params.Length() = 0)
            return this.win.text().get_control(name).body
        this.win.edit_text(name, params[1])
        return this
    }

    ; Adds a text row under the existing ones and grows the body to fit it.
    ; opt: {style: "info", align: "center" | "left" | "right", color}
    add(name, text, opt := "") {
        this.win.new_text(name, text, ValueOr(opt.style, "info"), ValueOr(opt.align, "center") " x0 y+0")
        if (opt.color != "")
            this.win.edit_color(name, opt.color)
        return this.resize_by(0, this.win.text().get_size(name)[2])
    }

    ; x, y relative to the body
    add_slider(name, x, y, w, h, min, max, val, opt := "") {
        local
        global UiVector
        this.win.new_slider(name, new UiVector(x, y), new UiVector(w, h), min, max, val, opt)
        return this
    }

    slider(name) {
        return this.win.slider(name)
    }

    hwnd() {
        return this.win.hwnd()
    }

    window() {
        return this.win
    }

    _config(config) {
        local
        merged := {blur: 1, outline: [0, 0, 0, 1]}
        if IsObject(config)
            for k, v in config
                merged[k] := v
        return merged
    }

    _body_y(slot) {
        return this.pos.y + this._head_h + this._gap + (slot - 1) * (this.size.y + this._gap)
    }

    ; At most one geometry and outline update per window (unchanged geometry is skipped)
    _layout() {
        local
        global UiVector
        this.head.move_to(this.pos).resize_to(this.size.x, this._head_h)
        this.win.set_outline(this._last ? [0, 0, 0, 1] : [1, 0, 1, 0]
            , new UiVector(this.pos.x, this._body_y(Max(this._slot, 1))), this.size)
    }

    _update(old_pos, old_size) {
        this._layout()
    }

    _parts() {
        return [this.win, this.head]
    }

    _show() {
        if (!this._slot) {
            this._slot := 1
            this._layout()
        }
        if !this.win.visible
            this.win.show()
        if (this._slot = 1 && !this.head.visible)
            this.head.show()
        else if (this._slot != 1 && this.head.visible)
            this.head.hide()
    }
}
