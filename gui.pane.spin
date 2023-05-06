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

    NR_PANES    = 1                             ' override in parent object

    { window pane structure (longs)
        ID: window pane ID/"handle"
        SX, SY: Upper-left coordinates
        WD, HT: Width, height (lower-right corner is SX+WD, SY+HT)
        FILL_FLG: filled flag (0 for outline, non-zero for filled)
        PANE_CLR: pane fill color (ignore if FILL_FLG == 0)
        PSTR: pointer to pane title string (set to 0 if unused)
        TITLE_HT: height of pane title text, in pixels (ignore if PSTR == 0)
        TITLE_CLR: color of title text (ignore if PSTR == 0)
    } { IMPORTANT: keep LAST as the last enumeration }
    #0, ID, SX, SY, WD, HT, FILL_FLG, PANE_CLR, PSTR, TITLE_HT, TITLE_CLR, LAST

    STRUCTSZ    = (LAST)

VAR

    long _pane_buff[NR_PANES * STRUCTSZ]
    long _ptr_panes, _nr_panes

PUB init()
' Initialize, using internal buffer
'   NOTE: To change the maximum number of panes, override NR_PANES in the parent's
'       declaration of this OBJ. (OBJ pane: "gui.pane" | NR_PANES = #)
    _ptr_panes := @_pane_buff
    _nr_panes := NR_PANES

PUB init_ext_buff(ptr_buff, nr_panes)
' Initialize, using external window pane buffer
'   ptr_buff: pointer to buffer
    _ptr_panes := ptr_buff
    _nr_panes := nr_panes

PUB deinit{}
' Deinitialize
    _ptr_panes := 0
    _nr_panes := 0

pub destroy(pane_idx)
' Destroy a pane definition
    longfill(ptr(pane_idx), 0, STRUCTSZ)

PUB filled(pane_idx): f
' Get the filled flag of a pane
    return get_attr(pane_idx, FILL_FLG)

PUB fill_color(pane_idx): c
' Get the fill color of a pane
    return get_attr(pane_idx, PANE_CLR)

PUB get_attr(pane_idx, param): val

    if (pane_idx => 0 and pane_idx =< _nr_panes) ' pane idx 1-based so it maps 1:1 with tag #
        return long[ptr(pane_idx)][param]

pub get_ex(pane_idx): c
' Get the ending X coordinate of the pane, based on its starting coord and width
    return (get_attr(pane_idx, SX) + get_attr(pane_idx, WD))

pub get_ey(pane_idx): c
' Get the ending Y coordinate of the pane, based on its starting coord and height
    return (get_attr(pane_idx, SY) + get_attr(pane_idx, HT))

pub get_ht(pane_idx): w
' Get the height of the pane
    return (get_attr(pane_idx, HT))

pub get_sx(pane_idx): c
' Get the ending X coordinate of the pane, based on its starting coord and width
    return (get_attr(pane_idx, SX))

pub get_sy(pane_idx): c
' Get the ending X coordinate of the pane, based on its starting coord and width
    return (get_attr(pane_idx, SY))

pub get_wd(pane_idx): w
' Get the width of the pane
    return (get_attr(pane_idx, WD))

pub left_margin(pane_idx): px
' Get left inner margin of pane
'   Returns: margin in pixels
    return get_attr(pane_idx, INSET_X)

pub ptr(pane_nr): p
' Get pointer to start of pane_nr's structure in pane buffer
    return _ptr_panes + ((pane_nr * STRUCTSZ) * 4)

pub set_attr(pane_idx, param, val)
' Set pane attribute
'   pane_idx: pane number
'   param: attribute to modify
'   val: new value for attribute
    if (pane_idx => 0 and pane_idx =< _nr_panes)
        long[ptr(pane_idx)][param] := val

pub set_attr_all(param, val) | b
' Set attribute of ALL panes
'   param: attribute to modify
'   val: new value for attribute
    repeat b from 0 to _nr_panes-1
        set_attr(b, param, val)

pub set_dims(pane_idx, w, h)
' Set dimensions of pane
    set_attr(pane_idx, WD, w)
    set_attr(pane_idx, HT, h)

pub set_filled(pane_idx, f)
' Set filled flag of pane
'   f: 0 = not filled, nonzero = filled
    set_attr(pane_idx, FILL_FLG, f)

pub set_fill_color(pane_idx, c)
' Set fill color of pane
'   c: fill color word (up to 32bits)
    set_attr(pane_idx, PANE_CLR, c)

pub set_id_all(st_nr) | b
' Set ID attribute of all panes in ascending order
'   st_nr: starting ID number to use
    repeat b from 0 to _nr_panes-1
        set_attr((st_nr+b), ID, (st_nr+b))

pub set_pos(pane_idx, x, y)
' Set position of pane
    set_attr(pane_idx, SX, x)
    set_attr(pane_idx, SY, y)

pub set_title_color(pane_idx, c)
' Set color of title text
    set_attr(pane_idx, TITLE_CLR, c)

pub set_title_ht(pane_idx, t_ht)
' Set height of pane text
'   t_ht: height of text, in pixels
    set_attr(pane_idx, TITLE_HT, t_ht)

pub set_title_str(pane_idx, p_str)
' Set pane title string
'   p_str: pointer to string containing title (set to 0 if unused)
    set_attr(pane_idx, PSTR, p_str)

pub title_color(pane_idx): c
' Get pane title text color
'   Returns: color word (up to 32bits)
    return get_attr(pane_idx, TITLE_CLR)

pub title_height(pane_idx): h
' Get pane title text height
'   Returns: height in pixels
    return get_attr(pane_idx, TITLE_HT)

pub title_string(pane_idx): s
' Get pane title string
'   Returns: pointer if set, 0 otherwise
    return get_attr(pane_idx, PSTR)

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

