/*!
   Utility for automatic updating default firmware
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
                "Update default firmware in non-volatile memory.\n\n"+
		"Parameters:\n"+
		"    -d <number>  Device Number (default: 0)\n" +
		"    -p           Print bus info\n" +
		"    -i           Print firmware information only\n"+ 
		"    -u           Update only\n" + 
		"    -f           Overwrite firmware in any case\n" + 
		"    -h           This help\n\n" +
		"If neither -u nor -f is given and a non-default firmware if found overwriting must be confirmed by user.");

    public ParameterException (String msg) {
	super( msg + "\n" + helpMsg );
    }
}

// *****************************************************************************
// ******* DefaultUpdater ******************************************************
// *****************************************************************************
class DefaultUpdater {

// ******* main ****************************************************************
    public static void main (String args[]) {
    
	int devNum = 0;
	boolean force = false;
	boolean info = false;
	boolean updateonly = false;
	boolean ask = false;
	
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
		else if ( args[i].equals("-p") ) {
	    	    bus.printBus(System.out);
		    System.exit(0);
		}
		else if ( args[i].equals("-i") ) {
	    	    info = true;
		}
		else if ( args[i].equals("-u") ) {
	    	    updateonly = true;
		}
		else if ( args[i].equals("-f") ) {
	    	    force = true;
		}
		else if ( args[i].equals("-h") ) {
		    System.err.println(ParameterException.helpMsg);
	    	    System.exit(0);
		}
		else if ( !args[i].equals("-re") && !args[i].equals("-ue") )
		    throw new ParameterException("Invalid Parameter: "+args[i]);
	    }
	    if ( updateonly && force ) throw new ParameterException("Parameters -u and -f must not be specified at the same time");

// create the main class	    
	    Ztex1v1 ztex = new Ztex1v1 ( bus.device(devNum) );
	    bus.unref();
	    ConfigData config = ztex.config;
	    ztex.defaultDisableWarnings = true;

// evaluate current firmware(s)
	    System.out.println("Reset EZ-USB in order to load and evaluate firmware installed in non-volatile memory");
	    ztex.resetEzUsb();

	    if ( ztex.config != null ) config = ztex.config;
	    if ( config == null ) throw new Exception("No configuration data, can't evaluate type of FPGA Board");
	    byte majorVersion = config.getMajorVersion();
	    byte minorVersion = config.getMinorVersion();
	    String defaultFN = "../usb-fpga-" + majorVersion + "." + ( minorVersion / 10) + ( minorVersion % 10) + "/default." + ( ztex.dev().fx3() ? "img" : "ihx" );
	    System.out.println("Found " + config.getName()+",  using firmware image `"+defaultFN+"'");
	    
	    if ( !ztex.valid() ) {
		System.out.println("No Firmware installed: Installing the latest default firmware");
		force = true;
	    } else if ( ! ztex.InterfaceCapabilities(ztex.CAPABILITY_DEFAULT ) ) {
		System.out.println("Non-default firmware (firmware without default interface) installed");
		ask = !updateonly && !force;
	    } else {
		ztex.defaultVersion();
		boolean b = (ztex.defaultVersion() < ztex.defaultLatestVersion) || ((ztex.defaultVersion()==ztex.defaultLatestVersion) && (ztex.defaultSubVersion()<ztex.defaultLatestSubVersion));
		System.out.println("Default Firmware version " + ztex.defaultVersion() + "." + ztex.defaultSubVersion() + " found, latest version: " + ztex.defaultLatestVersion + "." + ztex.defaultLatestSubVersion + 
		    ( b ? ": update recommended" : ": no update required" ) );
		force = force || b;
	    }
	    
	    if ( info ) {
		ztex.dispose();
		System.exit(0);
	    }

	    if ( !(new File(defaultFN)).exists() ) throw new Exception("Firmware image does not exist: "+defaultFN);
	    
	    if ( ask ) {
		BufferedReader reader = new BufferedReader( new InputStreamReader( System.in ) );
		System.out.print("Overwriting current firmware (y|n) ? ");
		String str = reader.readLine();
		force = str.equals("y") || str.equals("Y");
	    }
    
	    if ( ! force ) {
		ztex.dispose();
		System.exit(0);
	    }

// upload the firmware
	    System.out.println("Firmware upload time: " + ztex.uploadFirmware( defaultFN, force ) + " ms");
	    
	    System.out.println("Firmware to NV memory upload time: " + ztex.nvUploadFirmware( defaultFN, force ) + " ms");
	    
// release resources
	    ztex.dispose();
	}
	catch (Exception e) {
	    System.out.println("Error: "+e.getLocalizedMessage() );
	} 
	catch (Error e) {
	    System.out.println("Error: "+e.getLocalizedMessage() );
	} 
    } 
   
}

