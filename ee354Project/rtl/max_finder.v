`timescale 1ns / 1ps

module max_finder #(
    parameter integer WIDTH = 4
) (
    input  wire clk,
    input  wire reset,
    input  wire [4*WIDTH-1:0] lane_values,
    output reg  [WIDTH-1:0] max_value
);

    localparam integer NUM_LANES = 4;

    wire [WIDTH-1:0] data [0:NUM_LANES-1];

    genvar i;
    //unpack input into lanes
    generate
        for (i = 0; i < NUM_LANES; i = i + 1) begin : gen_unpack
            localparam integer LO = i * WIDTH;
            localparam integer HI = LO + WIDTH - 1;
            assign data[i] = lane_values[HI:LO];
        end
    endgenerate

    //find max of each pair
    wire [WIDTH-1:0] pair1 = ((data[0] > data[1] )) ? data[0] : data[1];
    wire [WIDTH-1:0] pair2 = (data[2] > data[3] ) ? data[2] : data[3];

    //register pairs for final comparison
    reg [WIDTH-1:0] pair1_reg;
    reg [WIDTH-1:0] pair2_reg;

    always @(posedge clk) 
        begin
        if (reset) 
            begin
            pair1_reg <= {WIDTH{1'b0}};
            pair2_reg <= {WIDTH{1'b0}};
            max_value <= {WIDTH{1'b0}};
            end 
        else 
            begin
            pair1_reg <= pair1;
            pair2_reg <=pair2;
            max_value <= ((pair1_reg > pair2_reg )) ? pair1_reg : pair2_reg;
            end
        end

endmodule
