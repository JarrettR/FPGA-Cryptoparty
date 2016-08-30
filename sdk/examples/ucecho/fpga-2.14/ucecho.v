/*!
   ucecho -- Uppercase conversion example using the low speed interface of default firmware
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

`define UC(x) ( (((x) >= 8'd97) && ((x)<=8'd122)) ? (x)-8'd32 : (x) )

module ucecho (
        // control signals
	input fxclk_in,
	input reset_in,
        // hardware pins
	input lsi_clk,
        inout lsi_data,
	input lsi_stop
    );

    wire [7:0] in_addr, out_addr;
    wire [7:0] in_data0, in_data1, in_data2, in_data3;
    wire in_strobe, out_strobe, fxclk;
    reg [31:0] out_data;
    
    reg [31:0] mem[255:0];

    BUFG fxclk_buf (
	.I(fxclk_in),
	.O(fxclk) 
    );
    
    ezusb_lsi lsi_inst (
	.clk(fxclk),
	.reset_in(reset_in),
	.reset(),
	.data_clk(lsi_clk),
	.data(lsi_data),
	.stop(lsi_stop),
	.in_addr(in_addr),
	.in_data({in_data3, in_data2, in_data1, in_data0}),
	.in_strobe(in_strobe),
	.in_valid(),
	.out_addr(out_addr),
	.out_data(out_data),
	.out_strobe(out_strobe)
    );

    always @ (posedge fxclk)
    begin
	if ( in_strobe ) mem[in_addr] <= { `UC(in_data3), `UC(in_data2), `UC(in_data1), `UC(in_data0) };
	if ( out_strobe ) out_data <= mem[out_addr];
    end

endmodule

