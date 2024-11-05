# Clockwork

Clockwork is a RISC-V softcore built for educational purposes.

## Specifications

- RV32I instruction set implementation,
- 5-stage pipeline,
    - currently without forwarding unit,
- Direct-mapped instruction cache,
    - 512 instructions organized into 64 cache lines.

# Architecture diagram

Dotted lines represent locations of pipeline registers and which signals handle by a register when crossed by one of the line.

![](doc/architecture.png)
