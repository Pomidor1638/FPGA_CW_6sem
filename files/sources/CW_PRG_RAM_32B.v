`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Kudryashov D.S.
//
// Create Date: 21.05.2026
// Module Name: CW_PRG_RAM_32B
// Description: Writable 32-bit program memory with STI 1.0 interface
//////////////////////////////////////////////////////////////////////////////////

module CW_PRG_RAM_32B (
    input  wire        CLK,
    input  wire        RST,

    input  wire        S_EX_REQ,
    input  wire [11:2] S_ADDR,
    input  wire [2:0]  S_CMD,
    input  wire [31:0] S_D_WR,
    output wire        S_EX_ACK,
    output wire [31:0] S_D_RD
);

    reg [31:0] RAM [0:1023];

    initial $readmemh("prg_mem.mem", RAM);

    always @(posedge CLK) begin
        if (S_EX_REQ && !S_CMD[2])
            RAM[S_ADDR] <= S_D_WR;
    end

    assign S_D_RD   = (S_EX_REQ && S_CMD[2]) ? RAM[S_ADDR] : 32'h0000_0000;
    assign S_EX_ACK = 1'b1;

endmodule
