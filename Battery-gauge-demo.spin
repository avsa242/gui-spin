{
    --------------------------------------------
    Filename: Battery-gauge-demo.spin
    Author: Jesse Burt
    Description: Demo of the battery gauge GUI widget
    Copyright (c) 2023
    Started Jun 17, 2023
    Updated Jun 17, 2023
    See end of file for terms of use.
    --------------------------------------------
}

CON

    _clkmode    = cfg#_clkmode
    _xinfreq    = cfg#_xinfreq

' -- User-modifiable constants
    LED         = cfg#LED1
    SER_BAUD    = 115_200

    WIDTH       = 240
    HEIGHT      = 240

    CS_PIN      = 4
    SCK_PIN     = 1
    MOSI_PIN    = 2
    DC_PIN      = 3
    RST_PIN     = -1                             ' optional; -1 to disable

' --


OBJ

    cfg:    "boardcfg.flip"
    { define DISP_DRIVER on the commandline: flexspin -DDISP_DRIVER=\"display.lcd.st7735\" }
    lcd:    DISP_DRIVER
    ser:    "com.serial.terminal.ansi"
    time:   "time"
    batt:   "gui.battery-gauge"
    color:  "colors.16bpp"

var

    long _low_color, _ok_color, _low_thresh

PUB main()

    setup()
    batt.attach_display_driver(@lcd)            ' tell the gauge what display driver to use

    lcd.bgcolor( color.BLACK )
    lcd.clear()

    _low_thresh := 20                           ' threshold considered "low battery" (0..100)
    _low_color := color.RED                     ' low battery State of Charge color
    _ok_color := color.WHITE                    ' okay battery SoC color

'    batt.set_posxy(0, 0)                        ' default: 0, 0
'    batt.set_scale(8)                           ' default: 1

    { demo routines - uncomment one }
    draw_horiz_gauge__bar_color_soc()
'    draw_horiz_gauge__outline_color_soc()
'    draw_vert_gauge__bar_color_soc()
'    draw_vert_gauge__outline_color_soc()

pub draw_horiz_gauge__bar_color_soc() | soc
' Draw horizontal gauge:
'   state of charge is reflected by color of bars inside battery icon
    batt.set_outline_color(color.WHITE)
    repeat
        repeat soc from 0 to 100                ' simulated state of charge
            if ( soc < _low_thresh )
                batt.set_bar_color(_low_color)
            else
                batt.set_bar_color(_ok_color)
            batt.draw_horiz(soc)
            time.msleep(250)

pub draw_horiz_gauge__outline_color_soc() | soc
' Draw horizontal gauge:
'   state of charge is reflected by color of battery icon outline
    batt.set_bar_color(color.WHITE)
    repeat
        repeat soc from 0 to 100
            if ( soc < _low_thresh )
                batt.set_outline_color(color.RED)
            else
                batt.set_outline_color(color.WHITE)
            batt.draw_horiz(soc)
            time.msleep(250)

pub draw_vert_gauge__bar_color_soc() | soc
' Draw vertical gauge:
'   state of charge is reflected by color of bars inside battery icon
    batt.set_outline_color(color.WHITE)
    repeat
        repeat soc from 0 to 100
            if ( soc < _low_thresh )
                batt.set_bar_color(_low_color)
            else
                batt.set_bar_color(_ok_color)
            batt.draw_vert(soc)
            time.msleep(250)

pub draw_vert_gauge__outline_color_soc() | soc
' Draw vertical gauge:
'   state of charge is reflected by color of battery icon outline
    batt.set_bar_color(color.WHITE)
    repeat
        repeat soc from 0 to 100
            if ( soc < _low_thresh )
                batt.set_outline_color(color.RED)
            else
                batt.set_outline_color(color.WHITE)
            batt.draw_vert(soc)
            time.msleep(250)


PUB setup()

    ser.start(SER_BAUD)
    time.msleep(30)
    ser.clear()
    ser.strln(string("Serial terminal started"))

    if ( lcd.startx(CS_PIN, SCK_PIN, MOSI_PIN, DC_PIN, RST_PIN, WIDTH, HEIGHT, 0) )
        ser.strln(@"ST77xx driver started")
        lcd.preset_adafruit_1p3_240x240_land_up()
    else
        ser.strln(@"ST77xx driver failed to start - halting")
        repeat


DAT
{
Copyright 2023 Jesse Burt

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

