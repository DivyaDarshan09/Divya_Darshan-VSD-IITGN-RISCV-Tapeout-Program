# POR Removal Justification

## Objective

- This document formally justifies the removal of the behavioral Power-On Reset (POR) model (`dummy_por`) from the VSDCaravel RTL and its replacement with a single explicit external reset pin.  
- The goal is to make reset behavior explicit, externally controlled, and architecturally unambiguous.
---

## 1. Motivation

The existing POR implementation (`dummy_por`) is **not a synthesizable digital block**. It is a **behavioral RTL model** intended to approximate an **analog RC-based power-on reset circuit** during simulation.

**Key observations:**

- The POR logic is **simulation-only**
- It does **not represent real synthesized logic**
- It generates reset purely through **behavioral delay modeling**
- No functional logic depends on analog ramp timing

### Architectural Concern (Not Analog Validity)

While analog POR is a valid and often required silicon concept, **this design already exposes an explicit external reset pin** intended to be driven by board-level or testbench logic.

**Retaining a behavioral POR model in this context:**

- Introduces an **unnecessary behavioral abstraction** in RTL
- Obscures the true source of reset (external vs internal)
- Makes reset behavior harder to reason about during verification
- Conflicts with **explicit-reset design principles**, where reset control
  should be visible, deterministic, and externally driven

This is an **architectural clarity issue**, not a critique of analog POR itself.

---

## 2. Replacement Strategy

The POR model is removed and replaced with a **single explicit external reset pin** at the top level.

```bash
input resetb; // Active-low external reset

#Legacy POR-related signals are explicitly derived from this pin:
assign porb_h = resetb;
assign porb_l = resetb;
assign por_l  = ~resetb;
assign rstb_h = resetb;
```

**Key Properties of the New Reset Scheme**

- No hidden behavior
- No counters
- No delay logic
- No power-edge detection
- Fully visible and testbench-controllable reset behavior
---
##  3. Functional Equivalence

```bash
| Original Signal | Replacement |
|-----------------|-------------|
| porb_h          | resetb      |
| porb_l          | resetb      |
| por_l           | ~resetb     |
| rstb_h          | resetb      |
```

- All downstream logic continues to receive reset signals in the same logical sense as before. No functional changes are introduced in reset consumption.
---

## 4. Compliance with Design Rules

```bash
| Rule                         | Status |
|-------------------------------|--------|
| No digital POR                | ✅     |
| No reset counters             | ✅     |
| No power-edge detection       | ✅     |
| Explicit reset behavior       | ✅     |
| Reset visible in RTL & simulation | ✅ |
```
---
## 5. Conclusion

- Removing the behavioral POR model and using an explicit external reset:

    - Preserves functional correctness
    - Improves architectural clarity
    - Makes reset behavior deterministic and observable
    - Simplifies verification and debug
    - Matches SCL-180 pad capabilities
    - Aligns with ASIC reset best practices

```
    While analog POR remains a valid silicon concept, modeling it behaviorally in RTL is unnecessary when reset is explicitly provided and externally controlled.
```

**This change is architecturally safe, technically correct, and justified.**
