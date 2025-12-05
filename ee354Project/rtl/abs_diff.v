`timescale 1ns / 1ps

module abs_diff #(
    parameter integer WIDTH = 4
) (
    input  wire [4 * WIDTH-1:0] vec_new,
    input  wire [4 * WIDTH-1:0] vec_old,
    output wire [4 * WIDTH-1:0] vec_diff// init vars 4 times width for overflow protection in the math
);

    localparam integer NUM_LANES = 4;

    wire [WIDTH-1:0] new_val [0:NUM_LANES-1];
    wire [WIDTH-1:0] old_val [0:NUM_LANES-1];
    wire [WIDTH-1:0] abs_val [0:NUM_LANES-1];

    genvar i;

    generate
        for (i = 0; i < NUM_LANES; i = i + 1) begin : gen_lane
            localparam integer LO = i * WIDTH;
            localparam integer HI = LO + WIDTH - 1;

            //This is the abs difference calculation which says that if the new matrix > then old then set the new to old - new which is a key aspect of the algo design

            //Set thresh.
            assign new_val[i] = vec_new[HI:LO];
            assign old_val[i] =vec_old[HI:LO];

            assign abs_val[i] = ((new_val[i] >= old_val[i] )) ? (new_val[i] - old_val[i]) : (old_val[i] -new_val[i] ); //From above 

            assign vec_diff[HI:LO] = abs_val[i];
        end
    endgenerate

endmodule
