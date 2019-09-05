# DMG Programming Basics

The GameBoy (DMG) CPU is based on a subset of the Z80 processor.

## Memory Layout

Memory in the Game Boy is memory mapped and has the following layout:

| Address Space | Description                            |
| ------------- | -------------------------------------- |
| 0000 - 7FFF   | Cartridge 32KB                         |
| 8000 - 9FFF   | VRAM 8KB (Tiles and Background Layer)  |
| A000 - BFFF   | External Ram (XRAM) 8KB (Save Games)   |
| C000 - DFFF   | Work Ram (WRAM) 8KB                    |
| FE00 - FE9F   | Object Attribute Memory (OAM, Sprites) |
| FF00 - FF7F   | I/O Registers                          |
| FF80 - FFFE   | Hight RAM (HRAM)                       |
| FFFF          | Interrupt Switch                       |

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

HINT: Instead of using a 8-bit register in an opcode you can
always use [hl] instead.

## The LD opcode

The general structure of the LD opcode is as follows:

```assembly
    LD destination, source
```

### Loading Register from Register

The `LD` instruction can load any of the registers `A, B, C, D, E, H, L`
into any other of these registers:

```assembly
    LD A, B
```

### Immediate Loading of Registers

Specific fixed values can be loaded directly into one of the registers:

`A, B, C, D, E, H, L, SP, PC`

This is done using the `LD` instruction:

```assembly
    LD C, 3
    LD C, $FF
    LD DE, $FF80
```

### Direct Loading of Registers

The Registers `A, BC, DE, HL, SP` can be loaded directly from memory (direct addressing):

```assembly
    LD A, [$3FFF]
```

### Indirect Loading of Registers

Indirect loading allows to load any 8-bit register from the address contained in the 16-bit register `HL`:

```assembly
    LD D, [HL]
```

The register `A` can also be loaded from the 16-bit registers `BC, DE`:

```assembly
    LD A, [BC]
```

It is important to note that 16-bit register pairs can not be loaded indirectly!

### Storing a Register in Memory

Loading the content of a register into a given memory location can be done
as follows:

```assembly
    LD [$C000], A

    LD HL, $8000
    LD [HL], C

    LD [HL], $6F
```

### Automatic Increment and Decrement

When using `HL` for indirect loading into or storing to register `A` the `LDI` opcode
can be used to automatically increment the address inside `HL` after the loading took place:

```assembly
    LDI A, [HL]
    LDI [HL], A
```

There is also a version that decrements `HL`:

```assembly
    LDD A, [HL]
    LDD [HL], A
```

## Arithmetic

### Add instruction

```assembly
ADD A, register
ADD A, immediate data
ADD A, [HL]
```

### Add with Carry instruction

```assembly
ADC A, register
ADC A, immediate data
ADC A, [HL]
```

### Sub instruction

```assembly
SUB register
SUB immediate data
SUB [HL]
```

### Sub with Carry instruction

```assembly
SBC A, register
SBC A, immediate data
SBC A, [HL]
```

### AND instruction

```assembly
AND register
AND immediate data
AND [HL]
```

## Indexed Access to Data

### The General Solution

Given an Array of bytes starting at address `ArrayAddress` that contains up to 256 bytes it is possible to
access each byte by an index `Index` using the following code:

```assembly
    LD HL, ArrayAddress
    LD A, Index
    ADD L
    LD L, A
    JR NC, .nc
    INC H
.nc:
    LD A, [HL]
```

### A Faster Version

A neat trick is to align data (thats is less than 256 bytes) to pages. This means the data starts at addresses of the form $xx00 where xx is the page so that an indexed access can be implemented by simply loading the page (array address shifted right by 8) into `H` and the index into `L`:

```assembly
    LD H, ArrayAddress >> 8
    LD L, Index
    LD A, [HL]
```

This version is approx. 2 times faster than the genral solution to indexd access!

## Read Button State

The button state is located at $FF00. 
Normally bit 4 and 5 are set to 1. Setting them to 0 
will make the bits 0 to 3 become set or unset depending
on which buttons are pressed. When bit 5 is set to 0
the bits 0 to 3 will have the follwing meaning:

| bit | button |
| --- | ------ |
| 0   | right  |
| 1   | left   |
| 2   | up     |
| 3   | down   |

When bit 4 is set to 0 the bits 0 to 3 will have the follwing meaning:

| bit | button |
| --- | ------ |
| 0   | A      |
| 1   | B      |
| 2   | Select |
| 3   | Start  |

Example code to read all 8 button states into register A is given below:

```assembly
    LD A, %00100000
    LD [$FF00], A

    ; debounce
    LD A, [$FF00]
    LD A, [$FF00]

    CPL

    AND %00001111
    SWAP A
    LD B, A
    LD A, %00010000
    LD [$FF00], A

    ; debounce
    LD A, [$FF00]
    LD A, [$FF00]
    LD A, [$FF00]
    LD A, [$FF00]
    LD A, [$FF00]
    LD A, [$FF00]

    CPL
    AND %00001111
    OR B
```

## Bank Switching

*TBD!*

## References

* http://www.devrs.com/gb/files/opcodes.html
* https://raw.githubusercontent.com/jansegre/gameboy/master/spec/gbspec.txt
* http://marc.rawer.de/Gameboy/Docs/GBCPUman.pdf
* http://forums.nesdev.com/viewtopic.php?p=177418#p177418
* https://forums.nesdev.com/viewtopic.php?f=20&t=14691