{
    --------------------------------------------
    Filename: gui.button.spin
    Author: Jesse Burt
    Description: Generic object for manipulating GUI button structures
    Copyright (c) 2023
    Started Jul 18, 2022
    Updated Feb 4, 2023
    See end of file for terms of use.
    --------------------------------------------
}

con

    NR_BUTTONS  = 1                             ' to change, override this in the parent object

    { button states }
    UP          = 0
    DOWN        = 1
    PUSHED      = 1

    { button attributes structure (longs)
        ID: button id (for EVE: should match tag ID set with tag_attach() )
        ST: state (UP, DOWN/PUSHED)
        SX: x coord
        SY: y coord
        WD: width
        HT: height
        TSZ: text size/font
        OPT: button options (for EVE: flat or 3D effect)
        PSTR: pointer to button text
        TCOLOR: text color
    }

    { use the last enum as the size (equal to the number of enums before it) }
    #0, ID, ST, SX, SY, WD, HT, TSZ, OPT, PSTR, TCOLOR, SIZEOF_BTN_STRUCT
    BTN_BUFF_SZ = NR_BUTTONS * SIZEOF_BTN_STRUCT

var

    long _btn_buff[BTN_BUFF_SZ]
    long _ptr_btns, _nr_btns
    byte _spacing_x, _spacing_y

{ call one of init() or init_ext_buff() from the parent object, first }

pub init()
' Initialize, using internal buffer
'   NOTE: To change the maximum number of buttons, override NR_BUTTONS in the parent's
'       declaration of this object. (OBJ btn: "gui.button" | NR_BUTTONS = #)
    _ptr_btns := @_btn_buff
    _nr_btns := NR_BUTTONS

pub init_ext_buff(ptr_btnbuff, nr_btns)
' Initialize, using external button buffer
'   ptr_btnbuff: pointer to button(s) buffer (must be at least (nr_btns * BTN_BUFF_SZ) longs)
    _ptr_btns := ptr_btnbuff
    _nr_btns := nr_btns

pub deinit{}
' Deinitialize
'   Clear used variable space to 0
    longfill(@_btn_buff, 0, BTN_BUFF_SZ+2)
    bytefill(@_ptr_btns, 0, 2)

pub above(btn_nr): y
' Get coordinate immediately to the right of a button (including inter-button spacing)
'   btn_nr: button to read coordinate of
    return get_sy(btn_nr) - _spacing_y

pub below(btn_nr): y
' Get coordinate immediately to the right of a button (including inter-button spacing)
'   btn_nr: button to read coordinate of
    return get_ey(btn_nr) + _spacing_y

pub destroy(btn_nr)
' Destroy a button definition
    longfill(ptr(btn_nr), 0, SIZEOF_BTN_STRUCT)
    
pub get_attr(btn_nr, param): val
' Get button attribute
'   btn_nr: button number
'   param: attribute to read
'   Returns: value for attribute
    { button idx 1-based so it maps 1:1 with tag # }
    if ( (btn_nr => 1) and (btn_nr =< _nr_btns) )
        return long[ptr(btn_nr)][param]

pub get_ex(btn_nr): c
' Get the ending X coordinate of the button, based on its starting coord and width
    return (get_attr(btn_nr, SX) + get_attr(btn_nr, WD))

pub get_ey(btn_nr): c
' Get the ending Y coordinate of the button, based on its starting coord and height
    return (get_attr(btn_nr, SY) + get_attr(btn_nr, HT))

pub get_sx(btn_nr): c
' Get the ending X coordinate of the button, based on its starting coord and width
    return (get_attr(btn_nr, SX))

pub get_sy(btn_nr): c
' Get the ending X coordinate of the button, based on its starting coord and width
    return (get_attr(btn_nr, SY))

pub left_of(btn_nr): x
' Get coordinate immediately to the left of a button (including inter-button spacing)
'   btn_nr: button to read coordinate of
    return get_sx(btn_nr) - _spacing_x

pub min_height(btn_nr): w
' Get the minimum height of a button, considering its font size
    return (get_attr(btn_nr, TSZ))

pub min_width(btn_nr): w
' Get the minimum width of a button, considering its font size and length of text
    return (text_len(btn_nr) * (get_attr(btn_nr, TSZ)/2))

pub ptr(btn_nr): p
' Get pointer to start of btn_nr's structure in button buffer
    return _ptr_btns + ( ((btn_nr-1) * SIZEOF_BTN_STRUCT) * 4)

pub ptr_e(btn_nr): p
' Get pointer to start of btn_nr's structure in button buffer
'   Directly compatible with EVE button_ptr()
    return _ptr_btns + ( ((btn_nr-1) * SIZEOF_BTN_STRUCT) * 4) + 8

pub right_of(btn_nr): x
' Get coordinate immediately to the right of a button (including inter-button spacing)
'   btn_nr: button to read coordinate of
    return get_ex(btn_nr) + _spacing_x

pub set_attr_all(param, val) | b
' Set attribute of ALL buttons
'   param: attribute to modify
'   val: new value for attribute
    repeat b from 1 to _nr_btns
        set_attr(b, param, val)

pub set_attr(btn_nr, param, val)
' Set button attribute
'   btn_nr: button number
'   param: attribute to modify
'   val: new value for attribute
    { button idx 1-based so it maps 1:1 with tag # }
    if ( (btn_nr => 1) and (btn_nr =< _nr_btns) )
        long[ptr(btn_nr)][param] := val

pub set_pos(btn_nr, x, y)
' Set button position
'   btn_nr: button number
'   x, y: coordinates of upper-left button corner
    set_attr(btn_nr, SX, x)
    set_attr(btn_nr, SY, y)

pub set_spacing(x, y)
' Set inter-button spacing
    _spacing_x := 0 #> x
    _spacing_y := 0 #> y

pub set_sx(btn_nr, x)
' Set starting X coordinate of button
    set_attr(btn_nr, SX, x)

pub set_sy(btn_nr, y)
' Set starting Y coordinate of button
    set_attr(btn_nr, SY, y)

pub set_id_all(st_nr) | b
' Set ID attribute of all buttons in ascending order
'   st_nr: starting ID number to use
    repeat b from 0 to _nr_btns-1
        set_attr((st_nr+b), ID, (st_nr+b))

pub text_len(btn_nr): len
' Get the length of the text string pointed to by the button definition
'   btn_nr: button number
    return strsize(get_attr(btn_nr, PSTR))

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

