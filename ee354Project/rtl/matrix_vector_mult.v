`timescale 1ns / 1ps

module matrix_vector_mult #(
    parameter integer OUT_WIDTH = 12
) (
    input  wire clk,
    input  wire reset,
    input  wire  start,
    input  wire [16*4-1:0] A,
    input  wire [4*4-1:0] V,
    output reg  [4*OUT_WIDTH-1:0] Y,
    output reg done
);

    localparam integer PARTIAL_WIDTH = (OUT_WIDTH >= 10) ? OUT_WIDTH + 2 : 12;
    localparam [OUT_WIDTH-1:0] OUT_MAX = {OUT_WIDTH{1'b1}};
    localparam [PARTIAL_WIDTH-1:0] OUT_MAX_EXT = {{(PARTIAL_WIDTH-OUT_WIDTH){1'b0}}, OUT_MAX};

    reg [1:0] row;
    reg [1:0] row_next;
    reg [1:0] col;
    reg [1:0] col_next;
    reg [PARTIAL_WIDTH-1:0] accum;
    reg [PARTIAL_WIDTH-1:0] accum_next;
    reg [4*OUT_WIDTH-1:0] y;
    reg [4*OUT_WIDTH-1:0] y_next;
    reg busy;
    reg busy_next;
    reg done_next;

    //unpack matrix from bus
    wire [3:0] matrix [0:3][0:3];
    assign matrix[0][0] = A[3:0];
    assign matrix[0][1] = A[7:4];
    assign matrix[0][2] = A[11:8];
    assign matrix[0][3] = A[15:12];
    assign matrix[1][0] = A[19:16];
    assign matrix[1][1] = A[23:20];
    assign matrix[1][2] = A[27:24];
    assign matrix[1][3] = A[31:28];
    assign matrix[2][0] = A[35:32];
    assign matrix[2][1] = A[39:36];
    assign matrix[2][2] = A[43:40];
    assign matrix[2][3] = A[47:44];
    assign matrix[3][0] = A[51:48];
    assign matrix[3][1] = A[55:52];
    assign matrix[3][2] = A[59:56];
    assign matrix[3][3] = A[63:60];

    //unpack vector
    wire [3:0] vec [0:3];
    assign vec[0] = V[3:0];
    assign vec[1] = V[7:4];
    assign vec[2] = V[11:8];
    assign vec[3] = V[15:12];

    wire [7:0] prod = matrix[row][col] *vec[col];
    wire last_col = ((col == 2'd3 ));
    wire last_row = (row ==2'd3 );
    wire [PARTIAL_WIDTH-1:0] sum = accum +prod;
    wire [OUT_WIDTH-1:0] result = (sum > OUT_MAX_EXT) ? OUT_MAX : sum[OUT_WIDTH-1:0];

    always @(*) 
        begin
        row_next = row;
        col_next = col;
        accum_next = accum;
        y_next = y;
        busy_next = busy;
        done_next = 1'b0;

        //initialize when starting
        if (start && !busy) 
            begin
            row_next = 2'd0;
            col_next = 2'd0;
            accum_next = {PARTIAL_WIDTH{1'b0}};
            y_next = {4*OUT_WIDTH{1'b0}};
            busy_next = 1'b1;
            end 
        else if (busy) 
            begin
            //save result when done with row
            if (last_col) 
                begin

                y_next[row*OUT_WIDTH +: OUT_WIDTH] = result;
                accum_next = {PARTIAL_WIDTH{1'b0}};
                col_next = 2'd0;
                if (last_row) 
                    begin
                    busy_next = 1'b0;
                    done_next = 1'b1;
                    row_next = 2'd0;
                    end 
                else 
                    begin
                    row_next = row + 1'b1;
                    end
                end 
                else 
                    begin
                accum_next =sum;
                col_next = col +1'b1;
                end
            end
        end

    always @(posedge clk) 
        begin
        if (reset) 
            begin
            row <= 2'd0;
            col <= 2'd0;
            accum <= {PARTIAL_WIDTH{1'b0}};
            y <= {4*OUT_WIDTH{1'b0}};
            busy <= 1'b0;
            Y <= {4*OUT_WIDTH{1'b0}};
            done <= 1'b0;
            end 
        else 
            begin
            row <= row_next;
            col <= col_next;
            accum <= accum_next;
            y <= y_next;
            busy <= busy_next;
            Y <= y_next;
            done <= done_next;
            end
        end

endmodule
