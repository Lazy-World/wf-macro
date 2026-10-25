; @Tooltip Пока клавиша зажата, 2-я способность применяется повторно. В умном режиме нажатие доходит до игры
; @Bind
StartStopKey = LButton ; Ability 2 spam

; @Tooltip Умный режим: 2-я способность по иконке элемента у счётчика патронов и спам 4-й. Выключен - 2-я способность по таймеру
; @Boolean
SmartMode := false ; Smart mode

; @If !SmartMode
; @Tooltip Интервал между повторными применениями 2-й способности, пока клавиша зажата (в миллисекундах)
; @Value
AbilityInterval := 800 ; Ability 2 interval, ms

; @If SmartMode
; @Tooltip Элемент патронов от 2-й способности: пока клавиша зажата и иконка элемента пропала в точке патронов, 2-я применяется снова
; @Select ["Electricity", "Blast"]
AmmoElement := "Blast"       ; Ammo element

; @If SmartMode
; @Tooltip Точка на иконке элемента слева от счётчика патронов (двузначного: при одной цифре иконка сдвигается). Координаты для 1920x1080: SOBEK - 1811, 953 (Electricity), BOAR - 1805, 955 (Blast), KOHM - 1780, 955 (Blast)
; @MouseMove
AmmoSpot := [2619, 1103] ; Ammo pixel

; @Title Ability 4

; @If SmartMode
; @Tooltip 4-я способность спамится, пока зажата её клавиша
; @Boolean
AutoFourth := false ; Ability 4 spam

; @If AutoFourth
; @Tooltip Пока клавиша зажата, 4-я способность спамится. Нажатие доходит до игры
; @Bind
FourthKey = RButton ; Hold to spam ability 4

; @Title Misc

; @Tooltip Перезагрузка макроса
; @Bind
MiscReloadMacroKey = Insert ; Reload macro

; @Tooltip Выключить макрос
; @Bind
MiscUnloadMacroKey = Del ; Unload macro

; @Tooltip Пауза / возобновление макроса
; @Bind
MiscPauseKey = F11 ; Pause / resume macro