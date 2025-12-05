`timescale 1ns / 1ps

module vector_max #(
    parameter integer WIDTH = 12
) (
    input  wire clk,
    input  wire reset,
    input  wire start,
    input  wire [4*WIDTH-1:0] vec_in,
    output reg  [WIDTH-1:0] max_out,
    output reg  done
);

    localparam integer NUM_LANES = 4;

    wire [WIDTH-1:0] vals [0:NUM_LANES-1];
    reg busy;
    reg busy_next;
    reg done_next;
    reg [WIDTH-1:0] max_next;

    //unpack vector into 4 lanes
    assign vals[0] = vec_in[WIDTH-1:0];
    assign vals[1] =vec_in[2*WIDTH-1:WIDTH];
    assign vals[2] = vec_in[3*WIDTH-1:2*WIDTH];
    assign vals[3] = vec_in[4*WIDTH-1:3*WIDTH];

    //compare pairs then compare results
    wire [WIDTH-1:0] max_pair1 = (vals[0] > vals[1]) ? vals[0] : vals[1];
    wire [WIDTH-1:0] max_pair2 = (vals[2] > vals[3]) ? vals[2] : vals[3];
    wire [WIDTH-1:0] max_final = (max_pair1 > max_pair2) ? max_pair1 : max_pair2;

    always @(*) 
        begin
        busy_next = busy;
        done_next = 1'b0;
        max_next = max_out;

        //start computation when start signal comes
        if (start && !busy ) 
            begin

            busy_next =1'b1;
            end 
        else if (busy) 
            begin
            max_next = max_final;
            busy_next = 1'b0;
            done_next = 1'b1;
            end
        end

    always @(posedge clk) 
        begin
        if (reset) 
            begin
            busy <= 1'b0;
            max_out <= {WIDTH{1'b0}};
            done <= 1'b0;
            end 
        else 
            begin
            busy <= busy_next;
            max_out <= max_next;
            done <= done_next;
            end
        end

endmodule

