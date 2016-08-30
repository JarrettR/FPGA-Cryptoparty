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

package ztex;

import java.io.*;
import java.util.*;
import java.nio.*;

import org.usb4java.*;

/**
  * A helper class to implement asynchronous bulk and interrupt write transfers.
  */

// *****************************************************************************
// ******* ZtexUsbWriter *******************************************************
// *****************************************************************************
public class ZtexUsbWriter {
    private Device dev;
    private DeviceHandle handle;
    private int ep;
    private int bufNum;
    private int bufSize;
    private boolean isInt;

    private ByteBuffer[] bufs;
    private Transfer[] transfers;
    private volatile boolean[] pending;
    private int transmitCount = 0;
    private volatile long byteCount = 0;
    private boolean cancelled = false; 	// transfer.status() seem not to work under windows
    
    private final TransferCallback callback = new TransferCallback() {
    	public void processTransfer(Transfer transfer) {
	    byteCount += transfer.actualLength();
	    if ( (transfer.actualLength()!=transfer.length()) && (!cancelled) && (transfer.status()!=LibUsb.TRANSFER_CANCELLED) ) System.err.println( ZtexDevice1.name(dev) + ": Invalid length of sent data: " + transfer.actualLength() + " bytes sent, expected " + transfer.length() );
    	    // find index
    	    int i=0;
    	    while ( (i<bufNum) && (!transfer.equals(transfers[i])) ) i++;
    	    if ( i < bufNum ) {
    		pending[i] = false;
    	    }
    	    else System.err.println("Internal error: unknown transfer");
    	}
    };
    
    
// ******* ZtexUsbWriter *********************************************************
/**
  * Creates the writer for a given USB device and endpoint number.
  * @param p_handle The device handle used for communication (must be opened).
  * @param p_ep The input endpoint.
  * @param p_isInt True if it is an interrupt transfer.
  * @param p_bufSize size of each buffer. Typical values are 64KByte to 512KByte
  * @param p_bufNum number of buffer. Recommended queue size are 2MByte to 8MByte.
  */
    public ZtexUsbWriter ( DeviceHandle p_handle, int p_ep, boolean p_isInt, int p_bufNum, int p_bufSize ) {
        dev = LibUsb.getDevice(p_handle);
        handle = p_handle;
        ep = p_ep;
        bufNum = p_bufNum;
        bufSize = p_bufSize;
        bufs = new ByteBuffer[bufNum];
        transfers = new Transfer[bufNum];
        pending = new boolean[bufNum];
	for (int i=0; i<bufNum; i++) {
	    bufs[i] = BufferUtils.allocateByteBuffer(bufSize);
	    transfers[i] = null;
	    pending[i] = false;
	}
    }

/**
  * Creates the writer from a given ZTEX device and endpoint number.
  * @param ztex The ZTEX device.
  * @param p_ep The number of the input endpoint
  * @param p_isInt True if it is an interrupt transfer.
  * @param p_bufSize size of each buffer. Typical values are 64KByte to 512KByte
  * @param p_bufNum number of buffer. Recommended queue size is 2MByte to 8MByte.
  */
    public ZtexUsbWriter ( Ztex1 ztex, int p_ep, boolean p_isInt, int p_bufNum, int p_bufSize ) {
	this(ztex.handle(), 127 & p_ep, p_isInt, p_bufNum, p_bufSize);
    }

/**
  * Creates the writer for the input endpoint of the default interface of a ZTEX device.
  * @param ztex The ZTEX device.
  * @param p_bufSize size of each buffer. Typical values are 64KByte to 512KByte
  * @param p_bufNum number of buffer. Recommended queue size is 2MByte to 8MByte.
  */
    public ZtexUsbWriter ( Ztex1v1 ztex, int p_bufNum, int p_bufSize ) throws InvalidFirmwareException, UsbException, CapabilityException {
	this(ztex.handle(), ztex.defaultOutEP(), false, p_bufNum, p_bufSize);
    }
    
// ******* transmitBuffer ******************************************************
/**
  * Transmit the next buffer. 
  * @param buf The byte array which contains the data.
  * @param maxLen Maximum amount of data to transmit. If it is larger than the buffer size the last bytes are ignored.
  * @param timeout Timeout in ms. If timeout occurs the function returns -1.
  * @return The number of bytes transmitted or -1 if timeout occurs.
  * @throws UsbExecption if an error occurred.
  */
    public int transmitBuffer(byte[] buf, int maxLen, int timeout) throws UsbException {
	int j = transmitCount % bufNum;
//	System.out.println("TB1 "+transmitCount);
	for (int i=0; pending[j] && (i<timeout); i++ ) {
   	    try { Thread.sleep(1); } catch ( InterruptedException e) { } 
	}
	if ( pending[j] ) {
	    return -1;
	}
//	System.out.println("TB2 "+transmitCount);
	if ( transfers[j] == null ) {
	    transfers[j] = LibUsb.allocTransfer();
	    if ( transfers[j] == null ) throw new UsbException(dev, "Error allocating transfer buffer " + transmitCount);
	    if ( isInt ) LibUsb.fillInterruptTransfer(transfers[j], handle, (byte)ep, bufs[j], callback, this, 5000);
	    else LibUsb.fillBulkTransfer(transfers[j], handle, (byte)ep, bufs[j], callback, this, 5000);
	}
//	System.out.println("TB "+transmitCount);
	final int k = Math.min(Math.min(bufSize, maxLen), buf.length);
	bufs[j].rewind();
	bufs[j].put(buf, 0, k);
	transfers[j].setLength(k);
//	System.out.println("TB3 "+k);
        int result = LibUsb.submitTransfer(transfers[j]);
        if ( result!=LibUsb.SUCCESS ) throw new UsbException(dev, "Error submitting buffer " + transmitCount, result);
	pending[j] = true;
	transmitCount++;
	cancelled = false;
//	System.out.println("TB4 "+transmitCount);
	return k;
    }


/**
  * Transmit the next buffer. 
  * @param buf The byte array which contains the data. If the array is larger than the buffer size the last bytes are ignored.
  * @param timeout Timeout in ms. If timeout occurs the function returns -1.
  * @return The number of bytes transmitted or -1 if timeout occurs.
  * @throws UsbExecption if an error occurred.
  */
    public int transmitBuffer(byte[] buf, int timeout) throws UsbException {
	return transmitBuffer(buf, buf.length, timeout);
    }

// ******* byteCount ***********************************************************
/**
  * Return the number of bytes transmitted.
  * @return The number of bytes transmitted.
  */
    public long byteCount () {
	return byteCount;
    } 

// ******* bufSize *************************************************************
/**
  * Return the buffer size.
  * @return The buffer size.
  */
    public int bufSize () {
	return bufSize;
    } 

// ******* cancel **************************************************************
/**
  * Cancels all pending transfers, also see {@link #cancelWait(int)}.
  * @throws UsbExecption if an error occurred.
  */
    public void cancel() throws UsbException {
	cancelled = true;
	for (int i=0; i<bufNum; i++ ) {
	    if ( (transfers[i] != null) && pending[i] ) {
		int result = LibUsb.cancelTransfer(transfers[i]);
	    	if ( (result!=LibUsb.SUCCESS) && (result!=LibUsb.ERROR_NOT_FOUND) ) throw new UsbException(dev, "Unable to cancel transfer", result);
	    }
	}
    }

// ******* wait **********************************************************
/**
  * Waits until all pending transfers are finished or canceled.
  * @throws UsbExecption if an error occurred.
  */
    public boolean wait(int timeout) throws UsbException {
	boolean b = true;
	for (int i=0; b && i<=timeout; i+=20 ) {
	    b = false;
	    for (int j=0; j<bufNum; j++ ) {
		if ( transfers[j] != null ) {
		    b = b || pending[j];
		    if ( !pending[j] ) {
			LibUsb.freeTransfer(transfers[j]);
			transfers[j] = null;
		    }
		}
	    }
	    try { if ( b ) Thread.sleep(20); } catch ( InterruptedException e) { } 
	}
	return !b;
    }

// ******* cancelWait **********************************************************
/**
  * Cancels all pending transfers and waits until transfers are canceled.
  * @throws UsbExecption if an error occurred.
  */
    public boolean cancelWait(int timeout) throws UsbException {
	cancel();
	return wait(timeout);
    }


}
