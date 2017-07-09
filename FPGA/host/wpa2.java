/*!
intraffic -- example showing how the EZ-USB FIFO interface is used on ZTEX USB-FPGA Module 1.15y and 1.15y2
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

import java.io.*;
import java.util.*;

import ch.ntb.usb.*;

import ztex.*;

// *****************************************************************************
// ******* ParameterException **************************************************
// *****************************************************************************
// Exception the prints a help message
class ParameterException extends Exception {
    public final static String helpMsg = new String (
    "Parameters:\n"+
    "    -d <number>       Device Number (default: 0)\n" +
    "    -f 	       Force uploads\n" +
    "    -p                Print bus info\n" +
    "    -w                Enable certain workarounds\n"+
    "    -h                This help" );

    public ParameterException (String msg) {
        super( msg + "\n" + helpMsg );
    }
}

// *****************************************************************************
// ******* USBReader ***********************************************************
// *****************************************************************************
class UsbReader extends Thread {
    private final int bufNum = 8;
    public final int bufSize = 512*1024;
    public byte[][] buf = new byte[bufNum][];
    public int[] bufBytes = new int[bufNum];
    private int readCount = -1;
    private int getCount = -1;
    public boolean terminate = false;
    private Ztex1v1 ztex;

    public UsbReader ( Ztex1v1 p_ztex ) {
        super ();
        ztex = p_ztex;
        for (int i=0; i<bufNum; i++) {
            buf[i]=new byte[bufSize];
        }
    }

    public int getBuffer () {
        getCount += 1;
        while (getCount >= readCount) {
            try {
                sleep(1);
            }
            catch ( InterruptedException e) {
            }
        }
        return getCount % bufNum;
    }

    public void reset () {
        getCount = readCount + 1;
    }

    public void write ( String input ) throws UsbException, InvalidFirmwareException, IndexOutOfBoundsException {
        byte buf[] = { (byte)0x50, (byte)0x34,
                        (byte)0x51, (byte)0x31,
                        (byte)0x52, (byte)0x32,
                        (byte)0x53, (byte)0x38,
                        (byte)0x51, (byte)0x31,
                        (byte)0x00, (byte)0x00,
                        (byte)0x00, (byte)0x00,
                        (byte)0x90, (byte)0xce,
                        (byte)0x91, (byte)0xce,
                        (byte)0x92, (byte)0xce,
                        (byte)0x93, (byte)0xce,
                        (byte)0xe94, (byte)0xce };//input.getBytes();
        //byte buf[] = "144774222334455555".getBytes();
        //System.out.println("Sending " + buf.length + " bytes: `" + input + "'" );

        int i = LibusbJava.usb_bulk_write(ztex.handle(), 0x06, buf, buf.length, 1000);
        if ( i<0 )
            //throw new UsbException("Error sending data: " + LibusbJava.usb_strerror());
            System.out.println("Error sending data: " + LibusbJava.usb_strerror());
        System.out.println("Send " + i + " bytes: `" + input + "'" );

        try {
                Thread.sleep( 100 );
        }
            catch ( InterruptedException e ) {
        }

        buf = new byte[512];
        i = LibusbJava.usb_bulk_read(ztex.handle(), 0x82, buf, 512, 1000);
        int iter = 0;
        while ( i >= 0 && iter < 5) {

            System.out.println("Reading "+i+" bytes");
            for (int j = 0; j < i; j++) {
                if (j % 16 == 0)
                    System.out.print(j+":");

                System.out.print(" " + String.format("%02x", buf[j] ));
                if (j % 16 == 15)
                    System.out.println(";");
            }

            i = LibusbJava.usb_bulk_read(ztex.handle(), 0x82, buf, 512, 1000);
            iter++;
        }
        if ( i < 0 ) {
            //throw new UsbException("Error receiving data: " + LibusbJava.usb_strerror());
            System.out.println("Error: read "+i);
        }
    }

    public void run() {
        setPriority(MAX_PRIORITY);

        // claim interface 0
        try {
            ztex.trySetConfiguration ( 1 );
            ztex.claimInterface ( 0 );
        }
        catch ( Exception e) {
            System.out.println("Error: "+e.getLocalizedMessage() );
            System.exit(2);
        }


        // reader loop
        while ( !terminate ) {
            readCount += 1;

            while ( readCount - bufNum >= getCount ) {
                try {
                    sleep(1);
                }
                catch ( InterruptedException e) {
                }
            }

            int i = readCount % bufNum;
            bufBytes[i] = LibusbJava.usb_bulk_read(ztex.handle(), 0x82, buf[i], 512, 1000);
            //	    System.out.println("Buffer " + i +": read " + bufBytes[i] + " bytes");
        }

        // release interface 0
        ztex.releaseInterface( 0 );

    }
}


// *****************************************************************************
// ******* Test0 ***************************************************************
// *****************************************************************************
class WPA2 extends Ztex1v1 {

    // ******* InTraffic **************************************************************
    // constructor
    public WPA2 ( ZtexDevice1 pDev ) throws UsbException {
        super ( pDev );
    }

    // ******* main ****************************************************************
    public static void main (String args[]) {

        int devNum = 0;
        boolean force = false;
        boolean workarounds = false;

        try {
            // init USB stuff
            LibusbJava.usb_init();
            //LibusbJava.usb_set_debug(5);

            // scan the USB bus
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
                else if ( args[i].equals("-f") ) {
                    force = true;
                }
                else if ( args[i].equals("-p") ) {
                    bus.printBus(System.out);
                    System.exit(0);
                }
                else if ( args[i].equals("-p") ) {
                    bus.printBus(System.out);
                    System.exit(0);
                }
                else if ( args[i].equals("-w") ) {
                    workarounds = true;
                }
                else if ( args[i].equals("-h") ) {
                    System.err.println(ParameterException.helpMsg);
                    System.exit(0);
                }
                else throw new ParameterException("Invalid Parameter: "+args[i]);
            }


            // create the main class
            WPA2 ztex = new WPA2 ( bus.device(devNum) );
            ztex.certainWorkarounds = workarounds;

            // upload the firmware if necessary
            if ( force || ! ztex.valid() || ! ztex.dev().productString().equals("intraffic example for UFM 1.15y")  ) {
                System.out.println("Firmware upload time: " + ztex.uploadFirmware( "wpa2.ihx", force ) + " ms");
                force=true;
            }

            System.out.println("" + ztex.numberOfFpgas() + " FPGA's found");

            // upload the bitstream if necessary
            for (int i=0; i<ztex.numberOfFpgas(); i++ ) {
                ztex.selectFpga(i);
                if ( force || ! ztex.getFpgaConfiguration() ) {
                    System.out.print("FPGA "+i+": ");
                    System.out.println("FPGA configuration time: " + ztex.configureFpga( "../hdl/ztex_wrapper.bit" , force ) + " ms");
                }
            }

            // read the traffic
            UsbReader reader = new UsbReader( ztex );
            reader.start();

            for (int fn=0; fn<ztex.numberOfFpgas(); fn++ ) {
                System.out.println("FPGA " + fn + ":");
                ztex.selectFpga(fn);

                // EZ-USB FIFO test (controlled mode)
                ztex.vendorCommand (0x60, "Set test mode", 0, 0);
                reader.reset();

                int vcurrent = -1;
                //for (int i=0; i<1; i++) {
                    reader.write("144774222334455555");
                //}


                System.out.println("Continous mode");
                // EZ-USB FIFO test (continous mode)
                ztex.vendorCommand (0x60, "Set test mode", 1, 0);
                reader.reset();

                vcurrent = -1;
                for (int i=0; i<10; i++) {
                    reader.write("144774222334455555");
                }

                System.out.println();

                /*
                // performance test (continous mode)
                ztex.vendorCommand (0x60, "Set test mode", 1, 0);
                reader.reset();

                int words = 0;
                int intSum = 0;
                int intMax = 0;
                int intAdj = 0;
                int lastwi = -1;
                for (int i=0; i<10; i++) {
                    int j = reader.getBuffer();
                    int bb = reader.bufBytes[j];
                    byte[] b = reader.buf[j];
                    int current = vcurrent+1;

                    System.out.print("Buffer " + i + ": " + Math.round(words*6000.0/(words+intSum))/100.0 + "MB/s, max. interrupt: " + Math.round(intMax/150.0)/100 + "ms    \r");
                }
                */
                System.out.println();
            }


            reader.terminate=true;

        }
        catch (Exception e) {
            System.out.println("Error: "+e.getLocalizedMessage() );
        }
    }

}
