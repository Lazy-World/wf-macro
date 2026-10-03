;; Shared Misc subroutines: reload / unload / pause.
;; Include at the very END of a script (after all its own labels).
;; reload / exitapp / Suspend are auto-exempt from Suspend, so these
;; hotkeys keep working while the macro is paused.

MiscReloadMacro:
    reload
return

MiscUnloadMacro:
    exitapp
return

MiscPause:
    Suspend, Toggle
    Pause, Toggle, 1
    if (A_IsSuspended) {
        pausedBody := status.text
        status.text := "PAUSE"
    } else {
        status.text := pausedBody
    }
return
