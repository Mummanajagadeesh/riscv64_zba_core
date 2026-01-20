# drawIO Conventions

### Signal Placement

* **Inputs on the Left**
  All input signals to a module are placed on the **left side** of the block.
* **Outputs on the Right**
  All output signals from a module are placed on the **right side** of the block.
* This ensures **left-to-right dataflow**, improving readability and traceability.

### Module Identification

* Each module is drawn as a **single outer rectangular block**.
* The **module name is placed below the block**, centered, to avoid clutter inside the diagram.

### Internal Function Representation

* Internal behavior (e.g., *pipeline register*, *mux logic*, *adder*, *control logic*) is shown as a **small labeled block inside** the module.
* This provides **functional context** without exposing RTL-level detail.

### Color Scheme (Consistent Across All Modules)

* **Red/Pink (`#f8cecc`)** → Datapath inputs (data, addresses, operands)
* **Green (`#d5e8d4`)** → Control signals (enable, select, flush, stall, clk, reset)
* **Blue (`#dae8fc`)** → Main module boundary
* **Purple (`#e1d5e7`)** → Internal logic description
* **Yellow (`#fff2cc`)** → Outputs / stage-to-stage signals

> The color scheme is kept **identical across all modules** to maintain visual consistency.

### Edge / Arrow Rules

* All connections use **orthogonal (right-angle) edges**.
* **No diagonal or crossing wires** are used.
* **Every input and every output has an explicit arrow**.
* No merged or implicit connections are allowed.

### Signal Granularity

* **Each signal is drawn independently** (no bundling or grouping).
* Bit-widths are explicitly shown (e.g., `[63:0]`, `[4:0]`, `[1:0]`).
* This enforces a **1:1 mapping between RTL ports and diagram ports**.

### Pipeline Registers

* Pipeline stages (IF/ID, ID/EX, EX/MEM, MEM/WB) are drawn as:

  * Clear register blocks
  * Inputs from the previous stage on the left
  * Outputs to the next stage on the right
* **Reset and flush signals are explicitly connected** and shown as control inputs.

## Bulk Conversion 

```
for f in drawio/*.drawio; do
  drawio --export --format png --scale 2 --transparent \
    --output "assets/$(basename "${f%.drawio}.png")" "$f"
done
```

