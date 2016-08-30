/*!
   Java host software API of ZTEX SDK
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
    Functions for USB devices with ZTEX descriptor 1
*/
package ztex;

import java.io.*;
import java.util.*;
import java.nio.*;

import org.usb4java.*;

/**
  * This class implements the interface-independent part of the communication protocol for the interaction with the ZTEX firmware.<p>
  * All firmware implementations that provide the ZTEX descriptor 1 are supported.
  * A description of this descriptor can be found in {@link ZtexDevice1}.
  * <p>
  * The most important features of this class are the functions for uploading the firmware
  * and the renumeration management.
  * <p>
  * The interface dependent part of the communication protocol (currently only one is supported)
  * can be found in {@link Ztex1v1}.
  * @see ZtexDevice1
  * @see Ztex1v1
  */
public class Ztex1 {
    private DeviceHandle handle = null;
    private ZtexDevice1 dev = null;
    private Vector<String> oldDevices = new Vector<String>();
    private String oldDev = null;
    private boolean[] interfaceClaimed = new boolean[256];
    private boolean configurationSet = false;
/** * The timeout for  control messages in ms. */    
    public int controlMsgTimeout = 1000;	// in ms
    private long lastVendorCommandT = 0;

    
// ******* Ztex1 ***************************************************************
/** 
  * Constructs an instance from a given device.
  * @param pDev The given device.
  * @throws UsbException if an communication error occurred.
  */
    public Ztex1 ( ZtexDevice1 pDev ) throws UsbException {
	dev = pDev;
	init();
	dev.ref();
    }

// ******* init ****************************************************************
/** 
  * Initializates the class.
  * @throws UsbException if an communication error occurred.
  */
    protected synchronized void init () throws UsbException {
	for (int i=0; i<256; i++)
	    interfaceClaimed[i] = false;

	handle = new DeviceHandle();
	int result = LibUsb.open(dev.dev(), handle);
	if (result != LibUsb.SUCCESS) throw new UsbException(dev.dev(), "Unable to open USB device", result);
	
    }

// ******* dispose *************************************************************
/** 
  * This should be called if the class is not used anymore. 
  * It closes the USB connection and releases all resources
  */
    public synchronized void dispose () {
	if ( handle != null ) {
	    for (int i=0; i<256; i++)
		if ( interfaceClaimed[i] ) 
		    LibUsb.releaseInterface(handle, i);

	    LibUsb.close(handle);
	    handle = null;
	}
	if ( dev != null ) {
	    dev.unref();
	    dev = null;
	}
    }

// ******* finalize ************************************************************
    protected void finalize() throws Throwable {
	dispose();
    }

// ******* handle **************************************************************
/** * Returns the USB file handle. */
    public synchronized final DeviceHandle handle() 
    {
        return handle;
    }

// ******* dev *****************************************************************
/** 
  * Returns the corresponding {@link ZtexDevice1}. 
  * @return the corresponding {@link ZtexDevice1}. 
  */
    public synchronized final ZtexDevice1 dev() 
    {
        return dev;
    }

// ******* valid ***************************************************************
/** 
  * Returns true if ZTEX descriptor 1 is available.
  * @return true if ZTEX descriptor 1 is available.
  */
    public synchronized boolean valid ( ) {
	return dev.valid();
    }

// ******* checkValid **********************************************************
/** 
  * Checks whether ZTEX descriptor 1 is available.
  * @throws InvalidFirmwareException if ZTEX descriptor 1 is not available.
  */
    public synchronized void checkValid () throws InvalidFirmwareException {
	if ( ! dev.valid() ) 
	    throw new InvalidFirmwareException(this, "Can't read ZTEX descriptor 1");
    }

// ******* vendorCommand *******************************************************
/**
  * Sends a vendor command to Endpoint 0 of the EZ-USB device.
  * The command may be send multiple times until the {@link #controlMsgTimeout} is reached.
  * @param cmd The command number (0..255).
  * @param func The name of the command. This string is used for the generation of error messages.
  * @param value The value (0..65535), i.e bytes 2 and 3 of the setup data.
  * @param index The index (0..65535), i.e. bytes 4 and 5 of the setup data.
  * @param buf The payload data buffer. The full buffer is sent, i.e. transfer size is equal to buffer capacity.
  * @return the number of bytes sent.
  * @throws UsbException if a communication error occurs.
  */
    public synchronized int vendorCommand (int cmd, String func, int value, int index, ByteBuffer buf) throws UsbException {
	long t0 = new Date().getTime()-100;
	int trynum = 0;
	int i = -1;
	if ( controlMsgTimeout < 200 )
	    controlMsgTimeout = 200;
	    i = LibUsb.controlTransfer(handle, (byte)0x40, (byte)(cmd & 255), (short)(value & 0xffff), (short)(index & 0xffff), buf, controlMsgTimeout);
	    lastVendorCommandT = new Date().getTime();
	    if ( i < 0 ) {
		System.err.println("Warning (try " + (trynum+1) + "): " + LibUsb.strError(i) );
		try {
    		    Thread.sleep( 1 << trynum );
		}
		    catch ( InterruptedException e ) {
		}	
		trynum++;
	    }
	if ( i < 0 ) throw new UsbException( dev.dev(), (func != null ? func + ": " : "" ) + LibUsb.strError(i));
	return i;
    }

/**
  * Sends a vendor command to Endpoint 0 of the EZ-USB device.
  * The command may be send multiple times until the {@link #controlMsgTimeout} is reached.
  * @param cmd The command number (0..255).
  * @param func The name of the command. This string is used for the generation of error messages.
  * @param value The value (0..65535), i.e bytes 2 and 3 of the setup data.
  * @param index The index (0..65535), i.e. bytes 4 and 5 of the setup data.
  * @param length The size of the payload data (0..65535), i.e. bytes 6 and 7 of the setup data.
  * @param buf The payload data buffer.
  * @return the number of bytes sent.
  * @throws UsbException if a communication error occurs.
  */
    public synchronized int vendorCommand (int cmd, String func, int value, int index, byte[] buf, int length) throws UsbException {
	ByteBuffer buffer = BufferUtils.allocateByteBuffer(length);
	buffer.put(buf,0,length);
	return vendorCommand(cmd, func, value, index, buffer);
    }

/**
  * Sends a vendor command with no payload data to Endpoint 0 of the EZ-USB device.
  * The command may be send multiple times until the {@link #controlMsgTimeout} is reached.
  * @param cmd The command number (0..255).
  * @param func The name of the command. This string is used for the generation of error messages.
  * @param value The value (0..65535), i.e bytes 2 and 3 of the setup data.
  * @param index The index (0..65535), i.e. bytes 4 and 5 of the setup data.
  * @return the number of bytes sent.
  * @throws UsbException if a communication error occurs.
  */
    public int vendorCommand (int cmd, String func, int value, int index) throws UsbException {
	return vendorCommand (cmd, func, value, index, ByteBuffer.allocateDirect(0));
    }

/**
  * Sends a vendor command with no payload data and no setup data to Endpoint 0 of the EZ-USB device.
  * The command may be send multiple times until the {@link #controlMsgTimeout} is reached.
  * @param cmd The command number (0..255).
  * @param func The name of the command. This string is used for the generation of error messages.
  * @return the number of bytes sent.
  * @throws UsbException if a communication error occurs.
  */
    public int vendorCommand (int cmd, String func) throws UsbException {
	byte[] buf = { 0 };
	return vendorCommand (cmd, func, 0, 0, ByteBuffer.allocateDirect(0));
    }

// ******* vendorRequest *******************************************************
/**
  * Sends a vendor request to Endpoint 0 of the EZ-USB device.
  * The request may be send multiple times until the {@link #controlMsgTimeout} is reached.
  * @param cmd The request number (0..255).
  * @param func The name of the request. This string is used for the generation of error messages.
  * @param value The value (0..65535), i.e bytes 2 and 3 of the setup data.
  * @param index The index (0..65535), i.e. bytes 4 and 5 of the setup data.
  * @param buf The payload data buffer. Buffer capacity determines the length of the transfer.
  * @return the number of bytes received.
  * @throws UsbException if a communication error occurs.
  */
    public synchronized int vendorRequest (int cmd, String func, int value, int index, ByteBuffer buf) throws UsbException {
	long t0 = new Date().getTime()-100;
	int trynum = 0;
	int i = -1;
	if ( controlMsgTimeout < 200 )
	    controlMsgTimeout = 200;
	while ( i<=0 && new Date().getTime()-t0<controlMsgTimeout ) {		// we repeat the message until the timeout has reached
	    //	Wait at least 1ms after the last command has been send
	    long ms = new Date().getTime() - lastVendorCommandT;
	    if ( ms < 2 ) {
		try {
    	    	    Thread.sleep(1);
		}
	    	    catch ( InterruptedException e ) {
		}	
	    }
		
	    i = LibUsb.controlTransfer(handle, (byte)(0xc0 & 255), (byte)(cmd & 255), (short)(value & 0xffff), (short)(index & 0xffff), buf, controlMsgTimeout);
	    if ( i < 0 ) {
		System.err.println("Warning (try " + (trynum+1) + "): " + LibUsb.strError(i) );
		try {
    		    Thread.sleep( 1 << trynum );		
		}
		    catch ( InterruptedException e ) {
		}	
		trynum++;
	    }
	} 
	if ( i < 0 )
	    throw new UsbException( dev.dev(), (func != null ? func + ": " : "" ) + LibUsb.strError(i));
	return i;
    }

/**
  * Sends a vendor request to Endpoint 0 of the EZ-USB device.
  * The request may be send multiple times until the {@link #controlMsgTimeout} is reached.
  * @param cmd The request number (0..255).
  * @param func The name of the request. This string is used for the generation of error messages.
  * @param value The value (0..65535), i.e bytes 2 and 3 of the setup data.
  * @param index The index (0..65535), i.e. bytes 4 and 5 of the setup data.
  * @param maxlen The size of the requested payload data (0..65535), i.e. bytes 6 and 7 of the setup data.
  * @param buf The payload data buffer.
  * @return the number of bytes received.
  * @throws UsbException if a communication error occurs.
  */
    public synchronized int vendorRequest (int cmd, String func, int value, int index, byte[] buf, int maxlen) throws UsbException {
	ByteBuffer buffer = BufferUtils.allocateByteBuffer(maxlen);
	int i = vendorRequest(cmd, func, value, index, buffer);
	try {
	    buffer.get(buf,0,maxlen);
	}
	catch ( Exception e ) {
	    // errors can be ignored
	}
	return i;
	
    }

/**
  * Sends a vendor request to Endpoint 0 of the EZ-USB device.
  * The request may be send multiple times until the {@link #controlMsgTimeout} is reached.
  * @param cmd The request number (0..255).
  * @param func The name of the request. This string is used for the generation of error messages.
  * @param buf The payload data buffer.
  * @return the number of bytes sent.
  * @throws UsbException if a communication error occurs.
  */
    public int vendorRequest (int cmd, String func, ByteBuffer buf) throws UsbException {
	return vendorRequest (cmd, func, 0, 0, buf);
    }

/**
  * Sends a vendor request to Endpoint 0 of the EZ-USB device.
  * The request may be send multiple times until the {@link #controlMsgTimeout} is reached.
  * @param cmd The request number (0..255).
  * @param func The name of the request. This string is used for the generation of error messages.
  * @param maxlen The size of the requested payload data (0..65535), i.e. bytes 6 and 7 of the setup data.
  * @param buf The payload data buffer.
  * @return the number of bytes sent.
  * @throws UsbException if a communication error occurs.
  */
    public int vendorRequest (int cmd, String func, byte[] buf, int maxlen) throws UsbException {
	return vendorRequest (cmd, func, 0, 0, buf, maxlen);
    }

// ******* vendorCommand2 ******************************************************
/**
  * Sends a vendor command to Endpoint 0 of the EZ-USB device and throws an {@link UsbException} if not all of the payload has been sent.
  * The command may be send multiple times until the {@link #controlMsgTimeout} is reached.
  * @param cmd The command number (0..255).
  * @param func The name of the command. This string is used for the generation of error messages.
  * @param value The value (0..65535), i.e bytes 2 and 3 of the setup data.
  * @param index The index (0..65535), i.e. bytes 4 and 5 of the setup data.
  * @param buf The payload data buffer. The full buffer is sent, i.e. transfer size is equal to buffer capacity.
  * @throws UsbException if a communication error occurs or if not all of the payload has been sent.
  */
    public synchronized void vendorCommand2 (int cmd, String func, int value, int index, ByteBuffer buf) throws UsbException {
	int length = buf.capacity();
	int i = vendorCommand (cmd, func, value, index, buf);
	if ( i != length )
	    throw new UsbException( dev.dev(), (func != null ? func + ": " : "" ) + "Send " + i + " byte of data instead of " + length + " bytes");
    }

/**
  * Sends a vendor command to Endpoint 0 of the EZ-USB device and throws an {@link UsbException} if not all of the payload has been sent.
  * The command may be send multiple times until the {@link #controlMsgTimeout} is reached.
  * @param cmd The command number (0..255).
  * @param func The name of the command. This string is used for the generation of error messages.
  * @param value The value (0..65535), i.e bytes 2 and 3 of the setup data.
  * @param index The index (0..65535), i.e. bytes 4 and 5 of the setup data.
  * @param length The size of the payload data (0..65535), i.e. bytes 6 and 7 of the setup data.
  * @param buf The payload data buffer.
  * @throws UsbException if a communication error occurs or if not all of the payload has been sent.
  */
    public synchronized void vendorCommand2 (int cmd, String func, int value, int index, byte[] buf, int length) throws UsbException {
	int i = vendorCommand (cmd, func, value, index, buf, length);
	if ( i != length )
	    throw new UsbException( dev.dev(), (func != null ? func + ": " : "" ) + "Send " + i + " byte of data instead of " + length + " bytes");
    }

// ******* vendorRequest2 ******************************************************
/**
  * Sends a vendor request to Endpoint 0 of the EZ-USB device and throws an {@link UsbException} if not all of the payload has been received.
  * The request may be send multiple times until the {@link #controlMsgTimeout} is reached.
  * @param cmd The request number (0..255).
  * @param func The name of the request. This string is used for the generation of error messages.
  * @param value The value (0..65535), i.e bytes 2 and 3 of the setup data.
  * @param index The index (0..65535), i.e. bytes 4 and 5 of the setup data.
  * @param buf The payload data buffer. Buffer capacity determines the length of the transfer.
  * @throws UsbException if a communication error occurs or not all of the payload has been received.
  */
    public void vendorRequest2 (int cmd, String func, int value, int index, ByteBuffer buf) throws UsbException {
	int maxlen = buf.capacity();
	int i = vendorRequest(cmd, func, value, index, buf);
	if ( i != maxlen )
	    throw new UsbException( dev.dev(), (func != null ? func + ": " : "" ) + "Received " + i + " byte of data, expected "+maxlen+" bytes");
    }

/**
  * Sends a vendor request to Endpoint 0 of the EZ-USB device and throws an {@link UsbException} if not all of the payload has been received.
  * The request may be send multiple times until the {@link #controlMsgTimeout} is reached.
  * @param cmd The request number (0..255).
  * @param func The name of the request. This string is used for the generation of error messages.
  * @param buf The payload data buffer.
  * @throws UsbException if a communication error occurs or not all of the payload has been received.
  */
    public void vendorRequest2 (int cmd, String func, ByteBuffer buf) throws UsbException {
	vendorRequest2(cmd, func, 0, 0, buf);
    }

/**
  * Sends a vendor request to Endpoint 0 of the EZ-USB device and throws an {@link UsbException} if not all of the payload has been received.
  * The request may be send multiple times until the {@link #controlMsgTimeout} is reached.
  * @param cmd The request number (0..255).
  * @param func The name of the request. This string is used for the generation of error messages.
  * @param value The value (0..65535), i.e bytes 2 and 3 of the setup data.
  * @param index The index (0..65535), i.e. bytes 4 and 5 of the setup data.
  * @param maxlen The size of the requested payload data (0..65535), i.e. bytes 6 and 7 of the setup data.
  * @param buf The payload data buffer.
  * @throws UsbException if a communication error occurs or not all of the payload has been received.
  */
    public void vendorRequest2 (int cmd, String func, int value, int index, byte[] buf, int maxlen) throws UsbException {
	int i = vendorRequest(cmd, func, value, index, buf, maxlen);
	if ( i != maxlen )
	    throw new UsbException( dev.dev(), (func != null ? func + ": " : "" ) + "Received " + i + " byte of data, expected "+maxlen+" bytes");
    }

/**
  * Sends a vendor request to Endpoint 0 of the EZ-USB device and throws an {@link UsbException} if not all of the payload has been received.
  * The request may be send multiple times until the {@link #controlMsgTimeout} is reached.
  * @param cmd The request number (0..255).
  * @param func The name of the request. This string is used for the generation of error messages.
  * @param maxlen The size of the requested payload data (0..65535), i.e. bytes 6 and 7 of the setup data.
  * @param buf The payload data buffer.
  * @throws UsbException if a communication error occurs or not all of the payload has been received.
  */
    public void vendorRequest2 (int cmd, String func, byte[] buf, int maxlen) throws UsbException {
	vendorRequest2(cmd, func, 0, 0, buf, maxlen);
    }

// ******* bulkWrite ***********************************************************
/**
  * Wrapper method for ibUsb.bulkTransfer(DeviceHandle,byte,ByteBuffer,IntBuffer,long).
  * @param ep The endpoint number.
  * @param buffer The payload data buffer. The whole buffer is transferred, i.e. transfer legth is equal to buffer capacity
  * @param timeout The timeout in ms
  * @return The error code (<0) if an error occurred, otherwise the amount of transferred date
  */
    public int bulkWrite(int ep, ByteBuffer buffer, long timeout) 
    {
	IntBuffer transferred = BufferUtils.allocateIntBuffer();
	int result = LibUsb.bulkTransfer(handle, (byte)(ep & 127), buffer, transferred, timeout);
	return result < 0 ? result : transferred.get();
    }

/**
  * Wrapper method for LibUsb.bulkTransfer(DeviceHandle,byte,ByteBuffer,IntBuffer,long).
  * @param ep The endpoint number.
  * @param buf The payload data buffer.
  * @param length The size of the payload data
  * @param timeout The timeout in ms
  * @return The error code (<0) if an error occurred, otherwise the amount of transferred date
  */
    public int bulkWrite(int ep, byte[] buf, int length, long timeout) 
    {
	ByteBuffer buffer = BufferUtils.allocateByteBuffer(length);
	buffer.put(buf,0,length);
	IntBuffer transferred = BufferUtils.allocateIntBuffer();
	int result = LibUsb.bulkTransfer(handle, (byte)(ep & 127), buffer, transferred, timeout);
	return result < 0 ? result : transferred.get();
    }

// ******* bulkRead ************************************************************
/**
  * Wrapper method for LibUsb.bulkTransfer(DeviceHandle,byte,ByteBuffer,IntBuffer,long).
  * @param ep The endpoint number.
  * @param buffer The payload data buffer. The transfer length is determined by buffer capacity.
  * @param timeout The timeout in ms
  * @return The error code (<0) if an error occurred, otherwise the amount of transferred date
  */
    public int bulkRead(int ep, ByteBuffer buffer, long timeout) 
    {
	IntBuffer transferred = BufferUtils.allocateIntBuffer();
	int result = LibUsb.bulkTransfer(handle, (byte)(128 | (ep & 127)), buffer, transferred, timeout);
	return result < 0 ? result : transferred.get();
    }

/**
  * Wrapper method for LibUsb.bulkTransfer(DeviceHandle,byte,ByteBuffer,IntBuffer,long).
  * @param ep The endpoint number.
  * @param buf The payload data buffer.
  * @param maxlen The size of the transfer.
  * @param timeout The timeout in ms
  * @return The error code (<0) if an error occurred, otherwise the amount of transferred date
  */
    public int bulkRead(int ep, byte[] buf, int maxlen, long timeout) 
    {
	ByteBuffer buffer = BufferUtils.allocateByteBuffer(maxlen);
	IntBuffer transferred = BufferUtils.allocateIntBuffer();
	int result = LibUsb.bulkTransfer(handle, (byte)(128 | (ep & 127)), buffer, transferred, timeout);
	try {
	    buffer.get(buf,0,maxlen);
	}
	catch ( Exception e ) {
	    // errors can be ignored
	}
	return result < 0 ? result : transferred.get();
    }

// ******* allocateByteBuffer **************************************************
/**
  * Utility function that creates a {@link ByteBuffer} from byte array.
  * @param buf The byte array.
  * @return A {@link ByteBuffer} .
  */
    public static ByteBuffer allocateByteBuffer(byte[] buf) 
    {
	ByteBuffer buffer = BufferUtils.allocateByteBuffer(buf.length);
	return buffer.put(buf,0,buf.length);
    }

/**
  * Utility function that creates a {@link ByteBuffer} from byte array.
  * @param buf The byte array.
  * @param offs The offset of the first data in the byte array.
  * @param length Length of the The byte array.
  * @return A {@link ByteBuffer}.
  */
    public static ByteBuffer allocateByteBuffer(byte[] buf, int offs, int length) 
    {
	ByteBuffer buffer = BufferUtils.allocateByteBuffer(length);
	return buffer.put(buf,offs,length);
    }

// ******* setConfiguration ****************************************************
/**
  * Sets the configuration.
  * @param config The configuration number (usually 1)
  * @throws UsbException if an error occurs while attempting to set the configuration.
  */
    public synchronized void setConfiguration ( int config) throws UsbException{
	int result = LibUsb.setConfiguration(handle(), config);
	if ( result < 0 )
	    throw new UsbException(dev.dev(), "Setting configuration to " + config + " failed: ", result);
	configurationSet = true;
    }


// ******* trySetConfiguration ****************************************************
/**
  * Tries to set the configuration.
  * If an error occurs while attempting to set the configuration, a warning message is printed to stderr.
  * @param config The configuration number (usually 1)
  */
    public synchronized void trySetConfiguration ( int config) {
	int result = LibUsb.setConfiguration(handle(), config);
	if ( result < 0 )
	    System.err.println("Setting configuration to " + config + " failed: " + LibUsb.strError(result));
	configurationSet = true;
    }


// ******* getInterfaceClaimed *************************************************
/**
  * Returns true if interface is claimed.
  * @return true if interface is claimed
  * @param iface The interface number
  */
    public synchronized boolean getInterfaceClaimed ( int iface ) {
	return iface>=0 && iface<256 && interfaceClaimed[iface];
    }
    

// ******* claimInterface ******************************************************
/**
  * Claims an interface.
  * @param iface The interface number (usually 0)
  * @throws UsbException if an error occurs while attempting to claim the interface.
  */
    public synchronized void claimInterface ( int iface) throws UsbException{
	if ( ! configurationSet )
	    trySetConfiguration(1);
	if ( iface<0 || iface>=256 || (!interfaceClaimed[iface]) ) {
	    int result = LibUsb.claimInterface(handle(), iface);
	    if ( result < 0 ) throw new UsbException(dev.dev(), "Claiming interface " + iface + " failed: ", result);
	}
	if ( iface>=0 && iface < 256 )
	    interfaceClaimed[iface]=true;
    }


// ******* releaseInterface ****************************************************
/**
  * Releases an interface.
  * @param iface The interface number (usually 0)
  */
    public synchronized void releaseInterface ( int iface ) {
	if ( iface<0 || iface>=256 || interfaceClaimed[iface] ) 
	    LibUsb.releaseInterface(handle(), iface);
	if ( iface>=0 && iface < 256 )
	    interfaceClaimed[iface]=false;
    }


// ******* findOldDevices ******************************************************
    private synchronized void findOldDevices() throws DeviceLostException, UsbException {
	oldDev = dev.name();
	oldDevices.clear();
//	System.out.println("oldDev="+oldDev);

	ZtexContext context = new ZtexContext();
	DeviceList dl = new DeviceList();
	int result = LibUsb.getDeviceList(context.context(), dl);
	if (result < 0) {
	    context.unref();
	    throw new UsbException( "findOldDevices: Unable to get device list: ", result);
	}
	
	try {
    	    for (Device dev: dl) {
		oldDevices.add(ZtexDevice1.name(dev));
//		System.out.println("add " + ZtexDevice1.name(dev) );
	    }
	}
	finally {
    	    LibUsb.freeDeviceList(dl, true);
    	    context.unref();
    	}
    }

// ******* initNewDevice *******************************************************
    private synchronized void initNewDevice (String errBase, boolean scanUnconfigured ) throws DeviceLostException, UsbException, InvalidFirmwareException {
	
	// close current connection
	dispose();

	// scan the bus for up to 60 s for a new device. Boot sequence may take a while.
	for ( int i=0; i<300 && dev==null; i++ ) {
    	    Device newDev = null;
    	    
	    // wait 0.2s
	    try {
    		Thread.sleep( 200 );
	    }
		catch ( InterruptedException e ) {
	    }
	    // accept old address after 5s
	    if ( i == 25 ) oldDevices.remove(oldDev);

	    // scan bus for new devices
	    ZtexContext context = new ZtexContext();
	    DeviceList dl = new DeviceList();
	    int result = LibUsb.getDeviceList(context.context(), dl);
	    if ( result < 0 ) {
		context.unref();
		throw new UsbException( "findNewDevice: Unable to get device list: ", result);
	    }
	    try {
    		for (Device udev: dl) {
		    String s = ZtexDevice1.name(udev);
//		    System.out.println(s + ": " + oldDevices.indexOf(s));
		    if ( oldDevices.indexOf(s)<0 ) {
			if ( newDev != null ) throw new DeviceLostException( errBase + "More than 1 new devices found: `" + ZtexDevice1.name(newDev) + "', `" + ZtexDevice1.name(udev) + "'");
			newDev = udev;
		    }
		}
	
		// init new device
		if ( newDev != null ) {
		    // create ZtexDevice1
    		    DeviceDescriptor dd = new DeviceDescriptor();
    		    result = LibUsb.getDeviceDescriptor(newDev, dd);
    		    if (result != LibUsb.SUCCESS) throw new UsbException(newDev, "Unable to read device descriptor", result);
		    int vid = dd.idVendor() & 65535;
		    int pid = dd.idProduct() & 65535;
		    try {
			dev = new ZtexDevice1(context, newDev, dd.idVendor() & 65535, dd.idProduct() & 65535, scanUnconfigured );
		    }
		    catch ( DeviceNotSupportedException e ) {
			throw new InvalidFirmwareException( e.getLocalizedMessage() );
		    }
		    init();
		}
	    }
	    finally {
    	        LibUsb.freeDeviceList(dl, true);
    	        context.unref();
	    }
	}
	
	if ( dev == null ) throw new DeviceLostException( errBase + ": No new device found" );
    }

// ******* uploadFirmware ******************************************************
/**
  * Uploads the firmware to the EZ-USB and manages the renumeration process.
  * <p>
  * Before the firmware is uploaded the device is set into a reset state.
  * After the upload the firmware is booted and the renumeration starts.
  * During this process the device disappears from the bus and a new one 
  * occurs which will be assigned to this class automatically (instead of the disappeared one).
  * @param imgFile The firmware image.
  * @param force The compatibility check is skipped if true.
  * @throws IncompatibleFirmwareException if the given firmware is not compatible to the installed one, see {@link ZtexDevice1#compatible(int,int,int,int)} (Upload can be enforced using the <tt>force</tt> parameter)
  * @throws FirmwareUploadException If an error occurred while attempting to upload the firmware.
  * @throws UsbException if a communication error occurs.
  * @throws InvalidFirmwareException if ZTEX descriptor 1 is not available.
  * @throws DeviceLostException if a device went lost after renumeration.
  * @return the upload time in ms.
  */
//  returns upload time in ms
    public long uploadFirmware ( ZtexImgFile1 imgFile, boolean force ) throws IncompatibleFirmwareException, FirmwareUploadException, UsbException, InvalidFirmwareException, DeviceLostException {
// load the firmware file
//	imgFile.dataInfo(System.out);
//	System.out.println(imgFile);
	
// check for compatibility
	if ( ! force && dev.valid() ) {
	    if ( imgFile.interfaceVersion() != dev.interfaceVersion() )
		throw new IncompatibleFirmwareException("Wrong interface version: Expected 1, got " + imgFile.interfaceVersion() );
	
	    if ( ! dev.compatible ( imgFile.productId(0), imgFile.productId(1), imgFile.productId(2), imgFile.productId(3) ) )
		throw new IncompatibleFirmwareException("Incompatible productId's: Current firmware: " + ZtexDevice1.byteArrayString(dev.productId()) 
		    + "  firmware file: " + ZtexDevice1.byteArrayString(imgFile.productId()) );
	}

// prepare FX3 for booting from USB
	if ( dev.valid() && dev.fx3() ) {
	    findOldDevices();
	    resetFX3(false);
	    initNewDevice("Device lost after reset", true);
	}

// scan the bus for comparison
	findOldDevices();

// upload the firmware
	long time = EzUsb.uploadFirmware( handle, imgFile );

// find and init new device
	initNewDevice("Device lost after uploading Firmware", false);
	
	return time;
    }

/**
  * Uploads the firmware to the EZ-USB and manages the renumeration process.
  * <p>
  * Before the firmware is uploaded the device is set into a reset state.
  * After the upload the firmware is booted and the renumeration starts.
  * During this process the device disappears from the bus and a new one 
  * occurs which will be assigned to this class automatically (instead of the disappeared one).
  * @param imgFileName The file name of the firmware image in ihx or img format. The file can be a regular file or a system resource (e.g. a file from the current jar archive).
  * @param force The compatibility check is skipped if true.
  * @throws IncompatibleFirmwareException if the given firmware is not compatible to the installed one, see {@link ZtexDevice1#compatible(int,int,int,int)} (Upload can be enforced using the <tt>force</tt> parameter)
  * @throws FirmwareUploadException If an error occurred while attempting to upload the firmware.
  * @throws UsbException if a communication error occurs.
  * @throws InvalidFirmwareException if ZTEX descriptor 1 is not available.
  * @throws DeviceLostException if a device went lost after renumeration.
  * @return the upload time in ms.
  */
//  returns upload time in ms
    public long uploadFirmware ( String imgFileName, boolean force ) throws IncompatibleFirmwareException, FirmwareUploadException, UsbException, InvalidFirmwareException, DeviceLostException {
// load the firmware file
	ZtexImgFile1 imgFile;
	try {
	    imgFile = new ZtexImgFile1( imgFileName );
	}
	catch ( IOException e ) {
	    throw new FirmwareUploadException( e.getLocalizedMessage() );
	}
	catch ( ImgFileDamagedException e ) {
	    throw new FirmwareUploadException( e.getLocalizedMessage() );
	}
	return uploadFirmware( imgFile, force );
    }

/**
  * Uploads the firmware to the EZ-USB and manages the renumeration process.
  * <p>
  * Before the firmware is uploaded the device is set into a reset state.
  * After the upload the firmware is booted and the renumeration starts.
  * During this process the device disappears from the bus and a new one 
  * occurs which will be assigned to this class automatically (instead of the disappeared one).
  * @param imgIn Input stream from which the img file is read.
  * @param name Name of the input.
  * @param force The compatibility check is skipped if true.
  * @throws IncompatibleFirmwareException if the given firmware is not compatible to the installed one, see {@link ZtexDevice1#compatible(int,int,int,int)} (Upload can be enforced using the <tt>force</tt> parameter)
  * @throws FirmwareUploadException If an error occurred while attempting to upload the firmware.
  * @throws UsbException if a communication error occurs.
  * @throws InvalidFirmwareException if ZTEX descriptor 1 is not available.
  * @throws DeviceLostException if a device went lost after renumeration.
  * @return the upload time in ms.
  */
//  returns upload time in ms
    public long uploadFirmware ( InputStream imgIn, String name, boolean force ) throws IncompatibleFirmwareException, FirmwareUploadException, UsbException, InvalidFirmwareException, DeviceLostException {
// load the firmware file
	ZtexImgFile1 imgFile;
	try {
	    imgFile = new ZtexImgFile1( imgIn, name );
	}
	catch ( IOException e ) {
	    throw new FirmwareUploadException( e.getLocalizedMessage() );
	}
	catch ( ImgFileDamagedException e ) {
	    throw new FirmwareUploadException( e.getLocalizedMessage() );
	}
	return uploadFirmware( imgFile, force );
    }


// ******* resetFX3 ************************************************************
/**
  * Resets a FX3 device with ztex firmware using vendor command 0xA1.
  * If parameter boot is false new firmware has to be uploaded via USB.
  * @param boot True in order to enable booting firmware from Flash.
  * <p>
  * @throws UsbException if a communication error occurs.
  * @throws InvalidFirmwareException if device its not an FX3 device with ZTEX firmware.
  */
// boot
    private void resetFX3 ( boolean boot ) throws UsbException, InvalidFirmwareException {
	if ( !dev.valid() || !dev.fx3() ) throw new InvalidFirmwareException("Reset using vendor command 0xA1 is not supported by the device");
	LibUsb.controlTransfer(handle, (byte)0x40, (byte)(0xA1 & 255), /*value*/ (short)(boot ? 1 : 0), /*index*/ (short)0, ByteBuffer.allocateDirect(0), 100);
    }

// ******* resetEzUsb **********************************************************
/**
  * Resets the EZ-USB and manages the renumeration process.
  * <p>
  * After the reset the renumeration starts.
  * During this process the device disappears from the bus and a new one 
  * occurs which will be assigned to this class automatically (instead of the disappeared one).
  * @throws FirmwareUploadException If an error occurred while attempting to upload the firmware.
  * @throws UsbException if a communication error occurs.
  * @throws InvalidFirmwareException if ZTEX descriptor 1 is not available.
  * @throws DeviceLostException if a device went lost after renumeration.
  */
    public void resetEzUsb () throws FirmwareUploadException, UsbException, InvalidFirmwareException, DeviceLostException {
	if ( !dev.valid() && dev.fx3() ) {
	    System.err.println("Warning: Attempting to reset a FX3 device in factory state");
	    return;
	}

// scan the bus for comparison
	findOldDevices();
	
	if ( dev.fx3() ) {
	    resetFX3(true);
	}
	else {
// reset the EZ-USB
	    EzUsb.resetFx2(handle,true);
	    try {
		EzUsb.resetFx2(handle,false);		// error (may caused by re-numeration) can be ignored
	    }
	    catch ( FirmwareUploadException e ) {
	    }
	}

// find and init new device
	initNewDevice( "Device lost after resetting the EZ-USB", true );
    }

// ******* toString ************************************************************
/** 
  * Returns a lot of useful information about the corresponding device.
  * @return a lot of useful information about the corresponding device.
  */
    public String toString () {
	return dev.toString();
    }

}    
