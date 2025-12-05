`timescale 1ns / 1ps

module vector_diff #(
    parameter integer WIDTH = 4
) (
    input  wire clk,
    input  wire reset,
    input  wire start,
    input  wire [4*WIDTH-1:0] vec_new,
    input  wire [4*WIDTH-1:0] vec_old,
    output reg  [WIDTH-1:0] max_diff,
    output reg done
);
    //bug fix(kamsi): timing failed HORRENDOUSLY here and the old divider
    localparam integer PIPE_CYCLES = 4;// 4 cycles to comp, split computation up. done for the sake of timing design, brother taught me to do
    reg [4*WIDTH-1:0] new_vec;
    reg [4*WIDTH-1:0] old_vec;

    reg [4*WIDTH-1:0] diff;

    reg [4*WIDTH-1:0] new_vec_next;
    reg [4*WIDTH-1:0] old_vec_next;
    reg [4*WIDTH-1:0] diff_next;

    reg [PIPE_CYCLES-1:0] start_pipe;// old
    reg [PIPE_CYCLES-1:0] start_pipe_next;//new

    reg done_flag;
    reg done_flag_next;

    reg [WIDTH-1:0] max_diff_next;
    reg done_next;

    //abs diff result and max from it
    wire [4*WIDTH-1:0] diff_lane;
    wire [WIDTH-1:0]   max_lane;

    always @(*) 
        begin
        new_vec_next = vec_new;
        old_vec_next = vec_old;
        
        diff_next = diff_lane;
        start_pipe_next = {start_pipe[PIPE_CYCLES-2:0], start};

        done_next =1'b0;
        done_flag_next =done_flag;
        max_diff_next = max_diff;

        if (start) 
            begin
            done_flag_next = 1'b0;
            end

        if (start_pipe[PIPE_CYCLES-1]) 
            begin
            max_diff_next = max_lane;
            done_flag_next = 1'b1;
            done_next = 1'b1;
            end 
        else if (!start && done_flag) 
            begin
            done_next = 1'b1;
            end
        end

    always @(posedge clk) 
        begin
        if (reset) 
            begin

            new_vec <= {4*WIDTH{1'b0}};
            old_vec <= {4*WIDTH{1'b0}};

            diff <= {4*WIDTH{1'b0}};
            start_pipe <= {PIPE_CYCLES{1'b0}};
            max_diff <= {WIDTH{1'b0}};

            done <= 1'b0;
            done_flag <= 1'b0;

            end 
        else 
            begin
            new_vec <= new_vec_next;
            old_vec <= old_vec_next;

            diff <= diff_next;
            start_pipe <= start_pipe_next;
            max_diff <= max_diff_next;

            done <= done_next;
            done_flag <= done_flag_next;

            end
        end

    //calc abs diff between vectors
    abs_diff #(.WIDTH(WIDTH)) diff_unit 
    (
        .vec_new(new_vec),
        .vec_old(old_vec),
        .vec_diff(diff_lane)
    );

    //find max of differences
    max_finder #(.WIDTH(WIDTH)) max_unit 
    (
        .clk(clk),
        .reset(reset),
        .lane_values(diff),
        .max_value(max_lane)
    );

endmodule
