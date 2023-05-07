{
    --------------------------------------------
    Filename: gui.pane.spin
    Author: Jesse Burt
    Description: Object for manipulating window "pane" logical structures
        * Serves as an anchor/home/origin for other GUI elements
    Copyright (c) 2023
    Started Feb 4, 2023
    Updated May 6, 2023
    See end of file for terms of use.
    --------------------------------------------
}

CON

    NR_PANES    = 1                             ' to change, override this in parent object

    { window pane structure (longs)
        ID: window pane ID/"handle"
        SX, SY: Upper-left coordinates
        WD, HT: Width, height (lower-right corner is SX+WD, SY+HT)
        FILL_FLG: filled flag (0 for outline, non-zero for filled)
        PANE_CLR: pane fill color (ignore if FILL_FLG == 0)
        PSTR: pointer to pane title string (set to 0 if unused)
        TITLE_HT: height of pane title text, in pixels (ignore if PSTR == 0)
        TITLE_CLR: color of title text (ignore if PSTR == 0)
    }

    { use the last enum as the size (equal to the number of enums before it) }
    #0, ID, SX, SY, WD, HT, FILL_FLG, PANE_CLR, PSTR, TITLE_HT, TITLE_CLR, SIZEOF_PANE_STRUCT
    PANE_BUFF_SZ = NR_PANES * SIZEOF_PANE_STRUCT

VAR

    long _pane_buff[PANE_BUFF_SZ]
    long _ptr_panes, _nr_panes

{ call one of init() or init_ext_buff() from the parent object, first }

PUB init()
' Initialize, using internal buffer
'   NOTE: To change the maximum number of panes, override NR_PANES in the parent's
'       declaration of this object. (OBJ pane: "gui.pane" | NR_PANES = #)
    _ptr_panes := @_pane_buff
    _nr_panes := NR_PANES

PUB init_ext_buff(ptr_panebuff, nr_panes)
' Initialize, using external window pane buffer
'   ptr_panebuff: pointer to pane(s) buffer (must be at least (nr_panes * PANE_BUFF_SZ) longs)
    _ptr_panes := ptr_panebuff
    _nr_panes := nr_panes

PUB deinit{}
' Deinitialize
'   Clear used variable space to 0
    longfill(@_pane_buff, 0, PANE_BUFF_SZ+2)

pub destroy(pane_nr)
' Destroy a pane definition
    longfill(ptr(pane_nr), 0, STRUCTSZ)

PUB filled(pane_nr): f
' Get the filled flag of a pane
    return get_attr(pane_nr, FILL_FLG)

PUB fill_color(pane_nr): c
' Get the fill color of a pane
    return get_attr(pane_nr, PANE_CLR)

PUB get_attr(pane_nr, param): val
' Get a pane's specific attribute
'   pane_nr: pane number
'   param: attribute to read
    { pane idx 1-based so it maps 1:1 with tag # }
    if ( (pane_nr => 0) and (pane_nr =< _nr_panes) )
        return long[ptr(pane_nr)][param]

pub get_ex(pane_nr): c
' Get the ending X coordinate of the pane, based on its starting coord and width
    return (get_attr(pane_nr, SX) + get_attr(pane_nr, WD))

pub get_ey(pane_nr): c
' Get the ending Y coordinate of the pane, based on its starting coord and height
    return (get_attr(pane_nr, SY) + get_attr(pane_nr, HT))

pub get_ht(pane_nr): w
' Get the height of the pane
    return (get_attr(pane_nr, HT))

pub get_sx(pane_nr): c
' Get the ending X coordinate of the pane, based on its starting coord and width
    return (get_attr(pane_nr, SX))

pub get_sy(pane_nr): c
' Get the ending X coordinate of the pane, based on its starting coord and width
    return (get_attr(pane_nr, SY))

pub get_wd(pane_nr): w
' Get the width of the pane
    return (get_attr(pane_nr, WD))

pub left_margin(pane_nr): px
' Get left inner margin of pane
'   Returns: margin in pixels
    return get_attr(pane_nr, INSET_X)

pub ptr(pane_nr): p
' Get pointer to start of pane_nr's structure in pane buffer
    return _ptr_panes + ((pane_nr * SIZEOF_PANE_STRUCT) * 4)

pub set_attr(pane_nr, param, val)
' Set pane attribute
'   pane_nr: pane number
'   param: attribute to modify
'   val: new value for attribute
    if ( (pane_nr => 0) and (pane_nr =< _nr_panes) )
        long[ptr(pane_nr)][param] := val

pub set_attr_all(param, val) | b
' Set attribute of ALL panes
'   param: attribute to modify
'   val: new value for attribute
    repeat b from 0 to _nr_panes-1
        set_attr(b, param, val)

pub set_dims(pane_nr, w, h)
' Set dimensions of pane
    set_attr(pane_nr, WD, w)
    set_attr(pane_nr, HT, h)

pub set_filled(pane_nr, f)
' Set filled flag of pane
'   f: 0 = not filled, nonzero = filled
    set_attr(pane_nr, FILL_FLG, f)

pub set_fill_color(pane_nr, c)
' Set fill color of pane
'   c: fill color word (up to 32bits)
    set_attr(pane_nr, PANE_CLR, c)

pub set_id_all(st_nr) | b
' Set ID attribute of all panes in ascending order
'   st_nr: starting ID number to use
    repeat b from 0 to _nr_panes-1
        set_attr((st_nr+b), ID, (st_nr+b))

pub set_pos(pane_nr, x, y)
' Set position of pane
    set_attr(pane_nr, SX, x)
    set_attr(pane_nr, SY, y)

pub set_title_color(pane_nr, c)
' Set color of title text
    set_attr(pane_nr, TITLE_CLR, c)

pub set_title_ht(pane_nr, t_ht)
' Set height of pane text
'   t_ht: height of text, in pixels
    set_attr(pane_nr, TITLE_HT, t_ht)

pub set_title_str(pane_nr, p_str)
' Set pane title string
'   p_str: pointer to string containing title (set to 0 if unused)
    set_attr(pane_nr, PSTR, p_str)

pub title_color(pane_nr): c
' Get pane title text color
'   Returns: color word (up to 32bits)
    return get_attr(pane_nr, TITLE_CLR)

pub title_height(pane_nr): h
' Get pane title text height
'   Returns: height in pixels
    return get_attr(pane_nr, TITLE_HT)

pub title_string(pane_nr): s
' Get pane title string
'   Returns: pointer if set, 0 otherwise
    return get_attr(pane_nr, PSTR)

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

