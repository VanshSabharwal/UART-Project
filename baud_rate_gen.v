`timescale 1ns / 1ps

module baud_rate_gen (clk, rst, S_tick);
    parameter BAUD_RATE = 9600;  // Desired baud rate
    parameter CLK_FREQ = 50000000; // System clock frequency in Hz
    
    input clk, rst;
    output reg S_tick;  // Output tick pulse (16x baud rate)
    
    // Divider value to generate 16x baud rate tick
    localparam DIV = CLK_FREQ / (BAUD_RATE * 16);
    
    // Width of counter based on DIV value
    localparam WIDTH = $clog2(DIV);

     reg [WIDTH - 1 : 0] count;

    always @ (posedge clk, posedge rst) begin
        if (rst) begin
            S_tick <= 1'b0;
            count <= 0;
        end
        else begin
            if (count == (DIV - 1)) begin
                count <= 0;
                S_tick <= 1'b1;
            end
            else begin
                count <= count + 1'b1;
                S_tick <= 1'b0;
            end
        end
    end
endmodule