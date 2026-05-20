`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.05.2026 22:14:36
// Design Name: 
// Module Name: CW_DIS_ROM
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

module CW_DIS_ROM(
    input  wire [4:0]  ADDR,
    output wire [7:0]  DATA
);

reg [7:0] ROM [0:31];
initial $readmemh("dis_mem.mem", ROM);

assign DATA = ROM[ADDR];

endmodule
