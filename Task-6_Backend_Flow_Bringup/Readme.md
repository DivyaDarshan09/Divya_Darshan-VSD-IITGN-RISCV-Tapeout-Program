# 🚀 Task 6 — Backend Flow Bring-Up @ 100 MHz  
## ICC2 → Star-RC → PrimeTime

<p align="center">
  <img src="https://img.shields.io/badge/Target_Frequency-100MHz-brightgreen"/>
  <img src="https://img.shields.io/badge/Clock_Period-10ns-blue"/>
  <img src="https://img.shields.io/badge/Flow-ICC2→StarRC→PrimeTime-orange"/>
  <img src="https://img.shields.io/badge/Goal-End--to--End_Flow_Validation-success"/>
</p>

---

## 📌 Objective

The objective of **Task-6** is to establish and validate a **complete backend implementation flow** for the Raven SoC wrapper capable of supporting a **100 MHz operating frequency**.

This task demonstrates:
- Correct **tool setup**
- Clean **handoff between backend tools**
- Successful **post-route parasitic extraction**
- Accurate **post-route Static Timing Analysis (STA)**

> ⚠️ This task focuses on **flow correctness**, not timing closure or signoff optimization.

---

## 🎯 Performance Target

| Parameter | Value |
|--------|-------|
| Target Frequency | **100 MHz** |
| Clock Period | **10 ns** |
| Timing Check | Post-route (SPEF-based STA) |

---
## 🧩 Design Overview

### Design Information

| Attribute | Description |
|--------|------------|
| Design Name | `raven_wrapper` |
| Technology | FreePDK45 (45 nm) |
| Standard Cell Library | Nangate Open Cell Library |
| SRAM Macro | `sram_32_1024_freepdk45` |
| Die Size | 3588 µm × 5188 µm |
| Core Area | 2988 µm × 4588 µm |
| Core Offset | 300 µm |
| Target Clock | 100 MHz (10 ns) |

---
### Metal Stack
- **Routing Layers:** Metal1 - Metal10
- **Power Grid:** Metal9 (Vertical), Metal10 (Horizontal)
- **Standard Cell Rails:** Metal1

| Layer | Direction | Usage |
|-------|-----------|-------|
| Metal1 | Horizontal | Standard cell rails, local routing |
| Metal2 | Vertical | Local routing |
| Metal3 | Horizontal | Macro pin connections |
| Metal4 | Vertical | Signal routing |
| Metal5 | Horizontal | Signal routing |
| Metal6 | Vertical | Signal routing |
| Metal7 | Horizontal | Signal routing |
| Metal8 | Vertical | Signal routing |
| Metal9 | Horizontal | Power mesh (vertical stripes) |
| Metal10 | Vertical | Power mesh (horizontal stripes) |
---
### Clock Specifications
```tcl
# Three clock domains at 100 MHz (10ns period)
- ext_clk:  10.0 ns period
- pll_clk:  10.0 ns period  
- spi_sck:  10.0 ns period
```
---
## Prerequisites

### Required Files
1. **Verilog Netlist:** `raven_wrapper.synth.v`
2. **Technology File:** `nangate.tf`
3. **LEF Files:** Standard cell and SRAM LEF files
4. **Timing Libraries:** `.db` files for standard cells and SRAM
5. **TLU+ Files:** Parasitic extraction models
6. **Constraint Files:** MCMM setup, timing constraints

---
## 🛠 Toolchain Used

| Stage | Tool |
|-----|-----|
| Placement & Routing | Synopsys ICC2 |
| Parasitic Extraction | Synopsys Star-RC |
| Static Timing Analysis | Synopsys PrimeTime |

---

## 🔁 Backend Flow Sequence

```text
ICC2 (Placement + CTS + Routing)
        ↓
Star-RC (SPEF Extraction)
        ↓
PrimeTime (Post-Route STA @ 100 MHz)
```
---
## Design Setup

```bash
# clone the repository
git clone https://github.com/kunalg123/icc2_workshop_collaterals
```
### 1. Common Setup Script (`icc2_common_setup.tcl`)

- This script defines all global variables and paths required for the design.

## 🔧 Global Design Configuration Script

- This configuration file serves as the **central initialization script** for the physical design flow.  
- It defines the **design identity**, **library associations**, **input file paths**, and **routing layer constraints** required before starting ICC2 execution.

---

### 🏷 Design Identification Parameters

These variables uniquely identify the design and its associated working library.

```tcl
set DESIGN_NAME        "raven_wrapper"
set LIBRARY_SUFFIX     "Nangate"
set DESIGN_LIBRARY     "${DESIGN_NAME}${LIBRARY_SUFFIX}"
```

**Purpose:**

- Establishes a unique design name
- Creates a consistent naming convention for the ICC2 design library
- Avoids conflicts when multiple designs are loaded in the same workspace

---
### 📚 Reference Library Definition

- The following LEF files are used to describe the physical layout characteristics of standard cells and embedded macros.

```tcl
set REFERENCE_LIBRARY [list \
    /path/to/nangate_stdcell.lef \
    /path/to/sram_32_1024_freepdk45.lef
]
```

**Purpose:**

- Provides cell geometry, pin locations, and obstruction data
- Enables correct placement and routing
- Allows ICC2 to understand both standard cells and SRAM macros

---
### 📥 Design Input Files

- These inputs define the logical design, technology rules, and timing/parasitic setup.

```tcl
set VERILOG_NETLIST_FILES        "/path/to/raven_wrapper.synth.v"
set TECH_FILE                   "/path/to/nangate.tf"
set TCL_MCMM_SETUP_FILE         "./init_design.mcmm_example.auto_expanded.tcl"
set TCL_PARASITIC_SETUP_FILE    "./init_design.read_parasitic_tech_example.tcl"
```

**Purpose:**

- Loads the synthesized RTL netlist
- Applies foundry-specific technology constraints
- Enables MCMM (Multi-Corner Multi-Mode) timing analysis
- Prepares parasitic extraction settings for later stages

---
### 🧱 Routing Layer Strategy

- This section defines the preferred routing direction for each metal layer and limits the routing stack.

```
set ROUTING_LAYER_DIRECTION_OFFSET_LIST \
    "{metal1 horizontal} {metal2 vertical} \
     {metal3 horizontal} {metal4 vertical} \
     {metal5 horizontal} {metal6 vertical} \
     {metal7 horizontal} {metal8 vertical} \
     {metal9 horizontal} {metal10 vertical}"

set MIN_ROUTING_LAYER "metal1"
set MAX_ROUTING_LAYER "metal10"
```

**Purpose:**

- Enforces alternating routing directions to reduce congestion
- Matches standard industry routing practices
- Ensures routers use only valid metal layers
- Provides compatibility with power grid planning