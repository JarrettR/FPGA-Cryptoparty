/*!
   flashbench -- Flash memory benchmark
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

import java.io.*;
import java.util.*;
import java.nio.*;

import org.usb4java.*;

import ztex.*;

// *****************************************************************************
// ******* ParameterException **************************************************
// *****************************************************************************
// Exception the prints a help message
class ParameterException extends Exception {
    public final static String helpMsg = new String (
		"Parameters:\n"+
		"    -d <number>   Device Number (default: 0)\n" +
		"    -s <number>   Number of sectors to be tested (64 KByte sector default: 16; 512 Bytes sector default: 8192)\n" +
		"    -w		   Perform write tests (may destroy data)\n" +    
		"    -1 	   Test primary flash (default if no secondary Flash available\n" + 
		"    -2		   Test secondary Flash  (default if available)\n" + 
		"    -p            Print bus info\n" +
		"    -h            This help" );
    
    public ParameterException (String msg) {
	super( msg + "\n" + helpMsg );
    }
}

// *****************************************************************************
// ******* Test0 ***************************************************************
// *****************************************************************************
class FlashBench extends Ztex1v1 {

// ******* FlashBench **********************************************************
// constructor
    public FlashBench ( ZtexDevice1 pDev ) throws UsbException {
	super ( pDev );
    }

// ******* testRW **************************************************************
// measures read + write performance
    public int testRW (boolean secondary, int num ) throws UsbException, InvalidFirmwareException, CapabilityException {
	int flashSectorSize = secondary ? flash2SectorSize() : flashSectorSize();
	int secNum = Math.max(1, 2048 / flashSectorSize);
	byte[] buf1 = new byte[flashSectorSize * secNum];
	byte[] buf2 = new byte[flashSectorSize * secNum];

	long t0 = new Date().getTime();

	for ( int i=0; i<num; i+=secNum ) {
	    int l = Math.min(num-i,secNum);
	    for (int k=0; k<flashSectorSize*l; k++) {
		buf1[k] = (byte) (int) Math.floor(256.0*Math.random());
	    }

	    System.out.print("Sector " + (i+l) + "/" + num+ "  " + Math.round(10000.0*(i+1)/num)/100.0 + "%    \r");
	    if ( secondary ) {
		flash2WriteSector(i,l,buf1);
		flash2ReadSector(i,l,buf2);
	    } else {
		flashWriteSector(i,l,buf1);
		flashReadSector(i,l,buf2);
	    }
	    int diffs=flashSectorSize*l;
	    for (int k=0; k<flashSectorSize*l; k++) 
		if ( buf1[k] == buf2[k] )
		    diffs -= 1;
	    if ( diffs!=0 ) {
		System.out.println("Error occured at sector " + i +": " + diffs + " differences");
	    } 
	}

	return (int) Math.round(num*flashSectorSize*1.0/(new Date().getTime() - t0));
    }

// ******* testW **************************************************************
// measures write performance
    public int testW (boolean secondary,  int num, byte[] backup ) throws UsbException, InvalidFirmwareException, CapabilityException {
	int flashSectorSize = secondary ? flash2SectorSize() : flashSectorSize();
	int secNum = Math.max(1, 2048 / flashSectorSize );
	byte[] buf = new byte[flashSectorSize * secNum];
	long t0 = new Date().getTime();
	for ( int i=0; i<num; i+=secNum ) {
	    int j = Math.min(num-i,secNum);
	    System.out.print("Sector " + (i+j) + "/" + num+ "  " + Math.round(10000.0*(i+1)/num)/100.0 + "%    \r");
	    System.arraycopy(backup,flashSectorSize*i, buf,0, flashSectorSize*j);
	    if ( secondary ) flash2WriteSector(i,j,buf);
	    else flashWriteSector(i,j,buf);
	}
	return (int) Math.round(num*flashSectorSize*1.0/(new Date().getTime() - t0));
    }

// ******* testR **************************************************************
// measures read performance
    public int testR (boolean secondary,  int num, boolean verify, byte[] backup ) throws UsbException, InvalidFirmwareException, CapabilityException {
	int flashSectorSize = secondary ? flash2SectorSize() : flashSectorSize();
	int secNum = Math.max(1, 2048 / flashSectorSize );
	byte[] buf = new byte[flashSectorSize * secNum];
	int errors = 0;
	long t0 = new Date().getTime();
	for ( int i=0; i<num; i+=secNum ) {
	    int j = Math.min(num-i,secNum);
	    System.out.print("Sector " + (i+j) + "/" + num+ "  " + Math.round(10000.0*(i+1)/num)/100.0 + "%    \r");
	    if ( secondary ) flash2ReadSector(i,j,buf);
	    else flashReadSector(i,j,buf);
	    if ( backup != null ) {
		if ( verify ) {
		    int diffs = flashSectorSize*j;
		    int l = flashSectorSize * i;
		    for (int k=0; k<flashSectorSize*j; k++) 
			if ( buf[k] == backup[flashSectorSize*i+k] ) diffs-=1;
		    if ( diffs!=0 ) System.out.println("Error occured at sector " + i +": " + diffs + " differences");
		}
		else {
		    System.arraycopy(buf,0, backup,flashSectorSize*i, flashSectorSize*j);
		}
	    }
	}
	return (int) Math.round(num*flashSectorSize*1.0/(new Date().getTime() - t0));
    }

// ******* main ****************************************************************
    public static void main (String args[]) {
    
	int devNum = 0;
	int sectors = 0;
	boolean flash1 = false, have1 = false;
	boolean flash2 = false, have2 = false;
	boolean writeTests = false;
	
	try {
// Scan the USB. This also creates and initializes a new USB context.
	    ZtexScanBus1 bus = new ZtexScanBus1( ZtexDevice1.ztexVendorId, ZtexDevice1.ztexProductId, true, false, 1);
	    if ( bus.numberOfDevices() <= 0) {
		System.err.println("No devices found");
	        System.exit(0);
	    }
	    
// scan the command line arguments
    	    for (int i=0; i<args.length; i++ ) {
	        if ( args[i].equals("-d") ) {
	    	    i++;
		    try {
			if (i>=args.length) throw new Exception();
    			devNum = Integer.parseInt( args[i] );
		    } 
		    catch (Exception e) {
		        throw new ParameterException("Device number expected after -d");
		    }
		}
	        if ( args[i].equals("-s") ) {
	    	    i++;
		    try {
			if (i>=args.length) throw new Exception();
    			sectors = Integer.parseInt( args[i] );
		    } 
		    catch (Exception e) {
		        throw new ParameterException("Number of sectors expected after -s");
		    }
		}
		else if ( args[i].equals("-1") ) {
		    flash1 = true;
		}
		else if ( args[i].equals("-2") ) {
		    flash2 = true;
		}
		else if ( args[i].equals("-w") ) {
		    writeTests = true;
		}
		else if ( args[i].equals("-p") ) {
	    	    bus.printBus(System.out);
		    System.exit(0);
		}
		else if ( args[i].equals("-h") ) {
		        System.err.println(ParameterException.helpMsg);
	    	        System.exit(0);
		}
		else throw new ParameterException("Invalid Parameter: "+args[i]);
	    }
	    

// create the main class	    
	    FlashBench ztex = new FlashBench ( bus.device(devNum) );
	    bus.unref();
	    
// print some information
	    System.out.println("Capabilities: " + ztex.capabilityInfo(", "));
	    
	    if ( ztex.InterfaceCapabilities(CAPABILITY_FLASH) ) {
		System.out.println("Primary Flash enabled: " + ztex.flashEnabled());
		System.out.println("Primary Flash sector size: " + ztex.toHumanStr(ztex.flashSectorSize())+" Bytes");
		System.out.println("Primary Flash size: " + ztex.toHumanStr(ztex.flashSize())+" Bytes");
	    }

	    if ( ztex.InterfaceCapabilities(CAPABILITY_FLASH2) ) {
		System.out.println("Secondary Flash enabled: " + ztex.flash2Enabled());
		System.out.println("Secondary Flash sector size: " + ztex.toHumanStr(ztex.flash2SectorSize())+" Bytes");
		System.out.println("Secondary Flash size: " + ztex.toHumanStr(ztex.flash2Size())+" Bytes");
		if ( !flash1 ) flash2 = true;
	    }
	    else if ( !flash2 ) flash1 = true;
	    
// primary flash test
	    if ( flash1 && ztex.InterfaceCapabilities(CAPABILITY_FLASH) && ztex.flashEnabled() ) {
		System.out.println("Testing Primary Flash ...");
		int s = sectors > 1 ? sectors : ztex.flashSectorSize() > 1024 ? 16 : 8192;
		if (s > ztex.flashSectors() ) s = ztex.flashSectors(); 
		byte[] backup = writeTests ? new byte[s*ztex.flashSectorSize()] : null;
		System.out.println("Read Performance: " + ztex.testR(false, s, false, backup) + " kb/s     ");
		if ( writeTests ) {
		    System.out.println("Read + Write Performance: " + ztex.testRW(false, s) + " kb/s      ");
		    System.out.println("Write Performance: " + ztex.testW(false, s, backup) + " kb/s      ");
		    System.out.println("Read Performance: " + ztex.testR(false, s, true, backup) + " kb/s     ");
		}
	    }

// secondary flash test
	    if ( flash2 && ztex.InterfaceCapabilities(CAPABILITY_FLASH2) && ztex.flash2Enabled() ) {
		System.out.println("Testing Secondary Flash ...");
		int s = sectors > 1 ? sectors : ztex.flash2SectorSize() > 1024 ? 16 : 8192;
		if (s > ztex.flash2Sectors() ) s = ztex.flash2Sectors(); 
		byte[] backup = writeTests ? new byte[s*ztex.flash2SectorSize()] : null;
		System.out.println("Read Performance: " + ztex.testR(true, s, false, backup) + " kb/s     ");
		if ( writeTests ) {
		    System.out.println("Read + Write Performance: " + ztex.testRW(true, s) + " kb/s      ");
		    System.out.println("Write Performance: " + ztex.testW(true, s, backup) + " kb/s      ");
		    System.out.println("Read Performance: " + ztex.testR(true, s, true, backup) + " kb/s     ");
		}
	    }

// release resources
	    ztex.dispose();
    
	}
	catch (Exception e) {
	    System.out.println("Error: "+e.getLocalizedMessage() );
	} 
   } 
   
}
