; Build configuration for Plus/4 demo part (as65 syntax)

; Build modes (set with 0/1)
STANDALONE_TEST  = 1
DEMO_IOLIB_EXO   = 0

; player zero-page base (legacy default was $db)
MUSIC_ZP_BASE    = $70

; runtime constants
PART_DURATION_LO = $60    ; 2400 frames (~48 sec @ 50Hz)
PART_DURATION_HI = $09
FLASH_STEPS2     = 6        ; 3 flashes = 6 toggles
