# VSD Caravel
## Refractored by : Divya Darshan VR
## xres_buf — External Reset Level-Shift Buffer

### Overview

- `xres_buf` is a level-shift buffer module used in the Caravel / VSDCaravel SoC to safely transfer the external reset signal from the pad domain (3.3V) to the core digital domain (1.8V).
- The module relies on built-in level-shifting present in SCL180 I/O / sky130 pads, and therefore implements a direct pass-through in RTL while preserving correct power-domain intent.

---

### Purpose and Motivation

**Why xres_buf is required**

- External reset (xres) is driven from a package pin
- Pad signals operate at 3.3V
- Core digital logic operates at 1.8V
- Direct connection without considering voltage domains is unsafe in ASICs

---

**xres_buf exists to:**

- Clearly mark a voltage-domain crossing
- Maintain technology abstraction
- Enable safe physical implementation
- Allow future changes without touching top-level RTL

---

### Module Interface

- RTL Definition

```bash
module xres_buf (
    X,
    A,
`ifdef USE_POWER_PINS
    VPWR,
    VGND,
    LVPWR,
    LVGND,
`endif
);
```
---

### Port Description

| Port Name | Direction | Domain      | Description                          |
| --------- | --------- | ----------- | ------------------------------------ |
| `X`       | inout     | 3.3V (Pad)  | External reset input from I/O pad    |
| `A`       | inout     | 1.8V (Core) | Reset signal forwarded to core logic |
| `VPWR`    | inout     | 3.3V        | Pad power supply (optional)          |
| `VGND`    | inout     | GND         | Pad ground (optional)                |
| `LVPWR`   | inout     | 1.8V        | Core power supply (optional)         |
| `LVGND`   | inout     | GND         | Core ground (optional)               |

---

### Functionality

- Logical Behavior
```bash
assign A = X;
```

- The module is purely combinational
- No inversion, delay, or state
- Output A always follows input X

---

### Level Shifting Explanation

- No explicit level-shifter is instantiated in RTL
- SCL180 pad cells (e.g., PC3D21) include built-in 3.3V → 1.8V level shifters
- Adding an extra level-shifter in RTL would:
	- Be redundant
	- Potentially break timing
	- Cause incorrect silicon behavior
- Hence, direct passthrough is correct and intentional.

---
### Power-Aware Design Considerations

- inout ports are used instead of input/output to:
	- Match pad modeling conventions
	- Allow tri-state behavior if required by test or physical flows

- USE_POWER_PINS guards:

	- Enable LVS/DRC correctness
	- Avoid polluting simple RTL simulations with power nets

- This makes xres_buf portable across flows:
	- RTL simulation
	- Unit-level testbenches
	- Synthesis
	- Place & route
	- Signoff (LVS/DRC)
---

### Testbench and Verification

**Verification Objective**

- The testbench verifies that:
	- A follows X exactly
	- No inversion occurs
	- No unintended logic is introduced
	- inout ports are driven correctly

---

## Test Results (RTL Simulation)

### Simulation Output

![image](../images/xres_sim.png)

✔ Functional correctness verified
✔ No unresolved drivers
✔ Clean elaboration and simulation

---
## Waveform Results
### VCD Generation

![image](../images/xres.png)

**Observations (GTKWave)**

- X_drv drives the pad signal
- X reflects the driven value
- A follows X exactly with no delay
- Hence, Waveform confirms pure pass-through behavior

---
### Summary

`xres_buf` safely propagates the external reset signal from the `3.3V` pad domain to the `1.8V` core domain using pad-integrated level shifting, implemented as a clean and power-aware RTL pass-through.








