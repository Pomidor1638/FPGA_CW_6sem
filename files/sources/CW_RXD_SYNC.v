`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.02.2026 09:25:28
// Design Name: 
// Module Name: CW_RXD_SYNC
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: UART RXD synchronizer
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CW_RXD_SYNC (
    input wire RXD,
    input wire CLK,
    input wire RST,
    output reg RXD_RG
    );
    
    reg SYNC_REG;
    
    initial begin
        RXD_RG = 1;
        SYNC_REG = 1;
    end
    
    always @(posedge CLK, posedge RST) begin
        if (RST) begin
            RXD_RG <= 1;
            SYNC_REG <= 1;
        end else begin
            SYNC_REG <= RXD;
            RXD_RG <= SYNC_REG;
        end
    end
    
endmodule
