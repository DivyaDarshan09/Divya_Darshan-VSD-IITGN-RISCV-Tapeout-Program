# Task3 - Removal of On-Chip POR and Final GLS Validation (SCL-180)

## Objective
- The objective of this task is to remove the on-chip Power-On Reset (POR) logic from the VSD Caravel–based RISC-V SoC and demonstrate that a design relying only on a single external active-low reset pin is safe and correct for the SCL-180 technology.
- This work aims to show, through RTL analysis, pad-level reasoning, synthesis, and gate-level simulation, that:
  - No internal POR circuitry is required.
  - All reset behavior is explicit and externally controlled.
  - The resulting design remains functionally correct and synthesizable.
  
--  
**Technology Note**

- This design targets the SCL-180 standard-cell and I/O library.
- As a result, SKY130-specific POR assumptions and pad behavior are removed.
- All reset decisions and documentation are written from an SCL-180 perspective.
---
## Phase-1: Study of Existing POR Usage

👉 **The complete analysis for this phase is documented here:**  
📄 **[POR_Usage_Analysis.md](https://github.com/DivyaDarshan09/Divya_Darshan-VSD-IITGN-RISCV-Tapeout-Program/blob/main/3-Task_No_POR_Final_GLS/POR_Usage_Analysis.md)**

This document covers:
- Identification and role of `dummy_por`
- Usage of `porb_h`, `porb_l`, and `por_l`
- Reset distribution paths across the SoC
- Clear separation between POR-driven logic and generic reset logic

This README continues from that analysis and documents **Phase-2 (RTL Refactoring)**, **Phase-3 (DC_TOPO Synthesis)**, and **Phase-4 (Final GLS)**.

---
## Phase-2: RTL Refactoring (POR Removal)

### Goal

Completely eliminate POR logic from the RTL and introduce a **single explicit
external reset pin**.

### Changes Performed

#### Removed
- `dummy_por` module
- All POR-generated timing/delay behavior
- Any reset logic dependent on power-edge detection

#### Introduced

```bash
input reset_n;   // Active-low external reset

# Explicit Reset Mapping (Legacy Compatibility)

assign porb_h = reset_n;
assign porb_l = reset_n;
assign por_l  = ~reset_n;
assign rstb_h = reset_n;
```
- These assignments are pure aliases — no logic, no delay, no inference.
---
**Design Rules Enforced**

- ❌ No digital POR
- ❌ No counters
- ❌ No power-pin edge detection
- ✅ Reset behavior fully explicit and visible
- ✅ All sequential logic resets from `reset_n`
---
### RTL SIMULATION

- Navigate to the HK-SPI test directory:
```bash
cd dv/hkspi/
```
- The Synopsys environment is initialized before invoking VCS.
```bash
csh
source /home/madank/toolRC_iitgntapeout
```
- The following command compiles the RTL and testbench and creates the simulation executable.
  
```bash
vcs -full64 -sverilog -timescale=1ns/1ps -debug_access+all \
    +incdir+../ +incdir+../../rtl +incdir+../../rtl/scl180_wrapper \
    +incdir+/home/Synopsys/pdk/SCL_PDK_3/SCLPDK_V3.0_KIT/scl180/iopad/cio250/6M1L/verilog/tsl18cio250/zero \
    +define+FUNCTIONAL +define+SIM \
    hkspi_tb.v -o simv
```
- The simulation is executed and a VCD file is generated for waveform viewing.
```bash
./simv -no_save +define+DUMP_VCD=1 | tee sim_log.txt
```

**Screenshot:** RTL Terminal Log

![rtl](3-Task_No_POR_Final_GLS/.Screenshots/rtl_terminal_1.v)


![rtl](3-Task_No_POR_Final_GLS/.Screenshots/rtl_terminal_2.v)


- All test cases pass successfully. The values read from registers 0 to 18 match the expected results, confirming correct functional behavior of the design.

**Waveforms are viewed using GTKWave.**
```bash
gtkwave hkspi.vcd hkspi_tb.v
```
**Screenshot:** RTL Waveform

![rtl](3-Task_No_POR_Final_GLS/.Screenshots/rtl_waveform.v)











