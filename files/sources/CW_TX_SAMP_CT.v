`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.02.2026 13:37:31
// Design Name: 
// Module Name: CW_TX_SAMP_CT
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CW_TX_SAMP_CT(
    input wire UART_CE,
    input wire CLK,
    input wire RST,
    input wire TXCT_R,
    output TX_CE
    );
    
    reg [2:0] counter = 0;
    
    always @(posedge CLK, posedge RST) begin
        if (RST) begin
            counter <= 0;
        end else begin
            if (TXCT_R) begin
                counter <= 0;
            end else if (UART_CE) begin
                counter <= counter + 1;
            end
        end
    end
    
    assign TX_CE = &counter & UART_CE;
    
endmodule
