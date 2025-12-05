`timescale 1ns / 1ps

module vector_scale #(
    parameter integer IN_WIDTH = 12,
    parameter integer OUT_WIDTH = 4,
    parameter integer MAX_WIDTH = 12
) (
    input  wire clk,
    input  wire reset,
    input  wire start,
    input  wire [4*IN_WIDTH-1:0]  V_in,
    input  wire [MAX_WIDTH-1:0]   max_value,
    output reg  [4*OUT_WIDTH-1:0] V_out,
    output reg  done
);

    localparam integer NUM_LANES = 4;

    localparam [1:0] IDLE = 2'd0;
    localparam [1:0] COMPUTE = 2'd1;

    reg [1:0] state;
    reg [1:0] state_next;
    reg [4*OUT_WIDTH-1:0] v_out_next;
    reg done_next;

    //extract each lane
    wire [IN_WIDTH - 1:0] val0 = V_in[0 * IN_WIDTH +: IN_WIDTH];
    wire [IN_WIDTH - 1:0] val1 = V_in[1 * IN_WIDTH +: IN_WIDTH];
    wire [IN_WIDTH - 1:0] val2 = V_in[2 * IN_WIDTH +: IN_WIDTH];
    wire [IN_WIDTH - 1:0] val3 = V_in[3 * IN_WIDTH +: IN_WIDTH];

    wire [IN_WIDTH -1:0] max_pair1 = (val0 > val1) ? val0 : val1;
    wire [IN_WIDTH -1:0] max_pair2 = (val2 > val3) ? val2 : val3;
    wire [IN_WIDTH -1:0] max_val = (max_pair1 > max_pair2) ? max_pair1 : max_pair2;

    reg [3:0] msb_pos;

    always @(*) 
        begin
        if (max_val[11]) msb_pos = 4'd11;
        else if (max_val[10]) msb_pos = 4'd10;
        else if (max_val[9]) msb_pos = 4'd9;
        else if (max_val[8]) msb_pos = 4'd8;
        else if (max_val[7]) msb_pos =4'd7;
        else if (max_val[6]) msb_pos = 4'd6;
        else if (max_val[5]) msb_pos = 4'd5;
        else if (max_val[4]) msb_pos = 4'd4;
        else if (max_val[3]) msb_pos = 4'd3;
        else if (max_val[2]) msb_pos = 4'd2;
        else if (max_val[1]) msb_pos = 4'd1;
        else msb_pos = 4'd0;
        end

    wire [3:0] shift = (max_val == 0 ) ? 4'd0 : ((4'd11 -msb_pos ));
    wire [14:0] scale = 15'd15 <<shift;

    //multiply by scale factor
    wire [26:0] prod0 = val0 * scale;
    wire [26:0] prod1 = val1 * scale;
    wire [26:0] prod2 = val2 * scale;
    wire [26:0] prod3 = val3 * scale;

    //shift right to get result
    wire [15:0] res0 = prod0[26:11];
    wire [15:0] res1 = prod1[26:11];
    wire [15:0] res2 = prod2[26:11];
    wire [15:0] res3 = prod3[26:11];

    wire [OUT_WIDTH - 1:0] scaled0 = (max_val == 0) ? 4'd0 : ((res0 >16'd15) ? 4'd15 : res0[3:0]);
    wire [OUT_WIDTH - 1:0] scaled1 = (max_val == 0) ? 4'd0 : ((res1 > 16'd15) ? 4'd15 : res1[3:0]);
    wire [OUT_WIDTH - 1:0] scaled2 = (max_val== 0) ? 4'd0 : ((res2 > 16'd15) ? 4'd15 : res2[3:0]);
    wire [OUT_WIDTH - 1:0] scaled3 = (max_val == 0) ? 4'd0 : ((res3 > 16'd15) ? 4'd15 : res3[3:0]);

    wire [4 * OUT_WIDTH - 1:0] scaled_vec = {scaled3, scaled2,scaled1, scaled0};

    always @(*) 
        begin
        state_next = state;
        v_out_next = V_out;
        done_next = 1'b0;

        case (state)
            IDLE: 
                begin

                if (start) 
                    begin
                    state_next = COMPUTE;
                    end
                end

            COMPUTE: 
                begin
                //output scaled result
                v_out_next = scaled_vec;
                done_next = 1'b1;
                state_next = IDLE;
                end

            default: 
                begin
                state_next = IDLE;
                end
        endcase
        end

    always @(posedge clk) 
        begin
        if (reset) 
            begin

            state <= IDLE;
            V_out <= {(4*OUT_WIDTH){1'b0}};

            done <= 1'b0;
            end 
        else 
            begin

            state <= state_next;
            V_out <= v_out_next;
            
            done <= done_next;
            end
        end

endmodule
