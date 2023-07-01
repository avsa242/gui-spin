{
    --------------------------------------------
    Filename: ScrollTextWin-Demo.spin
    Author: Jesse Burt
    Description: Demo of the scrollable text window object
    Copyright (c) 2023
    Started Jun 30, 2023
    Updated Jul 1, 2023
    See end of file for terms of use.
    --------------------------------------------

    See gui.win-scrolltext.spin for usage instructions
}

CON

    _clkmode    = cfg#_clkmode
    _xinfreq    = cfg#_xinfreq

' -- User-defined constants
    SER_BAUD    = 115_200

' --

{ default to the ANSI serial terminal driver if another one isn't specified }
#ifndef WIN_TERM_DRV
#define WIN_TERM_DRV "com.serial.terminal.ansi"
#endif
OBJ

    cfg:    "boardcfg.flip"
    ser:    WIN_TERM_DRV
    time:   "time"
    win:    "gui.win-scrolltext" | LINEWID_MAX = 128, LINES_MAX = 6

PUB main() | x, y, w, h, i

    setup()

    x := 0
    y := 0
    w := 35                                     ' text line length will be w-2 (window border)
    h := 7                                      ' text # of lines will be h-2 (window border)
    win.init(x, y, w, h, @ser)                  ' set window pos, size, and attach to serial object

    win.set_title_str(@"Test window")           ' set some attributes of the window
    win.set_border_fgcolor(ser.GREY)
    win.set_border_bgcolor(ser.BLUE)
    win.set_text_color(ser.GREY)
    win.draw_win()                              ' draw the window (optional)

    i := 0
    repeat
        { Write some text to the window buffer and then draw it. Currently for a "text log"-style
            output, the text should be be padded to the text window's width so they're all the
            same length (the scrolling won't look correct otherwise }
        win.printf1(@"this is a test message #%9.9d", i++)
        win.draw_buffer()

PUB setup()

    ser.start(SER_BAUD)
    time.msleep(30)
    ser.clear
    ser.strln(string("Serial terminal started"))

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

