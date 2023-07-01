{
    --------------------------------------------
    Filename: gui.win-scrolltext.spin
    Author: Jesse Burt
    Description: GUI element: scrollable text window
        Provides a scrollable (forward only; no scrollback) text buffer that can be written to
            using standard terminal I/O routines (see spin-standard-library terminal.common.spinh)
        with optional window decoration drawing
    Copyright (c) 2023
    Started Jun 30, 2023
    Updated Jul 1, 2023
    See end of file for terms of use.
    --------------------------------------------

    Requirements:
        * display driver with:
            * putchar() (e.g., com.serial.terminal.ansi.spin)
            * pos_xy()

            Optional, for drawing window decorations:
            * box()
            * str()
            * bgcolor()
            * fgcolor()
    Usage:
        2) Declare an instance of this object. The constants LINEWID_MAX and LINES_MAX can be
            optionally overridden from the top-level object. These define the maximum size
            the text buffer and window can be, and thus have a direct impact on memory usage.
        3) Point it to your display driver's object
        4a) Optionally set up the window position, size, colors, etc
        4b) Optionally draw the window by calling draw_win()
        5) Write text to the buffer using standard terminal I/O from this object
            (if enough text is written to the buffer that it would write past the end,
            it will be "scrolled" in memory a line's worth of text - this can be leveraged
            to display a text logging window)
        6) Draw the text buffer
        7) Build with FlexSpin. Set the preprocessor symbol WIN_TERM_DRV to the filename of
            your display driver. It must be defined with quotes (escaped) surrounding the
            filename (e.g., flexspin -DWIN_TERM_DRV=\"com.serial.terminal.ansi\")


    Example 'Application.spin':
    --
con SER_BAUD = 115_200

obj
    term:   WIN_TERM_DRV                                        ' part of step 1
    win:    "gui.win-scrolltext" | LINEWID_MAX=128, LINES_MAX=5 ' step 2

pub main()
    term.init_def(SER_BAUD)
    term.getchar()                                              ' press a key to start
    term.clear()

    win.init(0, 0, 80, 5, @term)                                ' step 3

    win.set_title_str(@"test")                                  ' step 4a (optional)
    win.set_border_fgcolor(term.GREY)                           ' .
    win.set_border_bgcolor(term.BLUE)                           ' .
    win.set_text_color(term.GREY)                               ' .
    win.draw_win()                                              ' step 4b (optional)

    win.printf1(@"This is a test message %d", cnt)              ' step 5
    win.draw_buffer()                                           ' step 6

    repeat
    --

    build (Linux or similar):
        export SPIN_STD_LIB=/home/myuser/spin-standard-library/library
        flexspin --interp=rom -I $SPIN_STD_LIB -DWIN_TERM_DRV=\"com.serial.terminal.ansi\" Application.spin
    run:
        proploader -t -p /dev/your_prop_device -D baudrate=115200 Application.binary
  
}

CON

    { max size of the text buffer; can be overridden in the parent object file }
    LINEWID_MAX     = 128
    LINES_MAX       = 5
    LOGBUFFSZ_MAX   = LINEWID_MAX * LINES_MAX

#ifndef WIN_TERM_DRV
#define WIN_TERM_DRV "com.serial.terminal.ansi"
#endif

OBJ

    disp=   WIN_TERM_DRV

VAR

    long _instance

    { window and buffer attributes }
    long _bord_fgcolor, _bord_bgcolor, _text_color
    word _sx, _sy, _width, _height, _line_wid, _lines, _line_last, _scroll_sz
    word _title_str

    { some pointers to various parts of the text buffer }
    word _wr_ptr, _ptr_firstline, _ptr_lastline, _ptr_winbuff_end

    byte _winbuff[LOGBUFFSZ_MAX]

pub init(sx, sy, w, h, optr)
' Initialize the window
    set_pos_dims(sx, sy, w, h)                  ' set position, dimensions
    attach(optr)                                ' attach to a display driver
    _wr_ptr := @_winbuff                        ' init pointer to start of text buffer

pub bind = attach_display_driver
pub attach = attach_display_driver
pub attach_display_driver(optr)
' Attach to a display driver
'   optr: pointer to terminal display driver object (e.g., attach_display_driver(@ser) )
    _instance := optr

pub draw_win()
' Draw a window with title string and border
'   x, y: upper-left coords of window
'   w, h: window dimensions (_outer_)
'   brd_fg, brd_bg: window border foreground, background colors
'   ttl_fg: title text fg color
    disp[_instance].box(_sx, _sy, _sx+_width, _sy+_height-1, _bord_fgcolor, _bord_bgcolor, true)
    disp[_instance].bgcolor(_bord_bgcolor)
    disp[_instance].fgcolor(_text_color)

    { optional window title - set in from the left by two columns }
    if ( _title_str )
        disp[_instance].pos_xy(_sx+2, _sy)
        disp[_instance].str(_title_str)

pub draw_buffer() | line_offs, ins_left, ins_top, iptr
' Draw the text buffer
    ins_left := _sx+1
    ins_top := _sy+1

    iptr := @_winbuff
    repeat line_offs from 0 to _line_last
        disp[_instance].pos_xy(ins_left, ins_top+line_offs)
        repeat _line_wid
            disp[_instance].putchar(byte[iptr++])

pub putchar(ch)
' Write a character to the window buffer
    byte[_wr_ptr++] := ch
    if ( _wr_ptr > _ptr_winbuff_end )
        { if we try to write a character past the end of the buffer,
            scroll the buffer up in RAM and set the pointer to the beginning of the last line }
        bytemove(@_winbuff, _ptr_firstline, _scroll_sz)
        _wr_ptr := _ptr_lastline

pub scroll()
' Manually scroll the window buffer up
    bytemove(@_winbuff, _ptr_firstline, _scroll_sz)

pub set_border_bgcolor(c)
' Set window border background color (also used as the window fill color)
    _bord_bgcolor := c

pub set_border_fgcolor(c)
' Set window border foreground color
    _bord_fgcolor := c

pub set_pos_dims(x, y, w, h)
' Set upper-left screen location and dimensions of window
    { window position and dims }
    _sx := x
    _sy := y
    _width := w <# LINEWID_MAX+2                ' limit outer window size to the max text area size
    _height := h <# LINES_MAX+2                 '   plus the borders

    { inner dims }
    _line_wid := _width-2                       ' window width minus the left and right
    _lines := _height-2                         ' window height minus the top and bottom
    _line_last := _lines-1
    _scroll_sz := (_lines-1) * _line_wid

    { set some pointers }
    _ptr_firstline := @_winbuff+_line_wid
    _ptr_lastline := @_winbuff+(_line_wid * _line_last)
    _ptr_winbuff_end := @_winbuff+(_line_wid*_lines)-1

pub set_text_color(c)
' Set text color
    _text_color := c

pub set_title_str(ptr_str)
' Set window titlte (0 to ignore)
    _title_str := ptr_str


#include "terminal.common.spinh"                ' provide the standard terminal routines

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

