# VSD Caravel
## Refractored by : Divya Darshan VR
## debug_regs.v — Debug Register Block Documentation


### Overview

- debug_regs.v implements a Wishbone slave debug register block used for internal visibility and debug during SoC bring-up and verification.
- The module exposes two 32-bit registers that can be read and written via the Wishbone bus.

**This block is typically used for:**

- Sanity checks during simulation
- Software ↔ hardware debug visibility
- Validation of Wishbone transactions

---
## Interface Summary

### Clock & Reset

| Signal     | Direction | Description       |
| ---------- | --------- | ----------------- |
| `wb_clk_i` | Input     | Wishbone clock    |
| `wb_rst_i` | Input     | Active-high reset |

### Wishbone Interface

| Signal            | Direction | Description          |
| ----------------- | --------- | -------------------- |
| `wbs_cyc_i`       | Input     | Cycle valid          |
| `wbs_stb_i`       | Input     | Strobe               |
| `wbs_we_i`        | Input     | Write enable         |
| `wbs_sel_i[3:0]`  | Input     | Byte select          |
| `wbs_adr_i[31:0]` | Input     | Address              |
| `wbs_dat_i[31:0]` | Input     | Write data           |
| `wbs_dat_o[31:0]` | Output    | Read data            |
| `wbs_ack_o`       | Output    | Transfer acknowledge |

### Register Map

| Address Offset | Register Name | Access | Description      |
| -------------- | ------------- | ------ | ---------------- |
| `0x8`          | `debug_reg_1` | R/W    | Debug register 1 |
| `0xC`          | `debug_reg_2` | R/W    | Debug register 2 |

- Byte-wise writes are supported using wbs_sel_i
- Reads return the full 32-bit register value

---
## Functional Behavior
### Write Operation

- A write occurs when:
```bash
wbs_cyc_i == 1
wbs_stb_i == 1
wbs_we_i  == 1
wbs_ack_o == 0
```
- Byte lanes are honored using wbs_sel_i
- wbs_ack_o is asserted for one cycle

### Read Operation

- A read occurs when:
```bash
wbs_cyc_i == 1
wbs_stb_i == 1
wbs_we_i  == 0
wbs_ack_o == 0
```
- wbs_dat_o returns register content
- wbs_ack_o is asserted for one cycle

### Idle Behavior

- When no Wishbone transaction is active:
	- wbs_ack_o = 0
	- wbs_dat_o = 0 (legacy behavior)
- This behavior was explicitly tested using the NO-TRANSACTION test case in the testbench.

---
## debug_regs.v — Proposed Read-Hold Logic (Under Verification)

### Background

- During review of `debug_regs.v`, an alternative Wishbone read implementation was identified and added to the RTL as commented code.
- This logic modifies how wbs_dat_o behaves when no transaction is active.

### Existing (Active) Behavior

- When no Wishbone transaction is active:
```bash
wbs_dat_o <= 32'h0;
wbs_ack_o <= 1'b0;
```

- This means:
	- Read data is cleared to zero when idle
	- Simple and safe, but not strictly required by Wishbone spec

This behavior is:
- ✔ Deterministic
- ✔ Easy to debug
- ✔ Currently VERIFIED

---
### Verification Status

- ✔ RTL simulation (Icarus Verilog)
- ✔ RTL simulation (Synopsys VCS)
- ✔ Idle case verified
- ✔ Read / write paths verified
- ✔ Byte-enable logic verified


### SIMULATION OUTPUTS

**RTL SIMULATION**

![RTL](../images/debug_term.png)


![gtk](../images/debug_sim.png)

---
### Proposed (Commented) Logic

```bash
wbs_dat_o <= debug_reg_1;
else if (wbs_adr_i[3:0] == 4'hC)
    wbs_dat_o <= debug_reg_2;
else
    wbs_dat_o <= 32'h0;

// Signal completion of read
wbs_ack_o <= 1'b1;

// NOTE:
// wbs_dat_o is intentionally NOT cleared when idle.
// It holds the last read value, which is correct Wishbone behavior.

```
---
## What Changes?

### Key Difference

| Aspect              | Current Logic | Proposed Logic        |
| ------------------- | ------------- | --------------------- |
| Idle `wbs_dat_o`    | Forced to `0` | Holds last read value |
| Wishbone compliance | Valid         | More spec-accurate    |
| Risk                | Minimal       | Requires verification |

---
### Why This Matters

- Wishbone spec allows dat_o to remain stable after a read
- Some masters sample data after ACK
- Holding last value avoids glitches in such systems

---
### Verification Status

| Item                  | Status       |
| --------------------- | ------------ |
| RTL compiled          | ❌ Not active |
| Testbench coverage    | ❌ Pending    |
| Waveform review       | ❌ Pending    |
| Spec compliance check | ⚠️ Partial   |


### NOTE 

The logic is preserved for future compliance improvement, but intentionally kept inactive until full regression verification.

## Summary

### Module: `debug_regs.v`

### Current Status
- The existing RTL implementation is **functionally correct and verified**.
- All read and write operations behave as expected under Wishbone protocol.
- Simulation and regression tests pass successfully.

### Identified Improvement (Documented Only)
- A proposed enhancement was identified for the **read data path**:
  - Allow `wbs_dat_o` to **retain the last read value when idle**
  - This behavior is more aligned with the Wishbone specification
- The improved logic:
  - Is **present only as commented code**
  - Is **clearly documented**
  - Has **not been enabled**, pending full verification

### Verification Status

| Item | Status |
|----|----|
| Legacy RTL | ✅ Verified |
| Proposed improvement | 📝 Documented |
| Enabled in RTL | ❌ No |
| Verification completed | ⏳ Pending |


----



















































