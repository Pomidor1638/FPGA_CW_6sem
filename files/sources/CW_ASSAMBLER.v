`timescale 1ns / 1ps

module CW_ASSAMBLER (
    input  wire        CLK,
    input  wire        RST,
    
    input  wire        RX_RDY_T,
    input  wire  [7:0] RX_DATA_R,
    output reg         RX_RDY_R,
    
    output reg         CMD_RDY_T,
    output wire [51:0] CMD_DATA_T,
    input  wire        CMD_RDY_R,
    
    output wire  [7:0] ASCII_DATA,
    input  wire        HEX_FLG,
    input  wire  [3:0] DC_ASCII_HEX
);

    localparam CMD_RESET = 4'b0000;
    localparam CMD_RUN   = 4'b0001;
    localparam CMD_STEP  = 4'b0010;
    localparam CMD_STOP  = 4'b0011;
    localparam CMD_MWR   = 4'b0100;
    localparam CMD_MRD   = 4'b0101;
    localparam CMD_PWR   = 4'b0110;
    localparam CMD_PRD   = 4'b0111;
    localparam CMD_ERR   = 4'b1111;

    localparam CHAR_SPACE = 8'h20;
    localparam CHAR_CR    = 8'h0D;
    localparam CHAR_LF    = 8'h0A;

    localparam ST_IDLE  = 0,
               ST_R1    = 1,  ST_U    = 2,  ST_N    = 3, 
               ST_E1    = 4,  ST_S2   = 5,  ST_E2   = 6,  ST_T1   = 7,
               ST_S1    = 8,  ST_T2   = 9,  ST_O    = 10, ST_P2   = 11, ST_E3 = 12, ST_P3 = 13,
               ST_P1    = 14, ST_W1   = 15, ST_R3   = 16, ST_R2   = 17, ST_D1 = 18,
               ST_M     = 19, ST_MW1  = 20, ST_MR3  = 21, ST_MR2  = 22, ST_MD1= 23,
               ST_ROPR  = 24, ST_EROPR= 25, ST_ERCMD= 26, ST_TRANS= 27;

    reg [4:0]  state;
    reg [3:0]  CMD;
    reg [15:0] ADDR;
    reg [31:0] DATA;
    reg [2:0]  DATA_CT;
    reg        OPR2_FLG;

    assign ASCII_DATA = RX_DATA_R;
    assign CMD_DATA_T = {CMD, ADDR, DATA};

    wire [2:0] END_CT;

    assign END_CT = (~OPR2_FLG) ? 3'h3 : (CMD[1] ? 3'h7 : 3'h1);

    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            state     <= ST_IDLE;
            RX_RDY_R  <= 1'b1;
            CMD_RDY_T <= 1'b0;
            DATA_CT   <= 3'b000;
            CMD       <= 4'd0;
            ADDR      <= 16'd0;
            DATA      <= 32'd0;
            OPR2_FLG  <= 1'b0;
        end else begin
            case (state)
                ST_IDLE: begin
                    RX_RDY_R  <= 1'b1;
                    CMD_RDY_T <= 1'b0;
                    DATA_CT   <= 3'b000;
                    OPR2_FLG  <= 1'b0;
                    CMD       <= 4'd0;
                    
                    if (RX_RDY_T) begin
                        if (RX_DATA_R == "R") state <= ST_R1;
                        else if (RX_DATA_R == "S") state <= ST_S1;
                        else if (RX_DATA_R == "P") state <= ST_P1;
                        else if (RX_DATA_R == "M") state <= ST_M;
                        else begin
                            CMD <= CMD_ERR;
                            CMD_RDY_T <= 1'b1;
                            state <= ST_TRANS;
                        end
                    end
                end

                ST_R1: begin
                    if (RX_RDY_T) begin
                        if (RX_DATA_R == "U") state <= ST_U;
                        else if (RX_DATA_R == "E") state <= ST_E1;
                        else begin CMD <= CMD_ERR; CMD_RDY_T <= 1'b1; state <= ST_TRANS; end
                    end
                end
                ST_U: begin
                    if (RX_RDY_T) begin
                        if (RX_DATA_R == "N") state <= ST_N;
                        else begin CMD <= CMD_ERR; CMD_RDY_T <= 1'b1; state <= ST_TRANS; end
                    end
                end
                ST_N: begin
                    if (RX_RDY_T) begin
                        if (RX_DATA_R == CHAR_CR) begin CMD <= CMD_RUN; state <= ST_ERCMD; end
                        else begin CMD <= CMD_ERR; CMD_RDY_T <= 1'b1; state <= ST_TRANS; end
                    end
                end
                ST_E1: begin
                    if (RX_RDY_T) begin
                        if (RX_DATA_R == "S") state <= ST_S2;
                        else begin CMD <= CMD_ERR; CMD_RDY_T <= 1'b1; state <= ST_TRANS; end
                    end
                end
                ST_S2: begin
                    if (RX_RDY_T) begin
                        if (RX_DATA_R == "E") state <= ST_E2;
                        else begin CMD <= CMD_ERR; CMD_RDY_T <= 1'b1; state <= ST_TRANS; end
                    end
                end
                ST_E2: begin
                    if (RX_RDY_T) begin
                        if (RX_DATA_R == "T") state <= ST_T1;
                        else begin CMD <= CMD_ERR; CMD_RDY_T <= 1'b1; state <= ST_TRANS; end
                    end
                end
                ST_T1: begin
                    if (RX_RDY_T) begin
                        if (RX_DATA_R == CHAR_CR) begin CMD <= CMD_RESET; state <= ST_ERCMD; end
                        else begin CMD <= CMD_ERR; CMD_RDY_T <= 1'b1; state <= ST_TRANS; end
                    end
                end

                ST_S1: begin
                    if (RX_RDY_T) begin
                        if (RX_DATA_R == "T") state <= ST_T2;
                        else begin CMD <= CMD_ERR; CMD_RDY_T <= 1'b1; state <= ST_TRANS; end
                    end
                end
                ST_T2: begin
                    if (RX_RDY_T) begin
                        if (RX_DATA_R == "O") state <= ST_O;
                        else if (RX_DATA_R == "E") state <= ST_E3;
                        else begin CMD <= CMD_ERR; CMD_RDY_T <= 1'b1; state <= ST_TRANS; end
                    end
                end
                ST_O: begin
                    if (RX_RDY_T) begin
                        if (RX_DATA_R == "P") state <= ST_P2;
                        else begin CMD <= CMD_ERR; CMD_RDY_T <= 1'b1; state <= ST_TRANS; end
                    end
                end
                ST_P2: begin
                    if (RX_RDY_T) begin
                        if (RX_DATA_R == CHAR_CR) begin CMD <= CMD_STOP; state <= ST_ERCMD; end
                        else begin CMD <= CMD_ERR; CMD_RDY_T <= 1'b1; state <= ST_TRANS; end
                    end
                end
                ST_E3: begin
                    if (RX_RDY_T) begin
                        if (RX_DATA_R == "P") state <= ST_P3;
                        else begin CMD <= CMD_ERR; CMD_RDY_T <= 1'b1; state <= ST_TRANS; end
                    end
                end
                ST_P3: begin
                    if (RX_RDY_T) begin
                        if (RX_DATA_R == CHAR_CR) begin CMD <= CMD_STEP; state <= ST_ERCMD; end
                        else begin CMD <= CMD_ERR; CMD_RDY_T <= 1'b1; state <= ST_TRANS; end
                    end
                end

                ST_P1: begin
                    if (RX_RDY_T) begin
                        if (RX_DATA_R == "W") state <= ST_W1;
                        else if (RX_DATA_R == "R") state <= ST_R2;
                        else begin CMD <= CMD_ERR; CMD_RDY_T <= 1'b1; state <= ST_TRANS; end
                    end
                end
                ST_W1: begin
                    if (RX_RDY_T) begin
                        if (RX_DATA_R == "R") state <= ST_R3;
                        else begin CMD <= CMD_ERR; CMD_RDY_T <= 1'b1; state <= ST_TRANS; end
                    end
                end
                ST_R3: begin
                    if (RX_RDY_T) begin
                        if (RX_DATA_R == CHAR_SPACE) begin CMD <= CMD_PWR; state <= ST_ROPR; end
                        else begin CMD <= CMD_ERR; CMD_RDY_T <= 1'b1; state <= ST_TRANS; end
                    end
                end
                ST_R2: begin
                    if (RX_RDY_T) begin
                        if (RX_DATA_R == "D") state <= ST_D1;
                        else begin CMD <= CMD_ERR; CMD_RDY_T <= 1'b1; state <= ST_TRANS; end
                    end
                end
                ST_D1: begin
                    if (RX_RDY_T) begin
                        if (RX_DATA_R == CHAR_SPACE) begin CMD <= CMD_PRD; state <= ST_ROPR; end
                        else begin CMD <= CMD_ERR; CMD_RDY_T <= 1'b1; state <= ST_TRANS; end
                    end
                end

                ST_M: begin
                    if (RX_RDY_T) begin
                        if (RX_DATA_R == "W") state <= ST_MW1;
                        else if (RX_DATA_R == "R") state <= ST_MR2;
                        else begin CMD <= CMD_ERR; CMD_RDY_T <= 1'b1; state <= ST_TRANS; end
                    end
                end
                ST_MW1: begin
                    if (RX_RDY_T) begin
                        if (RX_DATA_R == "R") state <= ST_MR3;
                        else begin CMD <= CMD_ERR; CMD_RDY_T <= 1'b1; state <= ST_TRANS; end
                    end
                end
                ST_MR3: begin
                    if (RX_RDY_T) begin
                        if (RX_DATA_R == CHAR_SPACE) begin CMD <= CMD_MWR; state <= ST_ROPR; end
                        else begin CMD <= CMD_ERR; CMD_RDY_T <= 1'b1; state <= ST_TRANS; end
                    end
                end
                ST_MR2: begin
                    if (RX_RDY_T) begin
                        if (RX_DATA_R == "D") state <= ST_MD1;
                        else begin CMD <= CMD_ERR; CMD_RDY_T <= 1'b1; state <= ST_TRANS; end
                    end
                end
                ST_MD1: begin
                    if (RX_RDY_T) begin
                        if (RX_DATA_R == CHAR_SPACE) begin CMD <= CMD_MRD; state <= ST_ROPR; end
                        else begin CMD <= CMD_ERR; CMD_RDY_T <= 1'b1; state <= ST_TRANS; end
                    end
                end

                ST_ROPR: begin
                    if (RX_RDY_T) begin
                        if (HEX_FLG) begin
                            if (OPR2_FLG) 
                                DATA <= {DATA[27:0], DC_ASCII_HEX};
                            else 
                                ADDR <= {ADDR[11:0], DC_ASCII_HEX};

                            if (DATA_CT == END_CT) begin
                                DATA_CT <= 3'b000;
                                OPR2_FLG <= OPR2_FLG | (CMD == CMD_PRD) | (CMD == CMD_MRD);
                                state <= ST_EROPR;
                            end else begin
                                DATA_CT <= DATA_CT + 1'b1;
                            end
                        end else begin
                            CMD <= CMD_ERR; CMD_RDY_T <= 1'b1; state <= ST_TRANS;
                        end
                    end
                end

                ST_EROPR: begin
                    if (RX_RDY_T) begin
                        if (~OPR2_FLG && RX_DATA_R == CHAR_SPACE) begin
                            OPR2_FLG <= 1'b1;
                            state <= ST_ROPR;
                        end else if (OPR2_FLG && RX_DATA_R == CHAR_CR) begin
                            state <= ST_ERCMD;
                        end else begin
                            CMD <= CMD_ERR; CMD_RDY_T <= 1'b1; state <= ST_TRANS;
                        end
                    end
                end

                ST_ERCMD: begin
                    if (RX_RDY_T) begin
                        if (RX_DATA_R == CHAR_LF) begin
                            CMD_RDY_T <= 1'b1; 
                            state <= ST_TRANS;
                        end else begin
                            CMD <= CMD_ERR; CMD_RDY_T <= 1'b1; state <= ST_TRANS;
                        end
                    end
                end

                ST_TRANS: begin
                    if (CMD_RDY_R) begin
                        CMD_RDY_T <= 1'b0;
                        OPR2_FLG  <= 1'b0;
                        RX_RDY_R  <= 1'b1;
                        state     <= ST_IDLE;
                    end
                end
            endcase
        end
    end
endmodule
