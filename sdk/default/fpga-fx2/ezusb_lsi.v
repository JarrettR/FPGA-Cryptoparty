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
   Implements the low speed interferace of default firmwares.
   
   It allows easy-to-use low speed communication with a SRAM-like 
   interface (32 bit width, 8 bit address). For example it can be used
   to transfer things like settings and debug data.
*/  

module ezusb_lsi (
	// control signals
	input clk,			// system clock, minimum frequency is 24 MHz
	input reset_in,			// high-active asynchronous reset
	output reg reset = 1'b1,	// synchronous reset output
	// hardware pins
	input data_clk,			// data sent on both edges, LSB transmitted first
	input mosi,
	output miso,
	input stop,
	// interface
	output reg [7:0] in_addr,	// input address
	output reg [31:0] in_data,	// input data
	output reg in_strobe = 1'b0,	// 1 indicates new data received (1 for one clock)
	output reg in_valid = 1'b0,	// 1 if date is valid
	output reg [7:0] out_addr,      // output address
	input [31:0] out_data,          // output data
	output reg out_strobe = 1'b0	// 1 indicates new data request (1 for one clock)
    );
    
    reg [39:0] read_reg;
    reg [31:0] write_reg;
    reg [2:0] data_clk_buf;
    reg dir = 0;	// 0 : read
    reg do_write = 0;
    
    assign miso = write_reg[0];
    
//    wire data_clk_edge = ( (data_clk==data_clk_buf[0]) && (data_clk==data_clk_buf[1]) && (data_clk!=data_clk_buf[2]) );
    wire data_clk_edge = ( (data_clk_buf[0]!=data_clk_buf[1]) && (data_clk_buf[1]==data_clk_buf[2]) );

    
    always @ (posedge clk)
    begin
	reset <= reset_in;
	data_clk_buf <= { data_clk_buf[1:0], data_clk };
	in_strobe <= (!reset) && data_clk_edge && (!dir) && stop && (!mosi);
	out_strobe <= (!reset) && data_clk_edge && (!dir) && stop && mosi;
	dir <= (!reset) && stop && ((data_clk_edge && mosi) || dir);
	if ( reset ) 
	begin 
	    in_valid <= 1'b0;
	    do_write <= 1'b0;
	end else if ( data_clk_edge )
	begin
	    if ( !dir )  // read from fx3
	    begin
	        if ( stop )
	        begin
	    	    if ( mosi ) // last 8 bit contain write address
		    begin
//		        dir <= 1'b1;
		        out_addr <= read_reg[39:32];
		        do_write <= 1'b1;
		    end else 
		    begin
		        in_valid <= 1'b1;
		        in_addr <= read_reg[39:32];
		        in_data <= read_reg[31:0];
		    end
		end else
		begin
		    read_reg <= { mosi, read_reg[39:1] };
		end
	    end else  // write to fx3
	    begin
	        write_reg[30:0] <= write_reg[31:1];
	        do_write <= 1'b0;
//	        dir <= stop;
	    end
	end else if ( dir && do_write )
	begin
	    write_reg <= out_data;
	end
    end
endmodule
