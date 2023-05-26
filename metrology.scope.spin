{
    --------------------------------------------
    Filename: metrology.scope.spin
    Description: Oscilloscope display widgets
    Author: Jesse Burt
    Copyright (c) 2023
    Created: May 26, 2023
    Updated: May 26, 2023
    See end of file for terms of use.
    --------------------------------------------

    Requirements:
        a display driver (declared in the parent object) with box() and plot() functions
            (see attach() for details)
    Operational overview:
        This object is first initialized using the init() function, giving it the dimensions
            and screen positioning information for the oscilloscope display.
        In addition, it is pointed to the display driver object's drawing primitive functions
            box() and plot() during initialization. It then calls these functions indirectly
            to draw the oscilloscope display.
        To actually draw the oscilloscope, call one of the draw_*() methods.
}

var

    long box, plot                              ' pointers to display driver draw functions

    long _ptr_smp, _len                         ' pointer to sample buffer, and length of

    word _sx, _sy, _width, _height              ' scope position, dimensions
    word _bottom, _right                        ' maximum coordinate edges

pub init(x, y, wid, ht, fptr, ptr_samples, len)
' Initialize oscilloscope object
'   (x, y): oscilloscope position (upper-left)
'   (wid, ht): oscilloscope window dimensions, in pixels
'   fptr: pointer to display driver's drawing primitive functions (box(), line(), plot())
'   ptr_samples: pointer to samples to plot
'   len: length of sample buffer
    set_pos(x, y)
    set_dims(wid, ht)
    _bottom := (y + ht)
    _right := (x + wid)
    attach(fptr)
    _ptr_smp := ptr_samples
    _len := len-1

pub attach(ptr)
' Attach to a display driver's drawing primitive functions
'   ptr: pointer to display driver's drawing functions
'   Source structure and interfaces MUST be:
'       ptr+0: @box(sx, sy, ex, ey, color, fill_flag)
'       ptr+4: @plot(x, y, color)
    longmove(@box, ptr, 2)

pub draw_inv_y(ref_lvl, c) | x
' Draw an oscilloscope plot with inverted y-axis
'   ref_lvl: reference level for plot
'   c: color to plot
    repeat x from 0 to _len
        plot(_sx+x, _sy+ref_lvl+long[_ptr_smp][x], c)

pub draw_inv_y_framed(ref_lvl, c) | x
' Draw an oscilloscope plot, framed
'   ref_lvl: reference level for plot
'   c: color to plot
    box(_sx, _sy, _right, _bottom, 1, false)
    repeat x from 0 to _len
        plot(_sx+x, _sy+ref_lvl+long[_ptr_smp][x], c)

pub draw(ref_lvl, c) | x
' Draw an oscilloscope plot
'   ref_lvl: reference level for plot
'   c: color to plot
    repeat x from 0 to _len
        plot(_sx+x, _bottom-ref_lvl-long[_ptr_smp][x], c)

pub draw_framed(ref_lvl, c) | x
' Draw an oscilloscope plot, framed
'   ref_lvl: reference level for plot
'   c: color to plot
    box(_sx, _sy, _right, _bottom, 1, false)
    repeat x from 0 to _len
        plot(_sx+x, _bottom-ref_lvl-long[_ptr_smp][x], c)

PUB set_pos(x, y)
' Set oscilloscope position
    _sx := x
    _sy := y

PUB set_dims(w, h)
' Set oscilloscope dimensions, in pixels
'   w: width
'   h: height
    _width := w
    _height := h

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

