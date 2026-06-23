# Traffic Light Controller — CEG-3555 Lab 3

**Course:** CEG-3555 – Systèmes numériques II
**Institution:** University of Ottawa, School of Electrical Engineering and Computer Science
**Authors:** Yann Joël Lyazid Giffaux, Rami Laham
**Date:** 2023-11-10

## Overview

This project implements a sequential traffic light controller in VHDL, targeting the Altera DE-12 board and built with Quartus II. The design uses a Finite State Machine (FSM) to model the behavior of a traffic light system controlling a main street and a secondary street.

## Objectives

- Design, implement, and test a traffic light controller module
- Apply the FSM design methodology
- Build a synchronous sequential machine

## Architecture

The system is implemented as a structural VHDL design composed of multiple hierarchical components:

- **1-bit Adder** — performs binary addition with carry-in/carry-out
- **4-bit Comparator** — compares two 4-bit inputs and outputs equal/greater-than/less-than flags
- **4-bit Selector** — multiplexes one of four 4-bit inputs based on a 2-bit select line
- **4-bit Counter** — synchronous counter with enable, load, and active-low reset
- **Debouncer** — filters noisy input signals, only passing a signal through after it remains stable across two consecutive clock edges
- **Controller** — top-level FSM driving traffic light state transitions based on input conditions

## Verification

Each component was simulated independently against expected truth tables before integration:

| Component | Result |
|---|---|
| 1-bit Adder | Matched expectations exactly |
| 4-bit Comparator | Matched expectations exactly |
| 4-bit Selector | Matched expectations exactly |
| 4-bit Counter | Mostly correct; minor reset-timing offset and a cosmetic display lag when re-enabled (no functional impact) |
| Controller | Behaved as expected; light states correctly tracked the selector inputs |
| Debouncer | Worked as intended |
| Full System | Functioned correctly overall, but exhibited a startup bug where the system stayed in its initial state instead of advancing as the counter activated |

No formal testbenches were written, due to limited prior experience with testbench development.

## Known Issues / Design Obstacles

- An early Karnaugh map error led to an incorrect register state design for the controller, requiring rework
- The VHDL conversion initially overlooked the need for a uniform reset signal across components, requiring later changes
- The counter has minor technical quirks (reset-value offset, display lag) that don't affect practical operation
- On-hardware testing on the Altera DE-12 board revealed a state-transition failure not seen in simulation; root cause undetermined — could be a hardware fault or an untested edge case, since simulation coverage didn't exercise all possible input combinations

## Conclusion

The FSM-based approach proved effective and practical for designing the sequential traffic light controller. Individual components met their design specifications, suggesting that any remaining issues lie in component integration rather than in the components themselves. More exhaustive testing covering all input cases would help isolate the source of the hardware discrepancy. Overall, the FSM methodology made the hierarchical system easier to reason about and understand.
