# Final System: UART-Controlled ALU and Register File

[cite_start]This repository contains the hardware description language (HDL) implementation of a system that performs **Arithmetic Logic Unit (ALU)** and **Register File (RegFile)** operations based on commands received via a **Universal Asynchronous Receiver-Transmitter (UART)** interface[cite: 223].

[cite_start]The system is designed to receive commands from a master (e.g., a testbench or external processor) through its **UART\_RX** interface, execute the specified operation (ALU or RegFile access), and send the result back to the master through the **UART\_TX** interface[cite: 223, 277].

## ⚙️ System Architecture

[cite_start]The core system, operating across two clock domains, consists of 10 primary blocks[cite: 41].

### Top-Level Diagram



### Clock Domains and Core Blocks

| Clock Domain | Clock Signal | Blocks in Domain | Description |
| :--- | :--- | :--- | :--- |
| **Domain 1 (High-Speed)** | [cite_start]**REF\_CLK** (50 MHz) [cite: 272] | [cite_start]**SYS\_CTRL**, **RegFile**, **ALU**, **Clock Gating**, **RST Synchronizer 1** [cite: 41, 47, 44, 45, 46, 57] | Handles command processing, register access, and ALU execution. |
| **Domain 2 (UART)** | [cite_start]**UART\_CLK** (3.6864 MHz) [cite: 272] | [cite_start]**UART\_TX**, **UART\_RX**, **PULSE\_GEN**, **Clock Dividers**, **RST Synchronizer 2** [cite: 41, 50, 51, 53, 55, 57] | Handles serial communication and timing generation. |
| **Asynchronous Bridge** | N/A | [cite_start]**ASYNC FIFO**, **Data Synchronizer** [cite: 59, 58] | Provides Clock Domain Crossing (CDC) for data passing between the UART and the main control logic. |

---

## 💾 Register File (RegFile)

[cite_start]The RegFile is an $8 \times 16$ register file, meaning it has **16 registers** in total, with data being **8 bits** wide by default[cite: 71, 78].

### Reserved Registers (Configuration & Operands)

[cite_start]Addresses **$0\times0$** to **$0\times3$** are reserved for system configuration and ALU operands[cite: 279].

| Address | Register | Description | Fields | Default Value | Connected to |
| :--- | :--- | :--- | :--- | :--- | :--- |
| [cite_start]**$0\times0$** [cite: 80] | **REG0** | [cite_start]ALU Operand A [cite: 81] | $7:0$ | N/A | [cite_start]ALU (A) [cite: 78] |
| [cite_start]**$0\times1$** [cite: 82] | **REG1** | [cite_start]ALU Operand B [cite: 83] | $7:0$ | N/A | [cite_start]ALU (B) [cite: 78] |
| [cite_start]**$0\times2$** [cite: 84] | **REG2** | [cite_start]UART Config [cite: 85] | [cite_start]$7:2$ (Prescale) [cite: 90] | [cite_start]32 [cite: 91] | [cite_start]UART\_RX [cite: 178] |
| | | | [cite_start]$1$ (Parity Type) [cite: 88] | [cite_start]0 [cite: 89] | [cite_start]UART [cite: 164, 178] |
| | | | [cite_start]$0$ (Parity Enable) [cite: 86] | [cite_start]1 [cite: 87] | [cite_start]UART [cite: 164, 178] |
| [cite_start]**$0\times3$** [cite: 92] | **REG3** | [cite_start]Division Ratio [cite: 93] | [cite_start]$7:0$ (Div\_Ratio) [cite: 93] | [cite_start]32 [cite: 94] | [cite_start]Clock Divider [cite: 78, 150] |

[cite_start]*Normal Read/Write operations are supported for addresses **$0\times4$** to **$0\times15$**[cite: 278].*

---

## 🧮 Supported Operations

### [cite_start]1. Register File Operations [cite: 240]

* [cite_start]Register File Write [cite: 241]
* [cite_start]Register File Read [cite: 242]

### [cite_start]2. ALU Operations [cite: 225]

| Category | [cite_start]Operation [cite: 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239] |
| :--- | :--- |
| **Arithmetic** | Addition, Subtraction, Multiplication, Division |
| **Logical** | AND, OR, NAND, NOR, XOR, XNOR |
| **Comparison (CMP)** | $A=B$, $A>B$ |
| **Shift** | $A>>1$ (Shift Right by 1), $A<<1$ (Shift Left by 1) |

---

## 📜 Command Protocol (UART Frames)

[cite_start]Commands are received frame-by-frame via the **UART\_RX** interface[cite: 277]. [cite_start]The system must be configured by writing to addresses $0\times2$ and $0\times3$ before performing other operations[cite: 275].

### [cite_start]1. Register File Write Command (3 frames) [cite: 244]

| Frame Index | Content | Description |
| :--- | :--- | :--- |
| **Frame 0** | [cite_start]`RF_Wr_CMD` ($0\times\text{AA}$) [cite: 250] | Write Command Code |
| **Frame 1** | [cite_start]`RF_Wr_Addr` [cite: 249] | Address to write to |
| **Frame 2** | [cite_start]`RF_Wr_Data` [cite: 246] | Data to be written |

### [cite_start]2. Register File Read Command (2 frames) [cite: 251]

| Frame Index | Content | Description |
| :--- | :--- | :--- |
| **Frame 0** | [cite_start]`RF_Rd_CMD` ($0\times\text{BB}$) [cite: 255] | Read Command Code |
| **Frame 1** | [cite_start]`RF_Rd_Addr` [cite: 254] | Address to read from |

### [cite_start]3. ALU Operation Command with Operand (4 frames) [cite: 256]

Used for operations where the operands are passed directly with the command.

| Frame Index | Content | Description |
| :--- | :--- | :--- |
| **Frame 0** | [cite_start]`ALU_OPER_W_OP_CMD` ($0\times\text{CC}$) [cite: 264] | ALU Operation with Operand Command Code |
| **Frame 1** | [cite_start]`Operand A` [cite: 263] | Value for ALU Operand A (written to REG0) |
| **Frame 2** | [cite_start]`Operand B` [cite: 262] | Value for ALU Operand B (written to REG1) |
| **Frame 3** | [cite_start]`ALU FUN` [cite: 261] | 4-bit ALU Function code |

### [cite_start]4. ALU Operation Command with No Operand (2 frames) [cite: 265]

Used for operations that use existing values in REG0/REG1 (e.g., if set by a previous operation or RF Write).

| Frame Index | Content | Description |
| :--- | :--- | :--- |
| **Frame 0** | [cite_start]`ALU_OPER_W_NOP_CMD` ($0\times\text{DD}$) [cite: 269] | ALU Operation with No Operand Command Code |
| **Frame 1** | [cite_start]`ALU FUN` [cite: 268] | 4-bit ALU Function code |

---

## 💻 Simulation and Testbench

[cite_start]The provided system expects an accompanying **TestBench** module to simulate the master (CPU/device) which sends commands via **RX\_IN** and checks results via **TX\_OUT**[cite: 19, 276, 277].

### Test Sequence Requirement

[cite_start]The testbench sequence **must** include[cite: 274]:
1.  [cite_start]**Initial Configuration:** Write operations to reserved addresses **$0\times2$** and **$0\times3$** to set the UART Config and Division Ratio[cite: 275].
2.  [cite_start]**Command Execution:** Send different commands (RegFile Operations and ALU Operations) to the system[cite: 276].
3.  [cite_start]**Result Verification:** Monitor the **UART\_TX** output for results sent by the system's **SYS\_CTRL** block[cite: 277].

### Clock Specifications

* [cite_start]**Reference Clock (REF\_CLK):** $50 \text{ MHz}$ [cite: 272]
* [cite_start]**UART Clock (UART\_CLK):** $3.6864 \text{ MHz}$ [cite: 272]
* [cite_start]**Clock Divider:** Always enabled (`clk_div_en = 1`)[cite: 273].

---

## 📂 Repository Contents

* `Final_System.pdf`: Project documentation and specifications (Source of this README).
* `sys_ctrl.v`: The main control logic, implemented as a Finite State Machine (FSM).
* `regfile.v`: Implementation of the 8x16 Register File.
* `alu.v`: Implementation of the Arithmetic Logic Unit.
* `uart_tx.v`: UART Transmitter module.
* `uart_rx.v`: UART Receiver module.
* `clk_gate.v`: Clock Gating logic for the ALU.
* `clk_divider.v`: Clock Divider modules to generate UART baud rate clocks.
* `pulse_gen.v`: Pulse Generator logic.
* `rst_sync.v`: Reset Synchronizer (RST\_SYNC) for CDC.
* `data_sync.v`: Data Synchronizer (Data\_Sync) for CDC.
* `async_fifo.v`: Asynchronous FIFO for TX path CDC.
* `sys_top.v`: Top-level module connecting all blocks.
* `sys_tb.v`: (Testbench file).
