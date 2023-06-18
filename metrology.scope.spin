{
    --------------------------------------------
    Filename: metrology.scope.spin
    Description: Oscilloscope display widgets
    Author: Jesse Burt
    Copyright (c) 2023
    Created: May 26, 2023
    Updated: Jun 17, 2023
    See end of file for terms of use.
    --------------------------------------------

    Requirements:
        a display driver that provides the following interfaces:
            con MAX_COLOR = xxx (xxx is the maximum possible color value the driver supports)
            pub box(sx, sy, ex, ey, color, fill_flag)
            pub plot(x, y, color)
        build-time symbol DISP_DRIVER defined with the display driver filename in escaped quotes
        Example:
            flexspin -DDISP_DRIVER=\"display.lcd.st7735\" -DST7789 -DGFX_DIRECT app.spin
            (define DISP_DRIVER as the driver filename
    Operational overview:
        This object is first initialized with:
            * screen position
            * scope dimensions
            * pointer to display driver
            * pointer to sample(s) to plot
            * length of the sample buffer
        The scope can then be drawn in buffered or unbuffered mode.

        Example:

        obj

            lcd:    DISP_DRIVER
            scope:  "metrology.scope"

        var

            long _sample

        pub main() | x, y, width, height, obj_ptr, ptr_samples, len

            ' NOTE: variables provided only to show the function of each parameter
            x := y := 0
            width := height := 100
            obj_ptr := @lcd
            ptr_samples := @_sample             ' point to sample(s)
            len := 1                            ' length of sample buffer
            scope.init(x, y, width, height, obj_ptr, ptr_samples, len)

}
obj

    disp= DISP_DRIVER

var

    long _disp_obj

    long _ptr_smp, _len                         ' pointer to sample buffer, and length of

    long _outline_color, _plot_color, _bg_color

    word _sx, _sy, _width, _height              ' scope position, dimensions
    word _bottom, _right                        ' maximum coordinate edges
    word _ref_lvl
    byte _vscale

pub init(x, y, wid, ht, optr, ptr_samples, len)
' Initialize oscilloscope object
'   (x, y): oscilloscope position (upper-left)
'   (wid, ht): oscilloscope window dimensions, in pixels
'   optr: pointer to display driver object
'   ptr_samples: pointer to samples to plot
'   len: length of sample buffer
    attach(optr)
    _ptr_smp := ptr_samples
    _len := len-1
    set_pos_dims(x, y, wid, ht)

    { default to black background with white outline and plot colors }
    _outline_color := disp[_disp_obj].MAX_COLOR
    _plot_color := disp[_disp_obj].MAX_COLOR
    _bg_color := 0
    _vscale := 1

pub attach = attach_display_driver
pub attach_display_driver(ptr)
' Attach to a display driver's drawing primitive functions
'   ptr: pointer to display driver's drawing functions
    _disp_obj := ptr

pub draw_inv_y(ref_lvl, c) | x
' Draw an oscilloscope plot with inverted y-axis
'   ref_lvl: reference level for plot
'   c: color to plot
    disp[_disp_obj].box(_sx+1, _sy+1, _right-1, _bottom-1, _bg_color, true)
    repeat x from 0 to _len
        disp[_disp_obj].plot(   _sx + x, ...
                                _sy + _ref_lvl + (long[_ptr_smp][x] * _vscale), ...
                                _plot_color )

pub draw_inv_y_framed() | x
' Draw an oscilloscope plot, framed
'   ref_lvl: reference level for plot
'   c: color to plot
    disp[_disp_obj].box(_sx, _sy, _right, _bottom, _outline_color, false)
    disp[_disp_obj].box(_sx+1, _sy+1, _right-1, _bottom-1, _bg_color, true)
    repeat x from 0 to _len
        disp[_disp_obj].plot(   _sx + x, ...
                                _sy + _ref_lvl + (long[_ptr_smp][x] * _vscale), ...
                                _plot_color )

pub draw() | x
' Draw an oscilloscope plot
'   ref_lvl: reference level for plot
'   c: color to plot
    disp[_disp_obj].box(_sx, _sy, _right, _bottom, _bg_color, true)
    repeat x from 0 to _len
        disp[_disp_obj].plot(   _sx + x, ...
                                _bottom-_ref_lvl - (long[_ptr_smp][x] * _vscale), ...
                                _plot_color )

pub draw_buffer_framed() | x
' Draw an oscilloscope plot (sweep buffer), framed
    disp[_disp_obj].box(_sx, _sy, _right, _bottom, _outline_color, false)
    disp[_disp_obj].box(_sx+1, _sy+1, _right-1, _bottom-1, _bg_color, true)
    repeat x from 0 to _len
        disp[_disp_obj].plot(   _sx + x, ...
                                _bottom-_ref_lvl - (long[_ptr_smp][x] * _vscale), ...
                                _plot_color )

pub draw_one() | x
' Draw an oscilloscope plot (sweep full scope width, each dot re-reads sample pointer)
    disp[_disp_obj].box(_sx+1, _sy+1, _right-1, _bottom-1, _bg_color, true)
    repeat x from _sx+1 to _right-1
        disp[_disp_obj].plot(   _sx + x, ...
                                _bottom - _ref_lvl - (long[_ptr_smp] * _vscale), ...
                                _plot_color )

pub draw_one_framed() | x
' Draw an oscilloscope plot (sweep full scope width, each dot re-reads sample pointer)
    disp[_disp_obj].box(_sx, _sy, _right, _bottom, _outline_color, false)
    disp[_disp_obj].box(_sx+1, _sy+1, _right-1, _bottom-1, _bg_color, true)
    repeat x from _sx+1 to _right-1
        disp[_disp_obj].plot(   _sx + x, ...
                                _bottom - _ref_lvl - (long[_ptr_smp] * _vscale), ...
                                _plot_color )

pub set_bgcolor(c)
' Set oscilloscope window background/fill color
    _bg_color := c

pub set_dims(w, h)
' Set oscilloscope dimensions, in pixels
'   w: width
'   h: height
    _width := w
    _height := h

pub set_outline_color(c)
' Set outline color for framed oscilloscope plots
    _outline_color := c

pub set_plot_color(c)
' Set oscilloscope plot color
    _plot_color := c

pub set_pos(x, y)
' Set oscilloscope position
    _sx := x
    _sy := y

pub set_pos_dims(x, y, w, h)
' Set position and dimensions of oscilloscope plot
    _sx := x
    _sy := y
    _width := w
    _height := h
    _bottom := (y + h)-1
    _right := (x + w)-1

pub set_ref_level(l)
' Set reference level for oscilloscope plot
    _ref_lvl := l

pub set_vscale(s)
' Set vertical scale factor
    _vscale := s

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

