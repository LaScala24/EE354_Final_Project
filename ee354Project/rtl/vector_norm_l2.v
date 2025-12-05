`timescale 1ns / 1ps

module vector_norm_l2 #(
    parameter integer WIDTH = 4,
    parameter integer NORM_WIDTH = WIDTH + 2
) (
    input  wire clk,
    input  wire reset,
    input  wire start,
    input  wire [4*WIDTH-1:0] V_in,
    output reg  [NORM_WIDTH-1:0] norm_out,
    output reg done
);

    localparam integer SUM_BITS = 2*WIDTH + 4;
    localparam [1:0] STATE_IDLE = 2'd0;
    localparam [1:0] STATE_ACCUM = 2'd1;
    localparam [1:0] STATE_SQRT = 2'd2;

    reg [1:0] state;
    reg [1:0] state_next;

    reg [1:0] idx;
    reg [1:0] idx_next;

    reg [SUM_BITS-1:0] sum_sq;
    reg [SUM_BITS-1:0] sum_sq_next;

    reg [SUM_BITS-1:0] rem;
    reg [SUM_BITS-1:0] rem_next;

    reg [NORM_WIDTH:0] root;
    reg [NORM_WIDTH:0] root_next;

    reg [SUM_BITS-1:0] bit_val;
    reg [SUM_BITS-1:0] bit_val_next;

    reg [4:0] iter;
    reg [4:0] iter_next;

    reg [NORM_WIDTH-1:0] norm_next;
    reg done_next;

    wire [WIDTH-1:0] lane_values [0:3];

    assign lane_values[0] = V_in[WIDTH-1:0];
    assign lane_values[1] = V_in[2 * WIDTH-1: WIDTH];
    assign lane_values[2] = V_in[3* WIDTH-1:2 *WIDTH];
    assign lane_values[3] = V_in[4 * WIDTH-1:3*WIDTH];

    //get current sample and square it
    wire [WIDTH-1:0] sample = lane_values[idx];
    wire [2*WIDTH-1:0] sample_sq = sample *sample;
    wire [SUM_BITS-1:0] sample_sq_ext ={{(SUM_BITS-2*WIDTH){1'b0}}, sample_sq};
    wire [SUM_BITS-1:0] sqrt_seed = {{(SUM_BITS-1){1'b0}}, 1'b1} << (2*WIDTH - 2);

    always @(*) 
        begin
        state_next = state;
        idx_next = idx;
        sum_sq_next = sum_sq;
        rem_next = rem;
        root_next = root;
        bit_val_next = bit_val;
        iter_next = iter;
        norm_next = norm_out;
        done_next = 1'b0;

        case (state)
            STATE_IDLE: 
                begin
                if (start) 
                    begin
                    state_next = STATE_ACCUM;
                    idx_next = 2'd0;
                    sum_sq_next = {SUM_BITS{1'b0}};
                    end
                end

            STATE_ACCUM: 
                begin
                //accumulate sum of squares
                sum_sq_next = sum_sq + sample_sq_ext;
                if (idx == 2'd3) 
                    begin
                    
                    state_next = STATE_SQRT;
                    rem_next = sum_sq + sample_sq_ext;
                    root_next = {(NORM_WIDTH+1){1'b0}};
                    bit_val_next = sqrt_seed;

                    iter_next = NORM_WIDTH;

                    end 
                else 
                    begin
                    idx_next = idx + 1'b1;
                    end
                end

            STATE_SQRT: 
                begin
                //binary search square root algorithm
                if (iter != 0) 
                    begin
                    //try adding bit, if works keep it
                    if (rem >= (root + bit_val) ) 
                        begin
                        rem_next = rem - (root + bit_val);
                        root_next = (root >> 1) + bit_val;
                        end 
                    else 
                        begin

                        rem_next = rem;

                        root_next = root >> 1;

                        end
                    bit_val_next = bit_val >>2;
                    iter_next = iter -1'b1;
                    end 
                else 
                    begin
                    norm_next = root[NORM_WIDTH-1:0];
                    done_next = 1'b1;
                    state_next = STATE_IDLE;
                    end
                end

            default: 
                begin
                state_next = STATE_IDLE;
                end
        endcase
        end

    always @(posedge clk) 
        begin
        if (reset) 
            begin
            state <= STATE_IDLE;
            idx <= 2'd0;
            sum_sq <= {SUM_BITS{1'b0}};
            rem <= {SUM_BITS{1'b0}};
            root <= {(NORM_WIDTH+1){1'b0}};
            bit_val <= {SUM_BITS{1'b0}};
            iter <= 5'd0;
            norm_out <= {NORM_WIDTH{1'b0}};
            done <= 1'b0;
            end 
        else 
            begin
            state <= state_next;
            idx <= idx_next;
            sum_sq <= sum_sq_next;
            rem <= rem_next;
            root <= root_next;
            bit_val <= bit_val_next;
            iter <= iter_next;

            norm_out <= norm_next;
            done <= done_next;
            end
        end

endmodule
