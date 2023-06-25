{
    --------------------------------------------
    Filename: metrology.scope.spin
    Description: Oscilloscope display widgets
    Author: Jesse Burt
    Copyright (c) 2023
    Created: May 26, 2023
    Updated: Jun 25, 2023
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

    long _htime
    long _trig_lvl

    word _sx, _sy, _width, _height              ' scope position, dimensions
    word _in_l, _in_t, _in_r, _in_b
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

pub draw_buffer() | x, r
' Draw an oscilloscope plot (sweep buffer)
'   ref_lvl: reference level for plot
'   c: color to plot
    disp[_disp_obj].box(_sx, _sy, _right, _bottom, _bg_color, true)
    r := _in_b - _ref_lvl                       ' pre-calc vertical offset

    repeat x from 0 to _len
        disp[_disp_obj].plot(   _in_l + x, ...
                                r - (long[_ptr_smp][x] * _vscale), ...
                                _plot_color )

pub draw_buffer_framed() | x, r
' Draw an oscilloscope plot (sweep buffer), framed
    disp[_disp_obj].box(_sx, _sy, _right, _bottom, _outline_color, false)
    disp[_disp_obj].box(_in_l, _in_t, _in_r, _in_b, _bg_color, true)
    r := _in_b - _ref_lvl

    repeat x from 0 to _len
        disp[_disp_obj].plot(   _in_l + x, ...
                                r - (long[_ptr_smp][x] * _vscale), ...
                                _plot_color )

pub draw_one() | x, r
' Draw an oscilloscope plot (sweep full scope width, each dot re-reads sample pointer)
'    disp[_disp_obj].box(_in_l, _in_t, _in_r, _in_b, _bg_color, true)
    r := _in_b - _ref_lvl
    repeat x from _in_l to _in_r
'        disp[_disp_obj].line(   x+1, _in_t, x+1, _in_b, 0 ) ' looks nicer than the box eraser, but much slower
        disp[_disp_obj].plot(   x, ...
                                r - (long[_ptr_smp] * _vscale), ...
                                _plot_color )
        waitcnt(cnt+_htime)

pub draw_one_framed() | x, r
' Draw an oscilloscope plot (sweep full scope width, each dot re-reads sample pointer)
    disp[_disp_obj].box(_sx, _sy, _right, _bottom, _outline_color, false)
    disp[_disp_obj].box(_in_l, _in_t, _in_r, _in_b, _bg_color, true)
    r := _in_b - _ref_lvl

    repeat x from _in_l to _in_r
        disp[_disp_obj].plot(   x, ...
                                r - (long[_ptr_smp] * _vscale), ...
                                _plot_color )

pub draw_one_triggered_hi() | x, r
' Draw an oscilloscope plot (sweep full scope width, each dot re-reads sample pointer)
'    disp[_disp_obj].box(_in_l, _in_t, _in_r, _in_b, _bg_color, true)
    r := _in_b - _ref_lvl
    repeat until long[_ptr_smp] => _trig_lvl
    repeat x from _in_l to _in_r
        disp[_disp_obj].plot(   x, ...
                                r - (long[_ptr_smp] * _vscale), ...
                                _plot_color )
        waitcnt(cnt+_htime)

pub dec_horiz_time()
' Decrease horizontal timescale
    _htime := 1000 #> _htime-1_000

pub dec_ref_level()
' Decrease reference level (clamped to minimum of 0)
    _ref_lvl := 0 #> (_ref_lvl-1)

pub dec_vscale()
' Decrease vertical scaling (clamped to minimum of 1)
    _vscale := 1 #> (_vscale-1)

pub inc_horiz_time()
' Increase horizontal timescale
    _htime += 1_000

pub inc_ref_level()
' Increase reference level
    _ref_lvl++

pub inc_vscale()
' Increase vertical scaling
    _vscale++

pub set_bgcolor(c)
' Set oscilloscope window background/fill color
    _bg_color := c

pub set_dims(w, h)
' Set oscilloscope dimensions, in pixels
'   w: width
'   h: height
    _width := w
    _height := h

pub set_horiz_time(v)
' Set horizontal timescale
    _htime := v

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
    _in_l := _sx+1
    _in_r := _right-1
    _in_t := _sy+1
    _in_b := _bottom-1

pub set_ref_level(l)
' Set reference level for oscilloscope plot
    _ref_lvl := l

pub set_trigger_level(l)
' Set threshold for triggering oscilloscope plot
    _trig_lvl := l

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

