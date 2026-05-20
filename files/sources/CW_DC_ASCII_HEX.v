`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Semenikhin A.V.
// 
// Create Date: 20.02.2026 21:09:25
// Design Name: 
// Module Name: CW_DC_ASCII_HEX
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: from ASCII to HEX converter
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CW_DC_ASCII_HEX(
    input wire [7:0] ASCII,
    output reg [3:0] HEX,
    output reg HEX_FLG
    );
    
    always @* begin
        case (ASCII)
            8'h30: begin HEX = 4'h0; HEX_FLG = 1'b1; end
            8'h31: begin HEX = 4'h1; HEX_FLG = 1'b1; end
            8'h32: begin HEX = 4'h2; HEX_FLG = 1'b1; end
            8'h33: begin HEX = 4'h3; HEX_FLG = 1'b1; end
            8'h34: begin HEX = 4'h4; HEX_FLG = 1'b1; end
            8'h35: begin HEX = 4'h5; HEX_FLG = 1'b1; end
            8'h36: begin HEX = 4'h6; HEX_FLG = 1'b1; end
            8'h37: begin HEX = 4'h7; HEX_FLG = 1'b1; end
            8'h38: begin HEX = 4'h8; HEX_FLG = 1'b1; end
            8'h39: begin HEX = 4'h9; HEX_FLG = 1'b1; end
            8'h41, 8'h61: begin HEX = 4'hA; HEX_FLG = 1'b1; end
            8'h42, 8'h62: begin HEX = 4'hB; HEX_FLG = 1'b1; end
            8'h43, 8'h63: begin HEX = 4'hC; HEX_FLG = 1'b1; end
            8'h44, 8'h64: begin HEX = 4'hD; HEX_FLG = 1'b1; end
            8'h45, 8'h65: begin HEX = 4'hE; HEX_FLG = 1'b1; end
            8'h46, 8'h66: begin HEX = 4'hF; HEX_FLG = 1'b1; end
            default: begin
                HEX = 4'h0;
                HEX_FLG = 1'b0;
            end
        endcase
    end
endmodule
