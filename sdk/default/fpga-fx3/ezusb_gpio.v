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

   On FX3 outputs on both ends are or-wired.

   Remember (because it's not implemented here) default interface always
   contains a reset signal.
*/  


module ezusb_gpio (
	// control signals
	input clk,			// system clock
	// hardware pins
	inout [3:0] gpio_n,		// wired or: low-active open-drain output
	// interface
	output reg [3:0] in,	
	input [3:0] out			// wired or: GPIO's not used for output should be 0
    );

    assign gpio_n[0] = !out[0] ? 1'bz : 1'b0;
    assign gpio_n[1] = !out[1] ? 1'bz : 1'b0;
    assign gpio_n[2] = !out[2] ? 1'bz : 1'b0;
    assign gpio_n[3] = !out[3] ? 1'bz : 1'b0;

    always @ (posedge clk)
    begin
	in <= ~gpio_n;
    end
endmodule
