{
    --------------------------------------------
    Filename: gui.button-eve.spin
    Author: Jesse Burt
    Description: EVE button management
    Copyright (c) 2023
    Started May 29, 2023
    Updated Jun 3, 2023
    See end of file for terms of use.
    --------------------------------------------
}

con

    { button states }
    UP          = 0
    RELEASED    = UP
    DOWN        = 1
    PUSHED      = DOWN

var

    long _disp_obj                              ' point to instance of EVE LCD driver
    long _action, _released_action              ' action (function) bound to button press
    long _surf_obj                              ' surface to render to

    { button attributes }
    long _bg_color
    long _text_str, _text_color

    word _surf_sx, _surf_sy, _surf_w, _surf_h   'xxx type? like root, frame, etc? does it matter?
    word _sx, _sy, _ex, _ey, _width, _height, _opt
    word _state

    byte _id
    byte _text_sz
    byte _spacing_x, _spacing_y

obj

    { "meta" instances of objects (object pointers) }
    disp=       "display.lcd.bt81x"             ' EVE LCD driver
    surface=    "gui.frame"                     ' surface

pub null()
' This is not a top-level object

pub init(button_id, init_st, bg_clr, surfc, disp)
' Initialize/set up the button
'   button_id: ID # of button (tag ID-1)
'   init_st: initial state of button
'   bg_clr: button background color (rgb24)
'   disp: pointer to instance of EVE display driver
    _id := button_id+1                          ' make button id 1:1 with touch tag ID
    _state := init_st                           ' initial state
    _bg_color := bg_clr

    _surf_obj := surfc                          ' pointer to gui frame instance
    _disp_obj := disp                           ' pointer to EVE driver instance
    wordmove(@_surf_sx, _surf_obj, 4)           ' copy position and dims of surface
    _action := _released_action := @null        ' no action by default to avoid crashes in the case
                                                '   of no defined function pointer

pub deinit{}
' Deinitialize
'   Clear used variable space to 0
    longfill(@_bg_color, 0, 3)
    wordfill(@_sx, 0, 8)
    bytefill(@_id, 0, 4)

pub above(): y
' Get coordinate immediately to the right of a button (including the surface's grid spacing)
    return _sy - surface[_surf_obj]._grid_sz

pub below(): y
' Get coordinate immediately to the right of a button (including the surface's grid spacing)
    return _ey + surface[_surf_obj]._grid_sz

pub draw()
' Use the display driver to draw the button
    disp[_disp_obj].color_rgb24(_text_color)
    disp[_disp_obj].widget_fgcolor(_bg_color)
    disp[_disp_obj].tag_attach(_id)
    disp[_disp_obj].button( surface[_surf_obj]._sx + _sx, ...
                            surface[_surf_obj]._sy + _sy, ...
                            _width, _height, _text_sz, _opt, _text_str)

pub get_ex(): x
' Get the ending X coordinate of the button, based on its starting coord and width
    return _ex

pub get_ey(): y
' Get the ending Y coordinate of the button, based on its starting coord and height
    return _ey

pub get_sx(): x
' Get the ending X coordinate of the button, based on its starting coord and width
    return _sx

pub get_sy(): y
' Get the ending X coordinate of the button, based on its starting coord and width
    return _sy

pub is_pushed(): p
' Flag indicating the button is pushed
'   Returns: TRUE (-1) or FALSE (0)
    return ( disp[_disp_obj].tag_active() == _id )

pub left_of(): x
' Get coordinate immediately to the left of a button (including the surface's grid spacing)
    return _sx - surface[_surf_obj]._grid_sz

pub min_height(): w
' Get the minimum height of a button, considering its font size

pub pushed_action()
' Call pushed button action
    _action()

pub right_of(): x
' Get coordinate immediately to the right of a button (including the surface's grid spacing)
    return _ex + surface[_surf_obj]._grid_sz

pub set_bgcolor(c)
' Set background color
    _bg_color := c

pub set_dims(w, h)
' Set button dimensions
    _width := w
    _height := h
    _ex := (_sx + _width)-1                     ' lower right coordinates
    _ey := (_sy + _height)-1

pub set_height(h)
' Set button height
    _height := h

pub set_pos(x, y)
' Set button position
'   x, y: coordinates of upper-left button corner
    _sx := surface[_surf_obj]._drw_sx + x
    _sy := surface[_surf_obj]._drw_sy + y

pub set_pos_dims(x, y, w, h)
' Set button position and dimensions
    _sx := surface[_surf_obj]._drw_sx + x
    _sy := surface[_surf_obj]._drw_sy + y

    { set the dimensions, clamping them to a sane range;
        EVE won't draw _anything_ in your display list if the size of a widget is invalid }
    _width := 1 #> w '<# surface[_surf_obj].right() - _sx   'XXX get these worked out;
    _height := 1 #> h '<# (surface[_surf_obj].bottom() - _sy)'XXX right now the max can be 0
    _ex := (_sx + _width)-1                     ' lower right coordinate
    _ey := (_sy + _height)-1

pub set_pushed_action(fptr)
' Attach an action to the button when it's pressed (transition from RELEASED to PUSHED)
'   (pushed event callback)
'   fptr: pointer to function
    _action := fptr

pub set_released_action(fptr)
' Attach an action to the button when it's released (transition from PUSHED to RELEASED)
'   (released event callback)
'   fptr: pointer to function
    _released_action := fptr

pub set_render_opt(o)
' Set rendering option
'   o: OPT_3D (0), OPT_FLAT (256)
    _opt := o

pub set_spacing(x, y)
' Set inter-button spacing
    _spacing_x := 0 #> x
    _spacing_y := 0 #> y

pub set_sx(x)
' Set starting X coordinate of button
    _sx := surface[_surf_obj]._drw_sx + x

pub set_sy(y)
' Set starting Y coordinate of button
    _sy := surface[_surf_obj]._drw_sx + y

pub set_state(new_state)
' Set state of button
'   st: UP (0), DOWN/PUSHED (1)
'   NOTE: The bound action will be called if state is DOWN/PUSHED
    if ( (new_state == PUSHED) and (_state == UP) )
        _opt := disp[_disp_obj].OPT_FLAT
        _action()
    elseif ( (new_state == RELEASED) and (_state == PUSHED) )
        _opt := disp[_disp_obj].OPT_3D
        _released_action()

    _state := new_state

pub set_text(p_str)
' Set button text string
    _text_str := p_str

pub set_text_color(c)
' Set button text color
    _text_color := c

pub set_text_and_pos(p_str, x, y)
' Set button text string and button position
    _text_str := p_str
    _sx := surface[_surf_obj]._drw_sx + x
    _sy := surface[_surf_obj]._drw_sy + y

pub set_text_button_pos_dims(p_str, x, y, w, h)
' Set button text string, button position and dimensions
    _text_str := p_str
    _sx := surface[_surf_obj]._drw_sx + x
    _sy := surface[_surf_obj]._drw_sy + y
    _width := w
    _height := h

pub set_text_size(sz)

    _text_sz := sz

pub set_text_size_color(p_str, sz, c)
' Set button text, text size, text color
    _text_str := p_str
    _text_sz := sz
    _text_color := c

pub set_width(w)
' Set button width
    _width := w

pub change_state()
' Change state of button
'   (0 -> 1 or 1 -> 0)
'   NOTE: The bound action will be called if state is DOWN/PUSHED
    _state ^= 1
    if ( _state == PUSHED )
        _opt := disp[_disp_obj].OPT_FLAT
        _action()
    else
        _opt := 0

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

