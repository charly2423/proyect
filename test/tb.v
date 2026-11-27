`default_nettype none
`timescale 1ns / 1ps
module tb;
    reg clk, rst_n, ena;
    reg [7:0] ui_in, uio_in;
    wire [7:0] uo_out, uio_out, uio_oe;
`ifdef GL_TEST
    wire VPWR = 1'b1;
    wire VGND = 1'b0;
`endif
    initial begin
        $dumpfile("tb.fst");
        $dumpvars(0, tb);
    end
    // Cocotb genera reloj, reset y estimulos.
    tt_um_charly2423_proyect user_project (
`ifdef GL_TEST
        .VPWR(VPWR), .VGND(VGND),
`endif
        .clk(clk), .rst_n(rst_n), .ena(ena),
        .ui_in(ui_in), .uo_out(uo_out),
        .uio_in(uio_in), .uio_out(uio_out), .uio_oe(uio_oe)
    );
endmodule
`default_nettype wire
