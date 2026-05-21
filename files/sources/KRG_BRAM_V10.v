`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        Module
// Engineer:       Kryakhtunov G.M.
// 
// Create Date:    2023.31.01 11:47:06
// Design Name: 
// Module Name:    KRG_BRAM_V10 
// Project Name:   Any
// Target Devices: Any FPGA or ASIC
// Tool versions:  Xilinx DS 14.7
// Description:    BRAM Read-Ahead
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
//
//////////////////////////////////////////////////////////////////////////////////
module KRG_BRAM_V10 # (
    parameter UAW = 9,
    parameter UDW = 64
)
(
    // System:
    input CLK,
    // Memory Interface:
    input [UAW-1:0]      Address,
    input                Write_Enable,
    input [UDW-1:0]      Write_Data,
    input                Read_Enable,
    output reg [UDW-1:0] Read_Data
);

reg [UDW-1:0] BRAM [0:(2**UAW)-1];
always @(posedge CLK)
 if(Read_Enable | Write_Enable)
  begin
   if(Write_Enable) BRAM[Address] <= Write_Data;
   Read_Data <= BRAM[Address];
  end


endmodule
