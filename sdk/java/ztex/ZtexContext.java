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
  * This class manages an USB context. 
  * Because libusb_get_device_list does not return an up to date device list at least on some implementations
  * a new context must be created every time the bus is (re)discovered, i.e. every time re-numeration occurs.
  * This class creates a new USB context, initializes it and deinitializes it as soon it is not used anymore.
  * Used is tracked using a reference counter. Reference counter of a new instance is 1.
*/

public class ZtexContext {
    private int refCount = 0;
    private Context context;
    
/**
  * Constructs an new USB context and initializes it.
  */
    public ZtexContext () throws UsbException {
	context = new Context();
        refCount = 0;
        ref();
    }        

/** 
  * Returns the USB context.
  * @return the USB context.
  */
    public final Context context() {
	return context;
    }

/**
  * Increases the reference count.
  * @return the USB context.
  */
    public synchronized ZtexContext ref() throws UsbException {
	refCount ++;
	if ( refCount == 1 ) {
    	    int result = LibUsb.init(context);
    	    if (result < 0 ) throw new UsbException("Unable to initialize usb context", result);
//	    System.out.println("created ZtexContext: " + context);
	}
	return this;
    }

/**
  * Decreases the reference count and deinitializes the context if reference counter reaches 0.
  */
    public synchronized void unref() {
	refCount --;
	if ( refCount == 0 ) {
//	    System.out.println("disposing ZtexContext: " + context);
	    LibUsb.exit(context);
	}
    }

    protected void finalize() throws Throwable {
	if (refCount > 0) refCount=1;
	unref();
        super.finalize();
    }
}
