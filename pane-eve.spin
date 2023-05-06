CON

    _clkmode    = cfg#_clkmode
    _xinfreq    = cfg#_xinfreq

' -- User-modifiable constants
    LED         = cfg#LED1
    SER_BAUD    = 115_200

    { EVE configuration }
    CS_PIN      = 0
    SCK_PIN     = 1
    MOSI_PIN    = 2
    MISO_PIN    = 3
    RST_PIN     = -1                             ' optional; -1 to disable

    BRIGHTNESS  = 128
' --

OBJ

    cfg:    "boardcfg.flip"
    disp:   "display.lcd.bt81x"
    ser:    "com.serial.terminal.ansi"
    time:   "time"

CON

    GREY            = $7f_7f_7f
    GREEN           = $00_ff_00
    RED             = $ff_00_00
    YELLOW          = $ff_ff_00
    WHITE           = $ff_ff_ff
    GREY55          = $55_55_55

#include "eve3-lcdtimings.800x480.spinh"

OBJ

    pane:   "gui.pane" | NR_PANES = 2

CON

    #0, PANE1, PANE2

PUB main() | p

    setup

    pane.init()
    pane.set_id_all(PANE1)

    pane.set_pos(PANE1, 0, 0)
    pane.set_dims(PANE1, 398, 470)
    pane.set_title_str(PANE1, @"PANE1 (OUTLINE)")
    pane.set_title_color(PANE1, $ff_ff_ff)
    pane.set_title_ht(PANE1, 26)
    pane.set_filled(PANE1, false)
    pane.set_fill_color(PANE1, $7f_7f_7f)

    pane.set_pos(PANE2, 401, 0)
    pane.set_dims(PANE2, 398, 470)
    pane.set_title_str(PANE2, @"PANE 2 (FILLED)")
    pane.set_title_color(PANE2, $ff_ff_ff)
    pane.set_title_ht(PANE2, disp.VGA8X12_ROM)
    pane.set_filled(PANE2, true)
    pane.set_fill_color(PANE2, $3f_3f_3f)

    p := disp.OPT_3D
    repeat
        disp.wait_rdy()
        disp.dl_start()
            disp.clear_color(0, 0, 0)
            disp.clear()
            draw_pane_clipped(PANE1)
            disp.tag_attach(1)
            disp.button(320, 40, 100, 70, 28, p, @"Clip test")
            if ( disp.tag_active == 1 )
                p := disp.OPT_FLAT
            else
                p := disp.OPT_3D
            disp.tag_attach(2)
            disp.scissor_rect(0, 0, WIDTH, HEIGHT)
            draw_pane(PANE2)
        disp.dl_end()

pub draw_pane(pane_nr)
' Draw window pane
'   pane_nr: pane definition index (use caution: make sure the number is valid)
    { use the button() widget to draw the window pane, since it's inexpensive }
    disp.widget_fgcolor(pane.fill_color(pane_nr))
    disp.button(pane.get_sx(pane_nr), pane.get_sy(pane_nr), pane.get_wd(pane_nr), ...
                pane.get_ht(pane_nr), 31, disp.OPT_FLAT, @"")

    ifnot ( pane.filled(pane_nr) )
        { give the pane an 'outlined' look by filling the inside with the background color }
        disp.widget_fgcolor(0)  'xxx hardcoded black; use some global bgcolor var
        disp.button(pane.get_sx(pane_nr)+1, pane.get_sy(pane_nr)+1, pane.get_wd(pane_nr)-2, ...
                    pane.get_ht(pane_nr)-2, 31, disp.OPT_FLAT, @"")

    { draw the (optional) pane title text - position it past the corner radius of the pane }
    if ( pane.title_string(pane_nr) )
        disp.color_rgb24(pane.title_color(pane_nr))
        disp.str(   pane.get_sx(pane_nr)+10, pane.get_sy(pane_nr), pane.title_height(pane_nr), ...
                    0, pane.title_string(pane_nr) )

pub draw_pane_clipped(pane_nr)
' Draw window pane
'   pane_nr: pane definition index (use caution: make sure the number is valid)
    { use the button() widget to draw the window pane, since it's inexpensive }
    disp.widget_fgcolor(pane.fill_color(pane_nr))
    disp.button(pane.get_sx(pane_nr), pane.get_sy(pane_nr), pane.get_wd(pane_nr), ...
                pane.get_ht(pane_nr), 31, disp.OPT_FLAT, @"")

    ifnot ( pane.filled(pane_nr) )
        { give the pane an 'outlined' look by filling the inside with the background color }
        disp.widget_fgcolor(0)  'xxx hardcoded black; use some global bgcolor var
        disp.button(pane.get_sx(pane_nr)+1, pane.get_sy(pane_nr)+1, pane.get_wd(pane_nr)-2, ...
                    pane.get_ht(pane_nr)-2, 31, disp.OPT_FLAT, @"")

    { draw the (optional) pane title text - position it past the corner radius of the pane }
    if ( pane.title_string(pane_nr) )
        disp.color_rgb24(pane.title_color(pane_nr))
        disp.str(   pane.get_sx(pane_nr)+10, pane.get_sy(pane_nr), pane.title_height(pane_nr), ...
                    0, pane.title_string(pane_nr) )

    disp.scissor_rect(pane.get_sx(pane_nr)+1, pane.get_sy(pane_nr)+pane.title_height(pane_nr), ...
                        pane.get_wd(pane_nr)-1, pane.get_ht(pane_nr)-1)

PUB setup()

    ser.start(SER_BAUD)
    time.msleep(30)
    ser.clear()
    ser.strln(string("Serial terminal started"))

    if disp.startx(CS_PIN, SCK_PIN, MOSI_PIN, MISO_PIN, RST_PIN, @_disp_setup)
        ser.strln(@"EVE driver started")

    disp.preset_high_perf()                       ' defaults, but max clock
    disp.set_brightness(BRIGHTNESS)

{
TERMS OF USE: MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
}
