/*!
   Common communication interface of default firmwares
   Copyright (C) 2009-2016 ZTEX GmbH.
   http://www.ztex.de

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License version 3 as
   published by the Free Software Foundation.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, see http://www.gnu.org/licenses/.
!*/
/* 
   Implements the 4 bi-directional GPIO's of the default interface.

   Outputs on both ends are or-ed.

   Remember (because it's not implemented here) default interface always
   contains a reset signal.
*/  


// all directions are seen from FPGA
module ezusb_gpio (
	// control signals
	input clk,			// system clock, minimum frequency is 24 MHz
	// hardware pins
	input gpio_clk,			// data clock; data sent on both edges
	input gpio_dir,			// 1: output, 0->1 transition latches input data and starts writing
	inout gpio_dat,
	// interface
	output reg [3:0] in,	
	input [3:0] out			// wired or: GPIO's not used for output should be 0
    );

    reg [2:0] gpio_clk_buf, gpio_dir_buf;
    reg [3:0] in_buf, out_reg, in_reg;
    reg [7:0] in_tmp;
    reg do_out;

    wire clk_edge = ( (gpio_clk_buf[0]!=gpio_clk_buf[1]) && (gpio_clk_buf[1]==gpio_clk_buf[2]) );
    wire dir_edge = ( (gpio_dir_buf[0]!=gpio_dir_buf[1]) && (gpio_dir_buf[1]==gpio_dir_buf[2]) );

    assign gpio_dat = gpio_dir ? out_reg[3] : 1'bz;

    always @ (posedge clk)
    begin
	gpio_clk_buf <= { gpio_clk_buf[1:0], gpio_clk };
	gpio_dir_buf <= { gpio_dir_buf[1:0], gpio_dir };
	
	do_out <= (do_out && gpio_dir_buf[0] && !clk_edge ) || (dir_edge && gpio_dir_buf[0]);
	
	if ( dir_edge && gpio_dir_buf[0] ) in_buf <= in_reg;
	if ( do_out ) out_reg <= out | in_reg;
	
	if ( clk_edge ) 
	begin
	    if ( gpio_dir_buf[0] ) out_reg <= {out_reg[2:0], 1'b0};
	    else in_reg <= { gpio_dat, in_reg[3:1] };
	end;
	
	in <= in_buf | out;
    end
endmodule
