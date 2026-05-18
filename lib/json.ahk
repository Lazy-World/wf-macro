#Requires AutoHotkey v2.0
; -----------------------------------------------------------------------------
; json.ahk - JSON parser/dumper + ergonomic Cfg wrapper for AHK v2
;
; Low-level:
;   JsonLoad(text)              -> Map | Array | scalar
;   JsonDump(obj, indent := "") -> JSON string
;
; Back-compat (old call style still used by scripts):
;   json_load(&src, args*)
;   json_dump(obj, indent := "", lvl := 1)
;
; High-level wrapper (recommended for new code):
;   cfg := Cfg.FromFile("path\\to\\file.json")
;   cfg.v("interval")           ; auto-unwrap  val.<name>.val
;   cfg.k("StartStop")          ; auto-unwrap  hk.<name>.key
;   cfg.get("game.melee")       ; dot path
;   cfg.get("misc.fps", 60)     ; with default
;   for fn, combo in cfg.hotkeys()
;       Hotkey "*" combo, %fn%
; -----------------------------------------------------------------------------

JsonLoad(text) {
    return json_load(&text)
}

JsonDump(obj, indent := "") {
    return json_dump(obj, indent)
}

; -----------------------------------------------------------------------------
; Cfg - thin wrapper around a parsed Map/Array tree
; -----------------------------------------------------------------------------
class Cfg {
    raw := Map()
    path := ""

    static FromFile(filePath) {
        c := Cfg()
        c.path := filePath
        c.Reload()
        return c
    }

    static FromString(jsonText) {
        c := Cfg()
        c.raw := JsonLoad(jsonText)
        return c
    }

    Reload() {
        if (this.path == "")
            throw Error("Cfg.Reload: no file path attached")
        text := FileRead(this.path, "UTF-8")
        this.raw := JsonLoad(text)
    }

    Save(filePath := "", indent := 4) {
        target := (filePath == "") ? this.path : filePath
        if (target == "")
            throw Error("Cfg.Save: no target path")
        f := FileOpen(target, "w", "UTF-8")
        if !f
            throw Error("Cfg.Save: cannot open " target)
        f.Write(JsonDump(this.raw, indent))
        f.Close()
    }

    ; --- traversal helpers ---

    Has(path) {
        cur := this.raw
        for part in StrSplit(path, ".") {
            if (cur is Map) {
                if !cur.Has(part)
                    return false
                cur := cur[part]
            } else if (cur is Array) {
                if !(IsInteger(part) && part >= 1 && part <= cur.Length)
                    return false
                cur := cur[Integer(part)]
            } else {
                return false
            }
        }
        return true
    }

    Get(path, default := unset) {
        cur := this.raw
        for part in StrSplit(path, ".") {
            if (cur is Map) {
                if !cur.Has(part) {
                    if IsSet(default)
                        return default
                    throw Error("Cfg.Get: missing key '" part "' in path '" path "'")
                }
                cur := cur[part]
            } else if (cur is Array) {
                if !(IsInteger(part) && part >= 1 && part <= cur.Length) {
                    if IsSet(default)
                        return default
                    throw Error("Cfg.Get: bad array index '" part "' in path '" path "'")
                }
                cur := cur[Integer(part)]
            } else {
                if IsSet(default)
                    return default
                throw Error("Cfg.Get: path '" path "' descends into a scalar at '" part "'")
            }
        }
        return cur
    }

    Set(path, value) {
        parts := StrSplit(path, ".")
        last := parts.Pop()
        cur := this.raw
        for part in parts {
            if !(cur is Map)
                throw Error("Cfg.Set: cannot descend into non-Map at '" part "'")
            if !cur.Has(part)
                cur[part] := Map()
            cur := cur[part]
        }
        if !(cur is Map)
            throw Error("Cfg.Set: parent of '" last "' is not a Map")
        cur[last] := value
    }

    ; --- sugar for project conventions ---

    ; val.<name>.val
    V(name, default := unset) {
        full := "val." name ".val"
        if this.Has(full)
            return this.Get(full)
        if IsSet(default)
            return default
        throw Error("Cfg.V: missing value '" name "'")
    }

    ; hk.<name>.key
    K(name, default := unset) {
        full := "hk." name ".key"
        if this.Has(full)
            return this.Get(full)
        if IsSet(default)
            return default
        throw Error("Cfg.K: missing hotkey '" name "'")
    }

    ; Map: funcName -> key combo
    Hotkeys() {
        out := Map()
        if !this.Has("hk")
            return out
        for funcName, entry in this.Get("hk") {
            if (entry is Map && entry.Has("key"))
                out[funcName] := entry["key"]
        }
        return out
    }

    ; Map<key>.<sub>.val collapsed into Map<key>.<sub>
    ; Useful when you want flat key=>value snapshot of all val.* entries.
    Values() {
        out := Map()
        if !this.Has("val")
            return out
        for name, entry in this.Get("val") {
            if (entry is Map && entry.Has("val"))
                out[name] := entry["val"]
        }
        return out
    }
}

; -----------------------------------------------------------------------------
; Low-level parser/dumper
; -----------------------------------------------------------------------------

json_load(&src, args*) {
    key := "", is_key := false
    stack := [ tree := [] ]
    next := '"{[01234567890-tfn'
    pos := 0

    while ( (ch := SubStr(src, ++pos, 1)) != "" ) {
        if InStr(" `t`n`r", ch)
            continue
        if !InStr(next, ch, true) {
            testArr := StrSplit(SubStr(src, 1, pos), "`n")
            ln := testArr.Length
            col := pos - InStr(src, "`n",, -(StrLen(src)-pos+1))
            msg := Format("{}: line {} col {} (char {})"
            ,   (next == "")      ? ["Extra data", ch := SubStr(src, pos)][1]
              : (next == "'")     ? "Unterminated string starting at"
              : (next == "\")     ? "Invalid \escape"
              : (next == ":")     ? "Expecting ':' delimiter"
              : (next == '"')     ? "Expecting object key enclosed in double quotes"
              : (next == '"}')    ? "Expecting object key enclosed in double quotes or object closing '}'"
              : (next == ",}")    ? "Expecting ',' delimiter or object closing '}'"
              : (next == ",]")    ? "Expecting ',' delimiter or array closing ']'"
              : [ "Expecting JSON value(string, number, [true, false, null], object or array)"
                , ch := SubStr(src, pos, (SubStr(src, pos)~="[\]\},\s]|$")-1) ][1]
            , ln, col, pos)
            throw Error(msg, -1, ch)
        }

        obj := stack[1]
        is_array := (obj is Array)

        if i := InStr("{[", ch) {
            val := (i = 1) ? Map() : Array()
            is_array ? obj.Push(val) : obj[key] := val
            stack.InsertAt(1, val)
            next := '"' ((is_key := (ch == "{")) ? "}" : "{[]0123456789-tfn")
        } else if InStr("}]", ch) {
            stack.RemoveAt(1)
            next := (stack[1] == tree) ? "" : (stack[1] is Array) ? ",]" : ",}"
        } else if InStr(",:", ch) {
            is_key := (!is_array && ch == ",")
            next := is_key ? '"' : '"{[0123456789-tfn'
        } else {
            if (ch == '"') {
                i := pos
                while i := InStr(src, '"',, i+1) {
                    val := StrReplace(SubStr(src, pos+1, i-pos-1), "\\", "\u005C")
                    if (SubStr(val, -1) != "\")
                        break
                }
                if !i ? (pos--, next := "'") : 0
                    continue

                pos := i
                val := StrReplace(val, "\/", "/")
                val := StrReplace(val, '\"', '"')
                , val := StrReplace(val, "\b", "`b")
                , val := StrReplace(val, "\f", "`f")
                , val := StrReplace(val, "\n", "`n")
                , val := StrReplace(val, "\r", "`r")
                , val := StrReplace(val, "\t", "`t")

                i := 0
                while i := InStr(val, "\",, i+1) {
                    if (SubStr(val, i+1, 1) != "u") ? (pos -= StrLen(SubStr(val, i)), next := "\") : 0
                        continue 2
                    xxxx := Abs("0x" . SubStr(val, i+2, 4))
                    if (xxxx < 0x100)
                        val := SubStr(val, 1, i-1) . Chr(xxxx) . SubStr(val, i+6)
                }

                if is_key {
                    key := val, next := ":"
                    continue
                }
            } else {
                val := SubStr(src, pos, i := RegExMatch(src, "[\]\},\s]|$",, pos)-pos)
                if IsInteger(val)
                    val += 0
                else if IsFloat(val)
                    val += 0
                else if (val == "true" || val == "false")
                    val := (val == "true")
                else if (val == "null")
                    val := ""
                else if is_key {
                    pos--, next := "#"
                    continue
                }
                pos += i-1
            }

            is_array ? obj.Push(val) : obj[key] := val
            next := obj == tree ? "" : is_array ? ",]" : ",}"
        }
    }

    return tree[1]
}

json_dump(obj, indent := "", lvl := 1) {
    if IsObject(obj) {
        if !(obj is Array || obj is Map || obj is String || obj is Number)
            throw Error("Object type not supported.", -1, Format("<Object at 0x{:p}>", ObjPtr(obj)))

        if IsInteger(indent) {
            if (indent < 0)
                throw Error("Indent parameter must be a positive integer.", -1, indent)
            spaces := indent, indent := ""
            Loop spaces
                indent .= " "
        }
        indt := ""
        Loop indent ? lvl : 0
            indt .= indent

        is_array := (obj is Array)
        lvl += 1, out := ""
        for k, v in obj {
            if IsObject(k) || (k == "")
                throw Error("Invalid object key.", -1, k ? Format("<Object at 0x{:p}>", ObjPtr(obj)) : "<blank>")
            if !is_array
                out .= escape_str(k) (indent ? ": " : ":")
            out .= json_dump(v, indent, lvl)
                .  (indent ? ",`n" . indt : ",")
        }
        if (out != "") {
            out := Trim(out, ",`n" . indent)
            if (indent != "")
                out := "`n" . indt . out . "`n" . SubStr(indt, StrLen(indent)+1)
        }
        return is_array ? "[" . out . "]" : "{" . out . "}"
    } else if (obj is Number) {
        return obj
    } else {
        return escape_str(obj)
    }

    escape_str(obj) {
        obj := StrReplace(obj, "\", "\\")
        obj := StrReplace(obj, "`t", "\t")
        obj := StrReplace(obj, "`r", "\r")
        obj := StrReplace(obj, "`n", "\n")
        obj := StrReplace(obj, "`b", "\b")
        obj := StrReplace(obj, "`f", "\f")
        obj := StrReplace(obj, "/", "\/")
        obj := StrReplace(obj, '"', '\"')
        return '"' obj '"'
    }
}
