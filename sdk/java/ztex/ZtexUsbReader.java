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
  * A helper class to implement asynchronous bulk and interrupt read transfers. This class also has a speed test mode.
  */

// *****************************************************************************
// ******* ZtexUsbReader *******************************************************
// *****************************************************************************
public class ZtexUsbReader {
    private Device dev;
    private DeviceHandle handle;
    private int ep;
    private boolean isInt;
    private int bufNum;
    private int bufSize;

    private ByteBuffer[] bufs;
    private Transfer[] transfers;
    private volatile boolean[] pending;
    private int getCount = 0;
    private volatile long byteCount = 0;
    
    private volatile boolean speedTest = false;
    private volatile long remaining;

    private final TransferCallback callback = new TransferCallback() {
    	public void processTransfer(Transfer transfer) {
	byteCount += transfer.actualLength();
    	// find index
    	int i=0;
    	while ( (i<bufNum) && (!transfer.equals(transfers[i])) ) i++;
    	if ( i < bufNum ) {
    	    if ( speedTest ) {
    		try {
    		    submit(i);
    		}
    		catch (Exception e) {
    		    System.err.println(e);
    		}
    	    }
    	    else pending[i] = false;
    	}
    	else System.err.println("Internal error: unknown transfer");
    	}
    };
    
    
// ******* ZtexUsbReader *******************************************************
/**
  * Creates the reader for a given USB device and endpoint number.
  * @param p_handle The device handle used for communication (must be opened).
  * @param p_ep The input endpoint.
  * @param p_isInt True if it is an interrupt transfer.
  * @param p_bufSize size of each buffer. Typical values are 64KByte to 512KByte
  * @param p_bufNum number of buffer. Recommended queue size is 2MByte to 8MByte.
  */
    public ZtexUsbReader ( DeviceHandle p_handle, int p_ep, boolean p_isInt, int p_bufNum, int p_bufSize ) {
        dev = LibUsb.getDevice(p_handle);
        handle = p_handle;
        ep = p_ep;
        isInt = p_isInt;
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
  * Creates the reader from a given ZTEX device and endpoint number.
  * @param ztex The ZTEX device.
  * @param p_ep The number of the input endpoint
  * @param p_isInt True if it is an interrupt transfer.
  * @param p_bufSize size of each buffer. Typical values are 64KByte to 512KByte
  * @param p_bufNum number of buffer. Recommended queue size is 2MByte to 8MByte.
  */
    public ZtexUsbReader ( Ztex1 ztex, int p_ep, boolean p_isInt, int p_bufNum, int p_bufSize ) {
	this(ztex.handle(), 128 | p_ep, p_isInt, p_bufNum, p_bufSize);
    }

/**
  * Creates the reader for the input endpoint of the default interface of a ZTEX device.
  * @param ztex The ZTEX device.
  * @param p_bufSize size of each buffer. Typical values are 64KByte to 512KByte
  * @param p_bufNum number of buffer. Recommended queue size is 2MByte to 8MByte.
  */
    public ZtexUsbReader ( Ztex1v1 ztex, int p_bufNum, int p_bufSize ) throws InvalidFirmwareException, UsbException, CapabilityException {
	this(ztex.handle(), ztex.defaultInEP(), false, p_bufNum, p_bufSize);
    }
    
// ******* submit **************************************************************
    private void submit(int i) throws UsbException {
	if ( transfers[i] == null ) return;
	if ( remaining <=0 ) {
	    LibUsb.freeTransfer(transfers[i]);
	    transfers[i] = null;
	    return;
	}
	remaining--;
        int result = LibUsb.submitTransfer(transfers[i]);
        if ( (result!=LibUsb.SUCCESS) && (result!=LibUsb.ERROR_BUSY) ) throw new UsbException(dev, "Error submitting buffer " + i, result);
        pending[i] = true;
    }
    
// ******* getBuffer ***********************************************************
/**
  * Get the next buffer. This does not work in speed test mode, see see {@link #start(long)}.
  * @param buf The byte array where to store the data.
  * @param timeout Timeout in ms. If timeout occurs the function returns -1.
  * @return The number of bytes read or -1 if timeout occurs.
  * @throws UsbExecption if an error occurred.
  */
    public int getBuffer(byte[] buf, int timeout) throws UsbException {
	if ( speedTest ) throw new UsbException(dev, "Unable to get buffer: Device is in speed test mode");
	int j = getCount % bufNum;
	for (int i=0; pending[j] && (i<timeout); i++ ) {
   	    try { Thread.sleep(1); } catch ( InterruptedException e) { } 
	}
	if ( pending[j] ) return -1;
	else if ( transfers[j] == null ) {
	    getCount++;
	    return 0;
	}
	else if ( transfers[j].status() != LibUsb.TRANSFER_COMPLETED ) throw new UsbException(dev, "Error receving buffer " + getCount + ": " + transfers[j].status());

	final int k = Math.min(transfers[j].actualLength(), buf.length);
	bufs[j].rewind();
	bufs[j].get(buf, 0, k);
	submit(j);
	getCount++;
	return k;
    }

// ******* byteCount ***********************************************************
/**
  * Return the number of bytes read since last {@link #start(long)}.
  * @return The number of bytes read since last {@link #start(long)}.
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
  * Cancels all pending transfers, also see {@link #cancelWait(int)},
  * @throws UsbExecption if an error occurred.
  */
    public void cancel() throws UsbException {
	speedTest = false;
	remaining = 0;
	for (int i=0; i<bufNum; i++ ) {
	    if ( (transfers[i] != null) && pending[i] ) {
		int result = LibUsb.cancelTransfer(transfers[i]);
	    	if ( (result!=LibUsb.SUCCESS) && (result!=LibUsb.ERROR_NOT_FOUND) ) throw new UsbException(dev, "Unable to cancel transfer", result);
	    }
	}
    }

// ******* cancelWait **********************************************************
/**
  * Cancels all pending transfers and waits until transfers are canceled.
  * @throws UsbExecption if an error occurred.
  */
    public boolean cancelWait(int timeout) throws UsbException {
	cancel();
	
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

// ******* start ***************************************************************
/**
  * Start the reader. 
  * The amount of buffers to be read is defined using the parameter maxCount.
  * A value of 0 starts infinite reads, a value of -1 starts the reader in speed test mode.
  * In this mode the buffer content is ignored and new read transfer are initiated immediately.
  * @param maxCount Maximum amount of bytes to read or 0 for infinite transfers or <0 for speed test mode.
  * @throws UsbExecption if an error occurred.
  */
    public void start(long maxCount) throws UsbException {
	byteCount = 0;
	speedTest = maxCount < 0;
	remaining = maxCount < 1 ? Long.MAX_VALUE : maxCount;
	for (int i=0; i<bufNum && remaining>0; i++) {
	    int j = (getCount+i) % bufNum;
	    if ( transfers[j] == null ) {
		transfers[j] = LibUsb.allocTransfer();
		if ( transfers[j] == null ) throw new UsbException(dev, "Error allocating transfer buffer "+j);
		if ( isInt ) LibUsb.fillInterruptTransfer(transfers[j], handle, (byte)ep, bufs[j], callback, this, 5000);
		else LibUsb.fillBulkTransfer(transfers[j], handle, (byte)ep, bufs[j], callback, this, 5000);
	    }
	    submit(j);
	}
    }
}
