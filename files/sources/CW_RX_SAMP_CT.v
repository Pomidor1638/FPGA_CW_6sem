`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.02.2026 09:51:49
// Design Name: 
// Module Name: CW_RX_SAMP_CT
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: RX sample counter
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CW_RX_SAMP_CT (
    input wire UART_CE,
    input wire CLK,
    input wire RST,
    input wire RXCT_R,
    output RX_CE
    );
    
    reg [2:0] counter = 0;
    
    always @(posedge CLK, posedge RST) begin
        if (RST) begin
            counter <= 0;
        end else begin
            if (RXCT_R) begin
                counter <= 0;
            end else if (UART_CE) begin
                counter <= counter + 1;
            end
        end
    end
    
    assign RX_CE = counter[0] & counter[1] & ~counter[2] & UART_CE;
    
endmodule
