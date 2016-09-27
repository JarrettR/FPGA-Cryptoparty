/*!
   memfifo -- implementation of EZ-USB slave FIFO's (input and output) a FIFO using BRAM
   Copyright (C) 2009-2014 ZTEX GmbH.
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
   Implements a FWFT FIFO from all BRAM.
*/  


module bram_fifo # (
      	parameter BRAM_N = 32		// Number of BRAM blocks; 32 available on LX16
    ) (
	input reset,			// reset
	// FIFO protocol equal to FWFT FIFO in "7 Series Memory Resources" user guide (ug743)
	// input fifo interface
        input [31:0] DI,                // must be hold while FULL is asserted
        output FULL,                    // 1-bit output: Full flag
        output reg WRERR,               // 1-bit output: Write error
        input WRCLK,                    // 1-bit input: Rising edge write clock.
        input WREN,                     // 1-bit input: Write enable

	// output fifo interface
	output reg [31:0] DO,
	output reg EMPTY,               // 1-bit output: Empty flag, can be used as data valid indicator
        output reg RDERR,               // 1-bit output: Read error
        input RDCLK,                    // 1-bit input: Read clock
        input RDEN                      // 1-bit input: Read enable
    );
        
    localparam ADDR_WIDTH = 15;		
    localparam ADDR_MAX = 512*BRAM_N-1;
    
    reg [31:0] BRAM[0:ADDR_MAX];
    
    // DRAM controller: writing
    reg reset_wr, WREN_BUF;
    reg [7:0] reset_wr_buf = 8'd0;
    reg [ADDR_WIDTH-1:0] WR_ADDR, WR_ADDR_NEXT, RD_ADDR_WR1, RD_ADDR_WR2, RD_ADDR_WR3;

    // DRAM controller: reading
    reg reset_rd;
    reg [7:0] reset_rd_buf = 8'd0;
    reg [ADDR_WIDTH-1:0] RD_ADDR, RD_ADDR_NEXT, WR_ADDR_RD1, WR_ADDR_RD2, WR_ADDR_RD3;

    assign FULL = reset_wr || FULL2;
    wire FULL2 = (WR_ADDR_NEXT==RD_ADDR_WR3) || (WR_ADDR_NEXT==RD_ADDR_WR2) || (WR_ADDR_NEXT==RD_ADDR_WR1);
    
    always @ (posedge WRCLK)
    begin
        RD_ADDR_WR1 <= RD_ADDR;
        RD_ADDR_WR2 <= RD_ADDR_WR1;
        RD_ADDR_WR3 <= RD_ADDR_WR2;
	
	reset_wr_buf <= { reset, reset_wr_buf[7:1] };
	reset_wr <= reset_wr_buf != 8'd0;
	
	if ( reset_wr )
	begin
	    WR_ADDR <= ADDR_MAX;
	    WR_ADDR_NEXT <= { (ADDR_WIDTH){1'b0} };
	    WREN_BUF <= 1'b0;
	end else
	begin
	    if ( WREN || WREN_BUF ) 		// process data
	    begin
		if ( ! FULL2 ) 
		begin
		    BRAM[WR_ADDR] <= DI;
		    WR_ADDR <= WR_ADDR_NEXT;
		    WR_ADDR_NEXT <= WR_ADDR_NEXT == ADDR_MAX ? { ADDR_WIDTH{1'b0} } : WR_ADDR_NEXT + 1;
		end
		WREN_BUF <= FULL2;
	    end
	    WRERR <= WREN && WREN_BUF;
	end
    end


    always @ (posedge RDCLK)
    begin
        WR_ADDR_RD1 <= WR_ADDR;
        WR_ADDR_RD2 <= WR_ADDR_RD1;
        WR_ADDR_RD3 <= WR_ADDR_RD2;
    
	reset_rd_buf <= { reset, reset_rd_buf[7:1] };
	reset_rd <= reset_rd_buf != 8'd0;
	
	if ( reset_rd )
	begin
	    RD_ADDR <= ADDR_MAX;
	    RD_ADDR_NEXT <= { (ADDR_WIDTH){1'b0} };
	    EMPTY <= 1'b1;
	end else
	begin
	    RDERR <= RDEN && EMPTY;
	    
	    if ( RDEN || EMPTY )
	    begin
		if ( (RD_ADDR_NEXT!=WR_ADDR_RD3) && (RD_ADDR_NEXT!=WR_ADDR_RD2) && (RD_ADDR_NEXT!=WR_ADDR_RD1) && (RD_ADDR!=WR_ADDR_RD3) && (RD_ADDR!=WR_ADDR_RD2) && (RD_ADDR!=WR_ADDR_RD1) ) 
		begin
		    EMPTY <= 1'b0;
    		    DO <= BRAM[RD_ADDR];
//		    DO <= { BRAM[RD_ADDR][23:0], RD_ADDR[7:0] };
		    RD_ADDR <= RD_ADDR_NEXT;
		    RD_ADDR_NEXT <= RD_ADDR_NEXT == ADDR_MAX ? { ADDR_WIDTH{1'b0} } : RD_ADDR_NEXT + 1;
		end else
		begin
		    EMPTY <= 1'b1;
		end
	    end
	end
    end

endmodule
 