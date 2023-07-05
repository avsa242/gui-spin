{
    --------------------------------------------
    Filename: Mic-ScopeDemo-SSD1309.spin2
    Description: Demo of the oscilloscope object
        * Input data from an electret mic (sampled by P2 smart-pin ADC)
        * Draw on an SSD1309 OLED
    Author: Jesse Burt
    Copyright (c) 2023
    Created: Jul 4, 2023
    Updated: Jun 4, 2023
    See end of file for terms of use.
    --------------------------------------------

    See metrology.scope.spin2 for instructions on building
}

CON

    _clkfreq    = cfg._clkfreq_def
    _xtlfreq    = cfg._xtlfreq

' -- User-modifiable constants
    SER_BAUD    = 2_000_000

    { SSD130x configuration }
    CS_PIN      = 18
    SCK_PIN     = 22
    MOSI_PIN    = 21
    DC_PIN      = 19
    RST_PIN     = 20                             ' optional; -1 to disable
    SPI_FREQ    = 10_000_000
    WIDTH       = 128
    HEIGHT      = 64

    { Electret microphone }
    MIC_PIN     = 10
    MIC_SRATE   = 48_000
    MIC_GAIN    = 1
    MIC_BIAS    = 1830
' --

    XMAX        = WIDTH-1
    YMAX        = HEIGHT-1

OBJ

    cfg:    "boardcfg.p2eval"
    disp:   "display.oled.ssd130x"
    ser:    "com.serial.terminal.ansi"
    scope:  "metrology.scope"
    mic:    "signal.adc.audio"

VAR

    long _smp
    long _smp_bias
    byte _fb[WIDTH*HEIGHT/8]

PUB main()

    setup()

    _smp_bias := MIC_BIAS
    disp.bgcolor(0)
    disp.clear()

    scope.init(0, 0, WIDTH, HEIGHT, @disp, @_smp)
    scope.set_ref_level(32)                     ' scope reference level
    scope.set_horiz_time(clkfreq/MIC_SRATE)     ' set horizontal timescale
    scope.set_data_scale(2048)                  ' max level expected from sample data
    scope.set_trigger_level(0)                  ' wait until data is this high to draw
                                                '   (scale is same as input data scale)
    repeat
        disp.clear()
        scope.draw_one_triggered_hi()           ' trigger on high threshold
'        scope.draw_one()                        ' no triggering; display will "roll"
        disp.show()

VAR long _smp_stack[50]
PUB cog_sample_mic()
' Sample the microphone using a P2 ADC
    mic.start(MIC_PIN, MIC_SRATE, MIC_GAIN)
    repeat
        _smp := (mic.adc_smp16()-_smp_bias)

VAR long _key_stack[50]
PUB cog_key_input()
' Wait for keypresses
    repeat
        case ser.getchar()
            "w":
                scope.inc_ref_level()
            "s":
                scope.dec_ref_level()
            "a":
                scope.dec_horiz_time()
            "d":
                scope.inc_horiz_time()
            "e":
                scope.inc_trigger_level()
                ser.printf(@"trigger level set to %d\n\r", scope._trig_lvl)
            "c":
                scope.dec_trigger_level()
                ser.printf(@"trigger level set to %d\n\r", scope._trig_lvl)
            "b":
                _smp_bias := _smp
                ser.printf(@"bias set to %d\n\r", _smp_bias)
            "h", "H", "?":
                ser.puts(@_help)

PUB setup()

    ser.start(SER_BAUD)
    ser.clear()
    ser.strln(string("Serial terminal started"))

    if ( disp.startx(CS_PIN, SCK_PIN, MOSI_PIN, DC_PIN, RST_PIN, SPI_FREQ, WIDTH, HEIGHT, @_fb) )
        ser.strln(@"SSD130x driver started")
    else
        ser.strln(@"SSD130x driver failed to start - halting")
        repeat

    disp.preset_128x64()
    disp.mirror_h(true)
    disp.mirror_v(true)


    cogspin(NEWCOG, cog_sample_mic(), @_smp_stack)
    cogspin(NEWCOG, cog_key_input, @_key_stack)

DAT

    _help
    byte "w: increase scope reference level (vertical)", ser.CR, ser.LF
    byte "s: decrease scope reference level (vertical)", ser.CR, ser.LF
    byte "a: decrease horizontal timescale (horizontal; delay between samples)", ser.CR, ser.LF
    byte "d: increase horizontal timescale (horizontal; delay between samples)", ser.CR, ser.LF
    byte "c: decrease trigger level", ser.CR, ser.LF
    byte "e: increase trigger level", ser.CR, ser.LF
    byte "b: set sample bias to current value (do when quiet)", ser.CR, ser.LF, 0

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

