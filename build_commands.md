# RISC-V software build flow

## Compile C test program to RISC-V assembly (RV64I)

```
riscv64-unknown-elf-gcc -ffreestanding -nostdlib -nostartfiles -march=rv64i -mabi=lp64 -S sw/test.c -o sw/test.s
```

---

## Assemble to object file

```
riscv64-unknown-elf-as sw/test.s -o sw/test.o
```

---

## Link using custom linker script

```
riscv64-unknown-elf-ld -T sw/linker.ld --entry=_start sw/test.o -o sw/test.elf
```

---

## Extract machine code for instruction memory initialization

```
riscv64-unknown-elf-objdump -d sw/test.elf | awk '/^[ ]*[0-9a-f]+:/ {print $2}' | sed '$d' > instruction.mem
```

---

# RTL simulation flow

## Compile SystemVerilog RTL and testbench

```
iverilog -g2012 -o sim.out tb/*.sv rtl/*.sv rtl/core/*.sv
```

---

## Run simulation

```
vvp sim.out
```

---

## View waveform

```
gtkwave risc.vcd
```