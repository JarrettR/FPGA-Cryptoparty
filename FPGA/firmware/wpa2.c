/*!
   WPA2 -- Firmware for ZTEX USB-FPGA Module 1.15y and 1.15y2
   Copyright (C) 2009-2014 ZTEX GmbH.
   Copyright (C) 2016 Jarrett Rainier
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

#include[ztex-conf.h]   // Loads the configuration macros, see ztex-conf.h for the available macros
#include[ztex-utils.h]  // include basic functions

// configure endpoint 2, in, quad buffered, 512 bytes, interface 0
EP_CONFIG(2,0,BULK,IN,512,4);

// configure endpoint 6, out, quad buffered, 512 bytes, interface 0
EP_CONFIG(6,0,BULK,OUT,512,4);

// select ZTEX USB FPGA Module 1.15 as target  (required for FPGA configuration)
IDENTITY_UFM_1_15Y(10.15.0.0,0);

// this product string is also used for identification by the host software
#define[PRODUCT_STRING]["WPA2 UFM 1.15y 0.1"]

// enables high speed FPGA configuration via EP6
ENABLE_HS_FPGA_CONF(6);

// this is called automatically after FPGA configuration
#define[POST_FPGA_CONFIG][POST_FPGA_CONFIG
	IOA0 = 1;				// controlled mode
	IOA7 = 1;				// reset on
	OEA = bmBIT0 | bmBIT7;

	EP2CS &= ~bmBIT0;			// clear stall bit
    
	REVCTL = 0x1;
	SYNCDELAY; 

	IFCONFIG = bmBIT7 | bmBIT5 | 3; 	// internal IFCLK, 30 MHz, OE, slave FIFO interface
	SYNCDELAY; 
	EP2FIFOCFG = bmBIT3 | bmBIT0;           // AOTUOIN, WORDWIDE
	SYNCDELAY;
    
	EP2AUTOINLENH = 2;                 	// 512 bytes 
	SYNCDELAY;
	EP2AUTOINLENL = 0;
	SYNCDELAY;

	FIFORESET = 0x80;			// reset FIFO
	SYNCDELAY;
	FIFORESET = 2;
	SYNCDELAY;
	FIFORESET = 0x00;
	SYNCDELAY;

	FIFOPINPOLAR = 0;
	SYNCDELAY; 
	PINFLAGSAB = 0;
	SYNCDELAY; 
	PINFLAGSCD = 0;
	SYNCDELAY; 

	IOA7 = 0;				// reset off
]

// set mode
ADD_EP0_VENDOR_COMMAND((0x60,,
	IOA7 = 1;				// reset on
	IOA0 = SETUPDAT[2] ? 1 : 0;
	IOA7 = 0;				// reset off
,,
	NOP;
));;

// include the main part of the firmware kit, define the descriptors, ...
#include[ztex.h]

void main(void)	
{
    init_USB();

    while (1) {	
    }
}

