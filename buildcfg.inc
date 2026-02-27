; Build configuration for Plus/4 demo part

; ------------------------------------------------------------
; Build mode selection (set one of these to 1)
; ------------------------------------------------------------
STANDALONE_TEST = 1
DEMO_IOLIB_EXO  = 0

; ------------------------------------------------------------
; Player zero-page base (default in legacy player was $db)
; Moved to $70 to avoid siziolib/exomizer ZP usage.
; ------------------------------------------------------------
MUSIC_ZP_BASE = $70

; ------------------------------------------------------------
; Runtime constants
; ------------------------------------------------------------
PART_DURATION_FRAMES = 50*48   ; ~48s at 50 Hz
FLASH_STEPS = 3
