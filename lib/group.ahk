;; Group keys - include at the very END of a macro, after all its own labels.
;; A label here ends the auto-execute section, so it must not be included earlier.
;; Every handler starts with `Suspend, Permit`, so it keeps working while the group is paused.
;; The keys themselves are bound by lib\macro.ahk.

MiscReloadMacro:
    Suspend, Permit
    Joiner.reload()
return

MiscUnloadMacro:
    Suspend, Permit
    Joiner.exit()
return

MiscPause:
    Suspend, Permit
    Joiner.pause(!Joiner.paused) ; toggle: Joiner.pause() defaults to pause on
return
