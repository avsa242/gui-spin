# gui-spin
----------

This is a P8X32A/Propeller, P2X8C4M64P/Propeller 2 library of GUI-related elements

**IMPORTANT**: This software is meant to be used with the [spin-standard-library](https://github.com/avsa242/spin-standard-library) (P8X32A) or [p2-spin-standard-library](https://github.com/avsa242/p2-spin-standard-library) (P2X8C4M64P). Please install the applicable library first before attempting to use this code, otherwise you will be missing several files required to build the project.


## Salient Features

* Scrollable text window (for ANSI serial terminals)
* Touchscreen button metadata and drawing (for EVE displays)
* Battery gauge widget
* GUI frame display (for EVE displays)
* Generic oscilloscope renderer
* Object-oriented - can be attached at the application level to any compatible display driver


## Requirements

P1/SPIN1:
* spin-standard-library

P2/SPIN2:
* p2-spin-standard-library


## Compiler Compatibility

| Processor | Language | Compiler               | Backend      | Status                |
|-----------|----------|------------------------|--------------|-----------------------|
| P1	    | SPIN1    | FlexSpin (6.1.1)	| Bytecode     | OK                    |
| P1	    | SPIN1    | FlexSpin (6.1.1)       | Native/PASM  | OK                    |
| P2	    | SPIN2    | FlexSpin (6.1.1)       | NuCode       | Not yet implemented   |
| P2        | SPIN2    | FlexSpin (6.1.1)       | Native/PASM2 | Not yet implemented   |

(other versions or toolchains not listed are __not supported__, and _may or may not_ work)


## Limitations

* Very early in development - may malfunction, or outright fail to build
* Some objects are currently limited to certain display drivers

