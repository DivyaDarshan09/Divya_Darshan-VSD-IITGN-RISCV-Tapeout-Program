# SCL180 Spare Cell Macro
## Refactored by: Divya Darshan VR
## Module: `scl180_marco_sparecell.v`

---

## Overview

- `scl180_marco_sparecell` is a **physical-design spare logic macro** intended for
  post-silicon Engineering Change Orders (ECOs).
- The module instantiates a small set of **standard logic gates** that are
  intentionally left unused during normal operation.
- These gates can be **reconnected using metal-only changes** during late-stage
  silicon fixes without requiring a full re-spin.

This module is **not a functional RTL block** and is included solely to support
**physical design flexibility**.

---

## Design Intent

- Provide **pre-placed logic resources** for ECO usage
- Avoid introducing functional dependencies in normal operation
- Ensure compatibility with:
  - RTL simulation
  - Power-aware simulation
  - Gate-level simulation (GLS)
  - P&R / LVS flows

---

## Interface Summary

### Ports

| Signal | Direction | Description |
|------|-----------|-------------|
| `LO` | Output | Constant low output driven by internal tie-low logic |

### Optional Power Pins

| Signal | Direction | Description |
|------|-----------|-------------|
| `VPWR` | Inout | Core power supply |
| `VGND` | Inout | Ground |
| `VPB`  | Inout | P-well bias |
| `VNB`  | Inout | N-well bias |

> Power pins are conditionally included using `USE_POWER_PINS`.

---

## Internal Structure

The macro instantiates the following logic:

- Constant logic cell (`dummy_scl180_conb_1`)
- Inverters (`inv0d2`)
- NAND gates (`nd02d2`)
- NOR gates (`nr02d2`)
- Buffer (`buffd1`)

### Functional Behavior

- The constant cell generates a stable logic `0` (`tielo`)
- The buffer drives the output:
```text
  LO = 0
```
- All other gates are structurally present but unused, reserved for ECO rewiring.
---
### Constant Cell Usage

```verilog
dummy_scl180_conb_1 conb0 (
    .LO(tielo),
    .HI(net7)
);
```

- `tielo` is used as a constant low source and drives the spare cell output.
- net7 represents a constant high output from the constant cell and is not used in the current implementation.
- Power pins of the constant cell are intentionally left unconnected in RTL, as this is an abstract functional model. Power connectivity is resolved during
physical implementation and LVS.

---
### Power Pin Handling

- Power pins are conditionally included using:
```bash
`ifdef USE_POWER_PINS
```

### This Approach Allows

- **Simple RTL simulation** without explicit power pin wiring
- **Power-aware compilation** when required (GLS, P&R, LVS)
- Reuse of a **single RTL source** across multiple design flows

---

### Correct Modeling Guidelines

- Power pins (`VPWR`, `VGND`, `VPB`, `VNB`) are declared as **`inout`**, matching
  real SCL180 standard-cell interfaces.
- In testbenches, power rails are modeled as **nets (`wire`)**, not variables
  (`reg`), to comply with `inout` port semantics.
- This modeling approach avoids **port-type violations** and ensures
  compatibility with **Synopsys VCS** and other sign-off tools.

---
### Known Warnings (Expected)

**TFIPC: Too Few Instance Port Connections**

- Triggered when USE_POWER_PINS is defined and the constant cell power pins are not connected.
- This is intentional in the abstract RTL model.
- The warning does not affect functional correctness.
- Power connectivity is resolved during physical implementation and LVS.

---
## Verification Strategy

### Verification Scope

The spare cell macro was verified for:

- Clean elaboration in **RTL** and **power-aware** simulation modes
- Correct constant output behavior (`LO = 0`)
- Absence of **X/Z** conditions on the output
- Compatibility with **Synopsys VCS** and **Icarus Verilog**

---
### Verification Status

| Item                  | Status     |
| --------------------- | ---------- |
| RTL elaboration       | ✅ Passed   |
| Power-aware compile   | ✅ Passed   |
| Constant output check | ✅ Verified |
| X/Z robustness        | ✅ Verified |

---

## Simulation Output

### RTL Simulation

The spare cell macro was simulated in both **power-aware** and **non-power-aware**
RTL modes to validate interface robustness and output stability.

- **With power pins enabled (`USE_POWER_PINS`)**:
  - The module elaborates cleanly in power-aware mode.
  - The constant low output (`LO = 0`) remains stable.
  - No X/Z conditions are observed.

- **Without power pins (default RTL)**:
  - The module compiles and simulates without requiring explicit power wiring.
  - The output behavior remains identical to the power-aware case.

These results confirm that the spare cell macro functions correctly across
different simulation configurations using a single RTL source.

**Screenshot: With power pins enabled (`USE_POWER_PINS`)**


![RTL](../images/w_pwr_spare.png)


**Screenshot: Without power pins (default RTL)**


![RTL](../images/wo_pwr_spare.png)

---
## Summary
### Module: `scl180_marco_sparecell.v`

### Current Status
- The spare cell macro is **structurally correct and verified**.
- The module provides **pre-placed spare logic gates** intended for post-silicon
  Engineering Change Orders (ECOs).
- A constant low output (`LO`) is generated using a technology-accurate constant
  cell.
- The module compiles cleanly in both:
  - Default RTL simulation
  - Power-aware simulation flows

### Identified Issue (Initial Implementation)
- A modeling issue was identified in the testbench and power-pin handling:
  - Power pins were initially driven using variables instead of nets
  - This resulted in **`inout` port connection violations** in Synopsys VCS
- Additionally, standard-cell primitives required explicit modeling for RTL
  simulation.

### Implemented Fix
- Power pins are now:
  - Declared as **`inout`** in the module, matching real SCL180 cell interfaces
  - Driven as **nets (`wire`)** in the testbench
- Functional stubs were introduced for SCL180 standard cells to enable RTL
  verification.
- The constant cell instantiation intentionally leaves power pins unconnected in
  RTL, consistent with abstract modeling practices.

### Verification Status

| Item | Status |
|----|----|
| Spare cell structural modeling | ✅ Verified |
| Constant output behavior (`LO = 0`) | ✅ Verified |
| Default RTL simulation | ✅ Passed |
| Power-aware compile (`USE_POWER_PINS`) | ✅ Passed |
| VCS compatibility | ✅ Verified |

---


























