;; Shared Misc subroutines: reload / unload / pause.
;; Include at the very END of a script (after all its own labels).
;; Each one acts on every running macro at once (see lib\joiner.ahk).
;; `Suspend, Permit` keeps these hotkeys working while the macros are paused.

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
    Joiner.pause(!Joiner.paused)
return
