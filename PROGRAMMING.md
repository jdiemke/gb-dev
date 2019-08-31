# DMG Programming

## Registers

We have 8 8-bit registers:

`A, F, B, C, D, E, H, L`

These can be grouped to 16-bit registers:

`AF, BC, DE, HL`

There are also the special purpose 16-bit registers:

`SP, PC`

Most of these registers have a special purpose:

* `A` is mainly used for arithmetic and logic operations
* `F` is the processor status register
* `B` and `C` are used as counters
* `DE` is used as destination address when moving data
* `HL` is used for indirect addressing
* `SP` is the stack pointer
* `PC` is the program counter

## Immediate Loading of Registers

Data can be loaded directly into:

`A, B, C, D, E, H, L`

This is done using the `LD` instruction:

`LD C, 3`