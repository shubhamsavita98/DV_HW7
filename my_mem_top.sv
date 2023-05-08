/*TOP MODULE*/
`timescale 1ns/1ps
module my_mem_top;

    bit clk;

    always #5 clk = ~ clk;

    my_mem_interface top_inf(clk); // interface

	my_mem dut(top_inf); //test program

	my_mem_pgm pgm_mem(top_inf); //design under test


endmodule