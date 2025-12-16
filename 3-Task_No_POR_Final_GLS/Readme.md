# Task3 - Removal of On-Chip POR and Final GLS Validation (SCL-180)

## Objective
- The objective of this task is to remove the on-chip Power-On Reset (POR) logic from the VSD Caravel–based RISC-V SoC and demonstrate that a design relying only on a single external active-low reset pin is safe and correct for the SCL-180 technology.
- This work aims to show, through RTL analysis, pad-level reasoning, synthesis, and gate-level simulation, that:
  - No internal POR circuitry is required.
  - All reset behavior is explicit and externally controlled.
  - The resulting design remains functionally correct and synthesizable.

 
