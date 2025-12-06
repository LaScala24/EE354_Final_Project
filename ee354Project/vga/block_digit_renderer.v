`timescale 1ns / 1ps
//like seen in demo
module block_digit_renderer 
(
    input  wire [3:0] digit,
    input  wire [9:0] px,
    input  wire [9:0] py,
    input  wire [9:0] base_x,
    input  wire [9:0] base_y,
    output wire pixel_on
);

    parameter W = 50;
    parameter H = 70;
    parameter THICK = 8;

    wire [9:0] x_vga = px -base_x;
    wire [9:0] y_vga = py -base_y;

    wire in_bounds = (x_vga >= 0) && (x_vga < W) && (y_vga >= 0) && (y_vga < H);

    wire seg_a = in_bounds && (y_vga >= 0) && (y_vga < THICK) && (x_vga >= THICK) && (x_vga < (W - THICK));
    wire seg_b = in_bounds && (x_vga >= (W - THICK)) && (x_vga < W) && (y_vga >= THICK) && (y_vga < (H/2 - THICK/2));
    wire seg_c = in_bounds && (x_vga >= (W - THICK)) && (x_vga < W) && (y_vga >= (H/2 + THICK/2)) && (y_vga < (H - THICK));
    wire seg_d = in_bounds && (y_vga >= (H - THICK)) && (y_vga < H) && (x_vga >= THICK) && (x_vga < (W - THICK));
    wire seg_e = in_bounds && (x_vga >= 0) && (x_vga < THICK) && (y_vga >= (H/2 + THICK/2)) && (y_vga < (H - THICK));
    wire seg_f = in_bounds && (x_vga >= 0) && (x_vga < THICK) && (y_vga >= THICK) && (y_vga < (H/2 - THICK/2));

    wire seg_g = in_bounds && (y_vga >= (H/2 - THICK/2)) && (y_vga < (H/2 + THICK/2)) && (x_vga >= THICK) && (x_vga < (W - THICK));

    wire [6:0] segs;
    assign segs[6] = (digit == 4'd0) || (digit == 4'd2) || (digit == 4'd3) || (digit == 4'd5) || (digit == 4'd6) || (digit == 4'd7) || (digit == 4'd8) || (digit == 4'd9);
    assign segs[5] = (digit == 4'd0) || (digit == 4'd1) || (digit == 4'd2) || (digit == 4'd3) || (digit == 4'd4) || (digit == 4'd7) || (digit == 4'd8) || (digit == 4'd9);
    assign segs[4] = (digit == 4'd0) || (digit == 4'd1) || (digit == 4'd3) || (digit == 4'd4) || (digit == 4'd5) || (digit == 4'd6) || (digit == 4'd7) || (digit == 4'd8) || (digit == 4'd9);
    assign segs[3] = (digit == 4'd0) || (digit == 4'd2) || (digit == 4'd3) || (digit == 4'd5) || (digit == 4'd6) || (digit == 4'd8) || (digit == 4'd9);
    assign segs[2] = (digit == 4'd0) || (digit == 4'd2) || (digit == 4'd6) || (digit == 4'd8);
    assign segs[1] = (digit == 4'd0) || (digit == 4'd4) || (digit == 4'd5) || (digit == 4'd6) || (digit == 4'd8) || (digit == 4'd9);
    assign segs[0] = (digit == 4'd2) || (digit == 4'd3) || (digit == 4'd4) || (digit == 4'd5) || (digit == 4'd6) || (digit == 4'd8) || (digit == 4'd9);

    assign pixel_on = (segs[6] && seg_a) || (segs[5] && seg_b) || (segs[4] && seg_c) || (segs[3] && seg_d) || (segs[2] && seg_e) || (segs[1] && seg_f) || (segs[0] &&seg_g );

endmodule

