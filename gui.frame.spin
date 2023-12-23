{
    --------------------------------------------
    Filename: gui.frame.spin
    Author: Jesse Burt
    Description: Object for managing display frames or surfaces
        (EVE BT81x display-specific implementation)
    Copyright (c) 2023
    Started Jun 3, 2023
    Updated Dec 23, 2023
    See end of file for terms of use.
    --------------------------------------------

    Basic usage:

    In the parent object/application, declare an instance of the EVE display driver, like:

        OBJ eve: "display.lcd.bt81x"

    Then declare an instance of this object for every frame/surface that needs to be rendered.
    For example, suppose the parent object needs to draw two separate frames:

        CON #0, LEFT_FRAME, RIGHT_FRAME     ' <- 0, 1
        OBJ frame[2]: "gui.frame"

    Then set up each instance with the position, dimensions, and EVE driver pointer:

        frame[LEFT_FRAME].init(0, 0, 300, 480, @eve)
        frame[RIGHT_FRAME].init(400, 0, 300, 480, @eve)

    Finally, call draw() somewhere inside your display list:

        repeat
            eve.wait_rdy()
            eve.dl_start()
            eve.clear_color(0, 0, 0)
            eve.clear()
            frame[LEFT_FRAME].draw()
            frame[RIGHT_FRAME].draw()
            '
            '... other display list commands here ...
            '
            eve.dl_end()

}

con

    { frame structure }
    SX      = 0
    SY      = 1
    WIDTH   = 2
    HEIGHT  = 3
    EX      = 4
    EY      = 5

obj

    disp=   "display.lcd.bt81x"                 ' "meta"-instance of EVE LCD driver

var

    long _disp_obj                              ' instance of display driver object
    long _drw_func                              ' pointer to optional function call within draw()
    long _bg_color                              ' frame background color
    word _surface[6]                            ' frame/surface structure
    word _text                                  ' frame text (optional)

    { positions and dimensions }
    word _sx, _sy                               ' upper-left coordinates
    word _drw_sx, _drw_sy                       ' drawable area start (start coords + grid size)
    word _drw_ex, _drw_ey                       ' drawable area end (end coords - grid size)
    word _drw_w, _drw_h                         ' drawable area size
    word _grid_sz                               ' set minimum spacing between things

    byte _text_sz

var long _null_ptr                              ' pointer to null()
pub null()
' This is not a top-level object

pub init(x, y, w, h, ptr_disp): p
' Initialize frame
'   (x, y): upper-left corner of the frame
'   (w, h): dimensions of the frame, in pixels
'   ptr_disp: pointer to the instance of a display driver
    _surface[SX] := _sx := x
    _surface[SY] := _sy := y
    _surface[WIDTH] := w
    _surface[HEIGHT] := h
    _surface[EX] := x + w
    _surface[EY] := y + h
    _bg_color := 0
    _grid_sz := 10
    _drw_sx := x+_grid_sz
    _drw_sy := y+_grid_sz
    _drw_ex := (x+w)-_grid_sz
    _drw_ey := (y+h)-_grid_sz
    _drw_w := _drw_ex-_drw_sx
    _drw_h := _drw_ey-_drw_sy
    _disp_obj := ptr_disp
    _text_sz := 26
    _null_ptr := @null                          ' point to null() by default
    _drw_func := _null_ptr
    return @_surface

pub bottom(): b
' Get bottom coordinate of frame, minus the grid size
    return _surface[EY]-_grid_sz

pub clear_draw_function()
' Clear the optional _drw_func function pointer
    _drw_func := @null

pub draw()
' Use the display driver to draw the frame
'   NOTE: init() must be called with the instance of a graphics driver
    disp[_disp_obj].widget_fgcolor(_bg_color)
    disp[_disp_obj].button( _surface[SX], _surface[SY], _surface[WIDTH], _surface[HEIGHT], ...
                            31, 0, 0)
    if ( _text )
        disp[_disp_obj].str(_drw_sx, _drw_sy, _text_sz, 0, _text)

    if ( _drw_func <> _null_ptr )
        _drw_func()

    { clip the display to within the drawable area }
    disp[_disp_obj].scissor_rect( _drw_sx, _drw_sy, _drw_w, _drw_h )

    { draw bounding box (for debugging only) }
#ifdef DEBUG
    disp[_disp_obj].box( _drw_sx, _drw_sy, _drw_ex, _drw_ey, 0)
#endif

pub get_ex(): x
' Get ending X coordinate of surface
    return _surface[EX]

pub get_ey(): y
' Get ending Y coordinate of surface
    return _surface[EY]

pub get_h(): h
' Get the height of the frame
    return _surface[HEIGHT]

pub get_sx(): x
' Get the x/upper-left coordinate of the frame
    return _surface[SX]

pub get_sy(): y
' Get the y/upper-left coordinate of the frame
    return _surface[SY]

pub get_w(): w
' Get the width of the frame
    return _surface[WIDTH]

pub left(): b
' Get left coordinate of frame, plus the grid size
    return _surface[SX]+_grid_sz

pub right(): b
' Get right coordinate of frame, minus the grid size
    return _surface[EX]-_grid_sz

pub set_bgcolor(c)
' Set the background color of the frame
    _bg_color := c

pub set_draw_function(ptr)
' Set pointer to optional external function to call when draw() is called
    _drw_func := ptr

pub set_h(h)
' Set the height of the frame
    _surface[HEIGHT] := h

pub set_sx(x)
' Set the x/upper-left coordinate of the frame
    _surface[SX] := _sx := x
    _surface[EX] := x+_surface[WIDTH]
    _drw_sx := x + _grid_sz
    _drw_ex := (x + _surface[WIDTH])-_grid_sz

pub set_sy(y)
' Set the y/upper-left coordinate of the frame
    _surface[SY] := _sy := y
    _surface[EY] := y+_surface[HEIGHT]
    _drw_sy := y + _grid_sz
    _drw_ey := (y + _surface[HEIGHT])-_grid_sz

pub set_text(t)
' Set pointer to (optional) frame title text
'   (set to 0 to ignore)
    _text := t

pub set_text_size(sz)
' Set title text size
    _text_sz := sz

pub set_w(w)
' Set the width of the frame
    _surface[WIDTH] := w

pub top(): b
' Get top coordinate of frame, plus the grid size
    return _surface[SY]+_grid_sz

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


