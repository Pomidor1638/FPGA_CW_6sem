`timescale 1ns / 1ps

module CW_PROCESSOR (
    input  wire        CLK,
    input  wire        RST,
    
    // DRP ODPS FROM AS
    input  wire        CMD_RDY_T,
    input  wire [51:0] CMD_DATA_R,
    output reg         CMD_RDY_R,
    
    // DTP ODPS TO DIS
    output reg         RES_RDY_T,
    output wire [51:0] RES_DATA_T,
    input  wire        RES_RDY_R,
    
    output reg         CEO,
    output reg         RSTO,
    
    output reg         PGM_S_EX_REQ,
    output reg  [17:2] PGM_S_ADDR,
    output reg  [3:0]  PGM_S_NBE,
    output reg  [2:0]  PGM_S_CMD,
    output reg  [31:0] PGM_S_D_WR,
    input  wire        PGM_S_EX_ACK,
    input  wire [31:0] PGM_S_D_RD,
    
    output reg         DM_S_EX_REQ,
    output reg  [15:0] DM_S_ADDR,
    output reg  [2:0]  DM_S_CMD,
    output reg  [7:0]  DM_S_D_WR,
    input  wire        DM_S_EX_ACK,
    input  wire [7:0]  DM_S_D_RD
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

    localparam ST_IDLE = 3'd0,
               ST_HCMD = 3'd1,
               ST_WRST = 3'd2,
               ST_WCEO = 3'd3,
               ST_WDM  = 3'd4,
               ST_WPGM = 3'd5,
               ST_TRES = 3'd6;

    reg [2:0]  state;
    reg [3:0]  CMD;
    reg [15:0] ADDR;
    reg [31:0] DATA;

    assign RES_DATA_T = {CMD, ADDR, DATA};

    initial begin
        state        = ST_IDLE;
        CMD_RDY_R    = 1'b1;
        RES_RDY_T    = 1'b0;
        CEO          = 1'b0;
        RSTO         = 1'b0;
        PGM_S_EX_REQ = 1'b0;
        PGM_S_ADDR   = 16'd0;
        PGM_S_NBE    = 4'b0000;
        PGM_S_CMD    = 3'b000;
        PGM_S_D_WR   = 32'd0;
        DM_S_EX_REQ  = 1'b0;
        DM_S_ADDR    = 16'd0;
        DM_S_CMD     = 3'b000;
        DM_S_D_WR    = 8'd0;
        CMD          = 4'd0;
        ADDR         = 16'd0;
        DATA         = 32'd0;
    end

    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            state        <= ST_IDLE;
            CMD_RDY_R    <= 1'b1;
            RES_RDY_T    <= 1'b0;
            CEO          <= 1'b0;
            RSTO         <= 1'b0;
            
            PGM_S_EX_REQ <= 1'b0;
            PGM_S_ADDR   <= 16'd0;
            PGM_S_NBE    <= 4'b0000;
            PGM_S_CMD    <= 3'b000;
            PGM_S_D_WR   <= 32'd0;
            
            DM_S_EX_REQ  <= 1'b0;
            DM_S_ADDR    <= 16'd0;
            DM_S_CMD     <= 3'b000;
            DM_S_D_WR    <= 8'd0;
            
            CMD          <= 4'd0;
            ADDR         <= 16'd0;
            DATA         <= 32'd0;
        end else begin
            case (state)
                ST_IDLE: begin
                    if (CMD_RDY_T) begin
                        CMD_RDY_R  <= 1'b0;
                        
                        CMD  <= CMD_DATA_R[51:48];
                        ADDR <= CMD_DATA_R[47:32];
                        DATA <= CMD_DATA_R[31:0];
                        
                        PGM_S_ADDR <= CMD_DATA_R[47:32];
                        PGM_S_D_WR <= CMD_DATA_R[31:0];
                        
                        DM_S_ADDR  <= CMD_DATA_R[47:32];
                        DM_S_D_WR  <= CMD_DATA_R[7:0]; 
                        
                        state <= ST_HCMD;
                    end
                end

                ST_HCMD: begin
                    case (CMD)
                        CMD_RESET: begin
                            RSTO <= 1'b1;
                            state <= ST_WRST;
                        end
                        CMD_STEP: begin
                            CEO <= 1'b1;
                            state <= ST_WCEO;
                        end
                        CMD_RUN, CMD_STOP: begin
                            CEO <= ~CMD[1]; 
                            RES_RDY_T <= 1'b1;
                            state <= ST_TRES;
                        end
                        CMD_MWR, CMD_MRD: begin
                            DM_S_EX_REQ <= 1'b1;
                            DM_S_CMD    <= (CMD[0] == 1'b0) ? 3'b001 : 3'b101;
                            state <= ST_WDM;
                        end
                        CMD_PWR, CMD_PRD: begin
                            PGM_S_EX_REQ <= 1'b1;
                            PGM_S_CMD    <= (CMD[0] == 1'b0) ? 3'b001 : 3'b101;
                            state <= ST_WPGM;
                        end
                        default: begin 
                            RES_RDY_T <= 1'b1;
                            state <= ST_TRES;
                        end
                    endcase
                end

                ST_WRST: begin
                    RSTO <= 1'b0;
                    RES_RDY_T <= 1'b1;
                    state <= ST_TRES;
                end

                ST_WCEO: begin
                    CEO <= 1'b0;
                    RES_RDY_T <= 1'b1;
                    state <= ST_TRES;
                end

                ST_WDM: begin
                    if (DM_S_EX_ACK) begin
                        DM_S_EX_REQ <= 1'b0; // REQ ADD?
                        RES_RDY_T   <= 1'b1;
                        if (CMD == CMD_MRD) begin
                            DATA <= {24'd0, DM_S_D_RD}; // ADD 0-Fullification
                        end
                        state <= ST_TRES;
                    end
                end

                ST_WPGM: begin
                    if (PGM_S_EX_ACK) begin
                        PGM_S_EX_REQ <= 1'b0; // REQ ADD?
                        RES_RDY_T    <= 1'b1;
                        if (CMD == CMD_PRD) begin
                            DATA <= PGM_S_D_RD;
                        end
                        state <= ST_TRES;
                    end
                end

                ST_TRES: begin
                    if (RES_RDY_R) begin
                        RES_RDY_T <= 1'b0;
                        CMD_RDY_R <= 1'b1; 
                        state <= ST_IDLE;
                    end
                end
            endcase
        end
    end
endmodule
