# PAD Reset Analysis – SCL-180 vs SKY130

## Objective
This document analyzes the reset pad requirements in the SCL-180 I/O library and explains why a dedicated digital POR is **not required** for SCL-180, in contrast to SKY130-based Caravel designs.

---
## 1. Reset Pad Behavior in SCL-180

### Observation from RTL

- In the SCL-180 wrapper and pad connections:

```verilog
.ENABLE_H(porb_h)
.INP_DIS(por)
```

**Key observations:**

- Reset pads do not require POR-generated enables
- Pad enable is controlled by logic-level signals
- No internal pad POR dependency is visible
---

## 2. Asynchronous Nature of Reset Pin

- From usage across the RTL:

```bash
always @(posedge clk or negedge porb)
```

**This proves:**

    - Reset is asynchronous
    - Reset does not rely on clock availability
    - Reset is valid as soon as the pad input is stable
---

## 3. Availability After VDD

**In SCL-180:**

- Pad input buffers are direct CMOS
- No power-domain crossing required for reset
- No dependency on internal POR to enable pad receivers

**Therefore:**

- Reset pin is available immediately after VDD ramp
- External reset can safely control initialization
---

## 4. Why SKY130 Required POR

- In SKY130-based Caravel:

    - Reset pad buffers depended on internal enables
    - I/O pads required POR-driven gating
    - Level shifters were not always active at power-up

**Therefore:**

- A digital POR was mandatory to guarantee reset availability
---

## 5. Why SCL-180 Does NOT Require POR

```bash
| Feature                 | SKY130           | SCL-180         |
|-------------------------|-----------------|----------------|
| Reset pad enable        | POR-dependent    | Always available |
| Level shifters          | External         | Integrated      |
| Pad power-up dependency | Yes              | No              |
| Mandatory POR           | Yes              | No              |
| Conclusion              | -                | -               |
```
---
## Conclusion

- SCL-180 I/O pads do not require POR-driven gating or internal enables.
- The reset pin is asynchronous, immediately available after VDD, and safe to use as the sole reset source.
- This makes POR logic architecturally unnecessary.

---
