con

    { frame structure }
    SX      = 0
    SY      = 1
    WIDTH   = 2
    HEIGHT  = 3
    EX      = 4
    EY      = 5

obj

    disp    = "display.lcd.bt81x"

var

    long _instance
    long _bg_color
    word _surface[6]
    word _sx, _sy
    word _drw_sx, _drw_sy, _drw_ex, _drw_ey, _drw_w, _drw_h
    word _grid_sz                               ' set minimum spacing between things

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
    _instance := ptr_disp

    return @_surface

pub bottom(): b
' Get bottom coordinate of frame, minus the grid size
    return _surface[EY]-_grid_sz

pub draw()
' Use the display driver to draw the frame
'   NOTE: init() must be called with the instance of a graphics driver
    disp[_instance].widget_fgcolor(_bg_color)
    disp[_instance].button( _surface[SX], _surface[SY], _surface[WIDTH], _surface[HEIGHT], ...
                            31, 0, 0)
    disp[_instance].str( _surface[SX]+_grid_sz, _surface[SY], 26, 0, @"TEST")

    { clip the display to within the drawable area }
    disp[_instance].scissor_rect( _drw_sx, _drw_sy, _drw_w, _drw_h )

    { draw bounding box }
'    disp[_instance].box( _drw_sx, _drw_sy, _drw_ex, _drw_ey, 0)

pub get_ex(): x

    return _surface[EX]

pub get_ey(): y

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

pub set_w(w)
' Set the width of the frame
    _surface[WIDTH] := w

pub top(): b
' Get top coordinate of frame, plus the grid size
    return _surface[SY]+_grid_sz



