# Verilog UART Controller

A comprehensive, synthesizable UART (Universal Asynchronous Receiver/Transmitter) controller designed in Verilog. This project includes a full-duplex UART with FIFO buffers to prevent data loss and a self-checking testbench for robust verification.



## Features

* **Full-Duplex Communication:** Simultaneous transmission and reception of data.
* **FIFO Buffers:** Independent transmit (TX) and receive (RX) FIFOs to handle data flow between fast processors and the slower serial line.
* **Parameterized Design:** Easily configurable data width and baud rate.
* **Error Detection:** Implements parity and frame error checking.
* **Standard UART Frame:** Supports the standard frame format (Start Bit, Data Bits, Parity Bit, Stop Bit).
* **Self-Checking Testbench:** Includes a comprehensive testbench that verifies functionality through a back-to-back loopback test and reports a clear PASS/FAIL result.

## Project Structure

The project is divided into several modular components:

* `uart_wrapper.v`: The top-level UART module that integrates the transmitter, receiver, and baud rate generator.
* `transmitter_top.v`: The top-level transmitter module, containing the TX FSM and TX FIFO.
* `receiver_top.v`: The top-level receiver module, containing the RX FSM and RX FIFO.
* `uart_tx.v`: The core transmitter Finite State Machine (FSM).
* `uart_rx.v`: The core receiver Finite State Machine (FSM).
* `uart_fifo.v`: A generic, reusable FIFO buffer.
* `baud_rate_gen.v`: Generates the high-speed tick for 16x oversampling based on the system clock and desired baud rate.
* `uart_tb.v`: The self-checking testbench.

## Simulation

To verify the design, you can use any standard Verilog simulator (e.g., ModelSim, Vivado Simulator, Icarus Verilog).

The provided testbench (`uart_tb.v`):
1.  Instantiates two UART modules (`uart_A` and `uart_B`).
2.  Connects them in a back-to-back (loopback) configuration.
3.  Sends a packet of random data from `uart_A` to `uart_B`.
4.  Waits for the transmission to complete.
5.  Reads the data from `uart_B`'s receiver FIFO.
6.  Compares the received data with the original sent data.
7.  Prints a `PASS` or `FAIL` summary to the console.

## Synthesis

This design is fully synthesizable and can be implemented on an FPGA. To target a specific device, you will need to create a constraints file (e.g., `.xdc` for Xilinx FPGAs) to map the top-level ports (`clk`, `rst`, `rx`, `tx`, etc.) to the physical pins on your board.

## Author

* Vansh Sabharwal
