{
    --------------------------------------------
    Filename: PropBOE-Spectrum-SSD130x.spin
    Description: Spectrum plot of the microphone
        on a Propeller Board of Education.
        Display: SSD130x OLED (1306, 1309)
        Using the spectrum plot widget object
    Author: Jesse Burt
    Copyright (c) 2023
    Created: Jul 3, 2023
    Updated: Jul 3, 2023
    See end of file for terms of use.
    --------------------------------------------

    Usage:
        define preprocessor symbol DISP_DRIVER defined with the display driver filename in
            escaped quotes when building, e.g.,:

    flexspin -DDISP_DRIVER=\"display.oled.ssd130x\" -DSSD130X_SPI -DSSD1309 PropBOE-SpecPlot-SSD130x.spin
}

CON

    _clkmode    = cfg#_clkmode
    _xinfreq    = cfg#_xinfreq

' -- User-modifiable constants
    LED         = cfg#LED1
    SER_BAUD    = 115_200

    { SSD130x configuration }
    CS_PIN      = 5'11
    SCK_PIN     = 1'12
    MOSI_PIN    = 2'13
    DC_PIN      = 4'14
    RST_PIN     = 3'15                             ' optional; -1 to disable

    WIDTH       = 128
    HEIGHT      = 64
' --

OBJ

    cfg:    "boardcfg.flip"
    disp:   "display.oled.ssd130x"
    ser:    "com.serial.terminal.ansi"
    time:   "time"
    spec:   "metrology.spectrum"
    aud:    "audio.input.mic-sigmadelta"

VAR

    long _smp
    byte _fb[WIDTH*HEIGHT/8]

PUB main() | s, e

    setup()

    aud.start(@_smp)

    disp.bgcolor(0)
    disp.clear()

    spec.init(0, 0, WIDTH, HEIGHT, @disp, @_smp, 1)
    spec.set_outline_color(1)
    spec.set_plot_color(1)
    spec.set_bgcolor(0)
    spec.set_xscale(1)
    repeat
        disp.clear()
        fill_input()
'        s := cnt
        spec.calc_dft()
'        e := cnt-s
'        ser.printf1(@"dft=%dus\n\r", e/80)
        spec.draw_plot()
'        spec.draw_line()
        disp.show()

PUB {++opt(0)}fill_input() | r, i, k
' Fill the FFT input with samples
    r := spec.ptr_real()
    i := spec.ptr_imag()

    repeat k from 0 to (spec.FFT_SZ-1)
        long[r][k] := _smp
        long[i][k] := 0

PUB setup()

    ser.start(SER_BAUD)
    time.msleep(30)
    ser.clear()
    ser.strln(string("Serial terminal started"))

    if disp.startx(CS_PIN, SCK_PIN, MOSI_PIN, DC_PIN, RST_PIN, WIDTH, HEIGHT, @_fb)
        ser.strln(@"SSD130x driver started")
    else
        ser.strln(@"disp driver failed")
        repeat

    disp.preset_128x()
    disp.mirror_h(true)
    disp.mirror_v(true)


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

