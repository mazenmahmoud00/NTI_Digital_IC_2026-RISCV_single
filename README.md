# NTI Digital IC Summer 2026

# 1) Labs

This directory contains the core source files, verification environments, build artifacts, and automation scripts for the digital integrated circuit design labs.

## 📂 Directory Structure

* **`build/`**: Working directory used for compilation outputs, synthesis reports, and running simulations.
* **`rtl/`**: Houses the synthesizable Register-Transfer Level (RTL) source files (Verilog/SystemVerilog hardware description logic).
* **`script/`**: Contains automation scripts configured with self-contained relative paths, allowing you to build and execute seamlessly from any terminal.
* **`tb/`**: Contains testbenches and verification components used for functional simulation and waveform validation.

## 🚀 Running Simulations

All script paths are fully adjusted. To run codes via Questa or ModelSim from any terminal, navigate to the **`build/`** directory and run the do-file from the scripts folder:

```bash
cd build
vsim -do ../script/<script_name>.do
```

# 2) Final Project

# RISC-V Single-Cycle Processor

A **32-bit RISC-V Single-Cycle Processor** implemented in Verilog HDL as part of the **NTI Digital IC Summer 2026 Training**.

The project covers the complete **RTL design, functional verification, simulation, and synthesis flow**, starting from the RISC-V instruction set and RTL implementation and progressing to synthesis using **Synopsys Design Compiler (`dc_shell`)**.

The processor is implemented using a modular single-cycle datapath containing the Program Counter, Instruction Memory, Register File, ALU, Immediate Extension Unit, Control Unit, and Data Memory.

---

## Features

* 32-bit RISC-V processor
* Single-cycle datapath
* Modular Verilog RTL implementation
* 32 general-purpose registers
* Instruction memory
* Data memory
* Immediate generation and sign extension
* ALU supporting arithmetic and logical operations
* Main control decoder
* ALU decoder
* Conditional branching using `BEQ`
* Load/store memory operations
* Assembly programs converted to machine-code HEX files
* Dedicated Verilog testbench
* RTL simulation using **QuestaSim**
* Logic synthesis using **Synopsys Design Compiler**
* Synthesis using **`dc_shell`**
* Timing and area analysis
* RTL-to-gate-level design flow

---

# Supported Instructions

The current implementation supports a subset of the **RV32I** instruction set.

## R-Type

| Instruction | Description            |
| ----------- | ---------------------- |
| `ADD`       | Addition               |
| `SUB`       | Subtraction            |
| `AND`       | Bitwise AND            |
| `OR`        | Bitwise OR             |
| `SLT`       | Set Less Than          |

## I-Type

| Instruction | Description                      |
| ----------- | -------------------------------- |
| `ADDI`      | Add Immediate                    |
| `ANDI`      | AND Immediate                    |
| `ORI`       | OR Immediate                     |
| `SLTI`      | Set Less Than Immediate          |
| `LW`        | Load Word                        |

## S-Type

| Instruction | Description |
| ----------- | ----------- |
| `SW`        | Store Word  |

## B-Type

| Instruction | Description     |
| ----------- | --------------- |
| `BEQ`       | Branch if Equal |

---

# Project Structure

```text
risc_v_single_cycle_processor/
│
├── Images/
│   └── Processor / simulation / synthesis images
│
├── rtl/
│   ├── adder.v
│   ├── alu.v
│   ├── alu_decoder.v
│   ├── control.v
│   ├── data_mem.v
│   ├── extend.v
│   ├── instruction_mem.v
│   ├── main_decoder.v
│   ├── program_counter.v
│   ├── reg_file.v
│   └── riscv_single.v
│
├── tb/
│   └── tb_riscv_single.v
│
├── program/
│   ├── program_control.s
│   ├── program_control.hex
│   ├── program_mem.s
│   ├── program_mem.hex
│   ├── program_r_type&imm.s
│   └── program_r_type&imm.hex
│
├── script/
│   └── Simulation / build / synthesis scripts
│
├── build/
│   └── Build outputs, simulation files and reports
│
└── syn/
    └── Synthesis files and reports
```

---

# RTL Design

The processor is divided into multiple RTL modules to keep the design modular and easy to verify.

## `riscv_single.v`

The top-level module of the processor.

It integrates:

* Program Counter
* Instruction Memory
* Register File
* Control Unit
* Immediate Extension
* ALU
* Data Memory
* PC + 4 adder
* Branch target calculation
* ALU input selection
* Write-back selection

---

## `program_counter.v`

Stores the current program counter and updates it every clock cycle.

The next PC can be either:

```text
PC + 4
```

or the calculated branch target when a branch instruction is taken.

---

## `instruction_mem.v`

Implements the instruction memory.

The current implementation uses a 256-word memory:

```verilog
reg [31:0] mem [0:255];
```

Instructions are word-aligned and accessed using the appropriate address bits.

The instruction memory is initialized with machine-code HEX files generated from the assembly test programs.

---

## `reg_file.v`

Implements the RISC-V register file.

The register file provides:

* Two read ports
* One write port
* Register write enable
* Clocked register writes

The testbench also checks register contents to verify the processor's execution results.

---

## `alu.v`

The ALU performs the main arithmetic and logical operations.

Current operations include:

```text
ADD
SUB
AND
OR
SLT
```

The ALU also generates a `zero` flag.

The `zero` flag is particularly important for the `BEQ` instruction because it indicates whether the two compared operands are equal.

---

## `extend.v`

Generates the immediate value according to the instruction format and performs the required sign extension.

The implementation handles:

* I-Type immediate
* S-Type immediate
* B-Type immediate

---

## `main_decoder.v`

The main decoder generates the processor control signals according to the instruction opcode.

Important control signals include:

```text
Branch
ResultSrc
MemWrite
ALUSrc
ImmSrc
RegWrite
ALUOp
```

These signals determine how the datapath behaves for each instruction type.

---

## `alu_decoder.v`

The ALU decoder generates the required ALU control signal using instruction fields such as:

* `ALUOp`
* `funct3`
* `funct7`

This allows the processor to select the required ALU operation for R-Type, immediate, memory, and branch instructions.

---

## `data_mem.v`

Implements the processor's data memory.

It is used by:

```text
LW
SW
```

The ALU calculates the memory address using:

```text
Base Register + Immediate
```

---

# Instruction Execution

## R-Type Instructions

Example:

```asm
add x4, x1, x2
```

Execution:

```text
Instruction Fetch
       ↓
Register Read
       ↓
ALU Operation
       ↓
Write Back
```

The two source registers are read from the register file, processed by the ALU, and the result is written to the destination register.

---

## I-Type Instructions

Example:

```asm
addi x3, x1, 10
```

The immediate value is extracted from the instruction and passed through the immediate extension unit.

The ALU then performs:

```text
Register + Immediate
```

and the result is written back to the destination register.

---

## Load Word - `LW`

Example:

```asm
lw x4, 16(x0)
```

Execution:

```text
Base Register + Immediate
          ↓
      ALU Address
          ↓
      Data Memory
          ↓
      Register File
```

The calculated address is used to read the requested data from memory, and the loaded value is written back to the destination register.

---

## Store Word - `SW`

Example:

```asm
sw x3, 16(x0)
```

Execution:

```text
Base Register + Immediate
          ↓
      ALU Address
          ↓
      Data Memory
          ↑
     Register Data
```

The ALU calculates the memory address, while the data from the source register is written to that address.

---

## Branch Equal - `BEQ`

Example:

```asm
beq x1, x2, label
```

For `BEQ`, the ALU compares the two register operands by subtraction:

```text
x1 - x2
```

If the result is zero:

```text
zero = 1
```

the branch condition becomes true and the branch target is selected as the next PC.

Otherwise, the processor continues with:

```text
PC + 4
```

---

# Verification & Testbench

A dedicated Verilog testbench is provided in:

```text
tb/tb_riscv_single.v
```

The testbench is responsible for:

* Generating the clock
* Applying reset
* Loading the required HEX program
* Running the processor for the required number of cycles
* Monitoring registers
* Monitoring memory
* Checking expected results
* Verifying control-flow behavior

The testbench allows the processor to be tested at the system level rather than verifying each RTL module independently.

---

# Test Cases

The verification environment is divided into multiple test programs, each targeting a specific group of processor functionality.

## 1. R-Type and Immediate Instructions

Program:

```text
program/program_r_type&imm.s
```

HEX file:

```text
program/program_r_type&imm.hex
```

This test program verifies arithmetic, logical, comparison, and immediate operations.

The tested instructions include:

```text
ADD
SUB
AND
OR
XOR
SLT
ORI
ANDI
SLTI
```

The purpose of this test is to verify:

* Register file read operations
* Register file write operations
* ALU operation selection
* Immediate generation
* ALU source selection
* Write-back functionality
* Control signal generation

---

## 2. Control Flow Test

Program:

```text
program/program_control.s
```

HEX file:

```text
program/program_control.hex
```

This test focuses on conditional branching using:

```text
BEQ
```

The test verifies that the processor correctly:

1. Reads the two source registers.
2. Compares their values.
3. Generates the ALU `zero` flag.
4. Determines whether the branch is taken.
5. Calculates the branch target.
6. Selects the correct next PC.
7. Continues execution from the correct instruction.

This test is particularly important because branch instructions affect the normal sequential PC flow.

---

## 3. Memory Test

Program:

```text
program/program_mem.s
```

HEX file:

```text
program/program_mem.hex
```

This test verifies the processor's memory instructions:

```text
SW
LW
```

The testbench checks that a value is correctly stored into memory and can subsequently be loaded back into a register.

For example, the testbench checks the store operation by verifying that:

```text
Memory[16] = 50
```

and then verifies that the same value can be loaded into:

```text
x4
```

This test verifies the complete memory datapath:

```text
Register File
      ↓
     ALU
      ↓
Data Memory
      ↓
Register File
```

---

# Simulation

The processor is simulated using:

**QuestaSim 2024.1**

The project scripts are configured with relative paths so that the simulations can be executed from the `build/` directory.

Typical flow:

```bash
cd build
vsim -do ../script/<script_name>.do
```

The simulation flow is:

```text
Compile RTL
     ↓
Compile Testbench
     ↓
Start Simulation
     ↓
Apply Reset
     ↓
Load HEX Program
     ↓
Generate Clock
     ↓
Run Simulation
     ↓
Check Results
```

The testbench uses `$readmemh` to load the machine-code program into instruction memory.

Example:

```verilog
$readmemh("../program/program_control.hex", dut.imem.mem);
```

---

# Reset

The processor includes an active reset input:

```verilog
input rst
```

The testbench applies reset before starting program execution.

Reset initializes the processor state and allows execution to start from the expected program counter value.

---

# Synthesis

After completing RTL functional verification, the processor is synthesized using:

**Synopsys Design Compiler**

The synthesis environment is accessed through:

```text
dc_shell
```

The purpose of synthesis is to transform the synthesizable RTL description into a **technology-mapped gate-level netlist** using the target standard-cell library.

The synthesis process also allows the design to be evaluated in terms of:

* Area
* Timing
* Critical path
* Slack
* Cell utilization
* Power estimation

---

# RTL-to-Gate-Level Flow

```text
       Verilog RTL
            │
            ▼
    RTL Functional
     Verification
            │
            ▼
       QuestaSim
            │
            ▼
     Verified RTL
            │
            ▼
   Synopsys Design Compiler
            │
         dc_shell
            │
            ▼
     RTL Elaboration
            │
            ▼
     Apply Constraints
            │
            ▼
    Logic Optimization
            │
            ▼
     Technology Mapping
            │
            ▼
   Gate-Level Netlist
            │
      ┌─────┼─────┐
      ▼     ▼     ▼
    Area  Timing Power
   Report Report Report
```

---

# Synopsys Design Compiler Flow

The synthesis flow is performed using the Design Compiler command-line environment:

```bash
dc_shell
```

The synthesis scripts are maintained in the project `script/` directory, while synthesis-related outputs and reports are stored under:

```text
syn/
```

---

## 1. RTL Analysis

The Verilog source files are analyzed by Design Compiler.

Example:

```tcl
analyze -format verilog {
    ../rtl/adder.v
    ../rtl/alu.v
    ../rtl/alu_decoder.v
    ../rtl/control.v
    ../rtl/data_mem.v
    ../rtl/extend.v
    ../rtl/instruction_mem.v
    ../rtl/main_decoder.v
    ../rtl/program_counter.v
    ../rtl/reg_file.v
    ../rtl/riscv_single.v
}
```

The purpose of this stage is to check and analyze the RTL source files before elaboration.

---

## 2. Elaboration

The top-level design is elaborated using:

```tcl
elaborate riscv_single
```

During elaboration, Design Compiler builds the complete design hierarchy and resolves the connections between the RTL modules.

---

## 3. Clock Definition

A clock constraint is applied to the processor.

Example:

```tcl
create_clock -name clk -period 10 [get_ports clk]
```

A 10 ns clock period corresponds to a target frequency of:

```text
100 MHz
```

The clock constraint is essential for timing optimization and analysis.

---

## 4. Design Constraints

Additional constraints can be applied to describe the expected operating environment.

Typical constraints include:

```tcl
set_input_delay
set_output_delay
set_clock_uncertainty
set_driving_cell
set_load
```

These constraints help Design Compiler optimize the design according to the desired timing requirements.

---

## 5. Synthesis and Optimization

The RTL is synthesized and optimized using:

```tcl
compile
```

Depending on the synthesis configuration, a more aggressive optimization command can also be used:

```tcl
compile_ultra
```

During compilation, Design Compiler performs logic optimization and maps the RTL design to cells available in the target standard-cell library.

---

# Synthesis Reports

After synthesis, different reports are generated to evaluate the implementation.

## Area Report

Command:

```tcl
report_area
```

The area report provides information about the hardware resources used by the synthesized processor.

Important parameters include:

* Combinational area
* Sequential area
* Total cell area
* Number of cells

---

## Timing Report

Command:

```tcl
report_timing
```

The timing report identifies the critical timing paths through the design.

Important parameters include:

* Critical path
* Startpoint
* Endpoint
* Data arrival time
* Data required time
* Slack

The timing report can be used to determine whether the design meets the target clock period.

---

## Constraint Report

Command:

```tcl
report_constraint -all_violators
```

This report is used to identify timing and design-constraint violations.

A properly constrained design should be checked for setup, hold, and other relevant violations depending on the synthesis environment.

---

## Power Report

When power analysis is configured, the following command can be used:

```tcl
report_power
```

The power report can provide estimates for:

* Internal power
* Switching power
* Leakage power
* Total power

---

# Synthesis Output

The synthesis stage produces a technology-mapped representation of the processor.

Typical outputs include:

```text
Gate-Level Netlist
Timing Reports
Area Reports
Constraint Reports
Power Reports
Synthesis Logs
```

These files are organized in the synthesis/build directories.

The synthesis results provide an initial evaluation of the processor's hardware cost and timing performance.

---

# Used Tools

| Tool                             | Usage                                               |
| -------------------------------- | --------------------------------------------------- |
| **Verilog HDL**                  | RTL hardware design                                 |
| **QuestaSim 2024.1**             | RTL simulation and functional verification          |
| **Synopsys Design Compiler**     | RTL synthesis and technology mapping                |
| **`dc_shell`**                   | Command-line interface for Synopsys Design Compiler |
| **RISC-V Assembler / Toolchain** | Assembly to machine-code generation                 |
| **Git**                          | Version control                                     |
| **GitHub**                       | Project hosting and collaboration                   |

---

# Design Flow Summary

The complete development flow can be summarized as:

```text
RISC-V ISA
    ↓
Assembly Programs
    ↓
Machine Code / HEX
    ↓
Verilog RTL Design
    ↓
RTL Simulation
    ↓
Functional Verification
    ↓
Synopsys Design Compiler
    ↓
dc_shell
    ↓
Synthesis
    ↓
Logic Optimization
    ↓
Technology Mapping
    ↓
Timing / Area / Power Analysis
    ↓
Gate-Level Netlist
```

---

# Learning Objectives

This project demonstrates practical experience with:

* RISC-V ISA
* RV32I instruction encoding
* Single-cycle CPU architecture
* Datapath design
* Control-unit design
* ALU design
* Register-file implementation
* Instruction memory
* Data memory
* Immediate generation
* Branch handling
* RTL design using Verilog
* Testbench development
* Functional verification
* QuestaSim simulation
* Clock and timing constraints
* Logic synthesis
* Synopsys Design Compiler
* `dc_shell`
* Technology mapping
* Area analysis
* Timing analysis
* RTL-to-gate-level design flow

---

# Future Improvements

Possible extensions include:

* Add more RV32I instructions
* Add `BNE`
* Add `BLT`
* Add `BGE`
* Add `JAL`
* Add `JALR`
* Improve automated pass/fail verification
* Add SystemVerilog assertions
* Add more comprehensive test cases
* Perform gate-level simulation
* Add power analysis
* Optimize area and timing
* Implement a pipelined RISC-V processor
* Continue from synthesis toward physical design

---

# Author

**Mazen Mahmoud**

---

# Repository

GitHub Repository:

https://github.com/mazenmahmoud00/NTI_DIGITAL_IC_SUMMER_2026/tree/main/risc_v_single_cycle_processor

Linkedin:

https://www.linkedin.com/in/mazen-mahmoud-411a60322/?isSelfProfile=true
