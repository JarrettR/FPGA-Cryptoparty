/*!
   ucecho -- uppercase conversion example for ZTEX USB-FPGA Module 1.15b and 1.15y2
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

#include[ztex-conf.h]	// Loads the configuration macros, see ztex-conf.h for the available macros
#include[ztex-utils.h]	// include basic functions

// configure endpoints 2 and 4, both belong to interface 0 (in/out are from the point of view of the host)
EP_CONFIG(2,0,BULK,IN,512,2);	 
EP_CONFIG(4,0,BULK,OUT,512,2);	 

// select ZTEX USB FPGA Module 1.15 as target  (required for FPGA configuration)
IDENTITY_UFM_1_15Y(10.15.0.0,0);	 

// this product string is also used for identification by the host software
#define[PRODUCT_STRING]["WPA2 for UFM 1.15y"]

// enables high speed FPGA configuration via EP4
ENABLE_HS_FPGA_CONF(4);

__xdata BYTE run;

#define[PRE_FPGA_RESET][PRE_FPGA_RESET
    run = 0;
]
// this is called automatically after FPGA configuration
#define[POST_FPGA_CONFIG][POST_FPGA_CONFIG
    IFCONFIG = bmBIT7;	        // internel 30MHz clock, drive IFCLK ouput, slave FIFO interface
    SYNCDELAY; 
    EP2FIFOCFG = 0;
    SYNCDELAY;
    EP4FIFOCFG = 0;
    SYNCDELAY;

    REVCTL = 0x0;	// reset 
    SYNCDELAY; 
    EP2CS &= ~bmBIT0;	// stall = 0
    SYNCDELAY; 
    EP4CS &= ~bmBIT0;	// stall = 0

    SYNCDELAY;		// first two packages are waste
    EP4BCL = 0x80;	// skip package, (re)arm EP4
    SYNCDELAY;
    EP4BCL = 0x80;	// skip package, (re)arm EP4

    FIFORESET = 0x80;	// reset FIFO
    SYNCDELAY;
    FIFORESET = 0x82;
    SYNCDELAY;
    FIFORESET = 0x00;
    SYNCDELAY;

    OEC = 255;
	IOA0 = 0; IOA1 = 0; IOA7 = 0;
	OEA = bmBIT0 | bmBIT1 | bmBIT7;
    run = 1;
]
/*
// set mode
ADD_EP0_VENDOR_COMMAND((0x60,,
	IOA7 = 1;				// reset on
	IOA0 = SETUPDAT[2] ? 1 : 0;
	IOA7 = 0;				// reset off
,,
	NOP;
));;*/


void wpa2_reset() {
	IOA0 = 0; IOA1 = 0; IOA7 = 0;
	OEA = bmBIT0 | bmBIT7;
	IOA7 = 1;				// reset on
    SYNCDELAY;
	IOA7 = 0;				// reset off
}

// include the main part of the firmware kit, define the descriptors, ...
#include[ztex.h]

void main(void)	
{
    WORD i,size;
    
    // init everything
    init_USB();

    wpa2_reset();
    
    while (1) {	
        if (run) {
            if (!(EP4CS & bmBIT2) ) {	// EP4 is not empty
                size = (EP4BCH << 8) | EP4BCL;
                if (size > 0 && size <= 512) {	// EP2 is not full
                    for ( i= 0; i < size; i++ ) {
                        IOA1 = 0;
                        IOC = EP4FIFOBUF[i];	// IOC out
                        IOA0 = 1;
                        IOA0 = 0;
                    }
                }
            }
            for (size = 0; IOA2 == 0; size++) {	// Empty flag not set
                IOA1 = 1;
                SYNCDELAY; 
                IOA0 = 1;
                IOA0 = 0;
                EP2FIFOBUF[size] = IOB;	// IOB in
            } 
            EP2BCH = size >> 8;
            SYNCDELAY; 
            EP2BCL = size & 255;		// arm EP2
        
            SYNCDELAY; 
            EP4BCL = 0x80;			// (re)arm EP4
        }
    }
}
