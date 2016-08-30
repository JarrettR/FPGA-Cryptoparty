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
    Event handler for asynchronous mode.
*/
package ztex;

import java.io.*;
import java.util.*;

import org.usb4java.*;

/**
  * This class defines an event handler thread which can be used in asynchronous mode. 
  */

// *****************************************************************************
// ******* ZtexEventHandler ****************************************************
// *****************************************************************************
public class ZtexEventHandler extends Thread {
    private volatile boolean terminate;
    private volatile boolean isAlive;
    private Context context;
    
/**
  * Creates the event handler for a given USB context.
  * @param p_context The USB context
  */
    public ZtexEventHandler ( Context p_context ) {
        super ();
        context = p_context;
        isAlive = false;
    }

/**
  * Creates the event handler for a given ZTEX device.
  * @param ztex The ZTEX device
  */
    public ZtexEventHandler ( Ztex1 ztex ) {
        super ();
        context = ztex.dev().context().context();
        isAlive = false;
    }

/**
  * Stops the event handler. This call waits up to 1.5s
  * @return true if the event handler terminated correctly.
  */
    public boolean terminate() {
        terminate = true;
	for (int i=0; isAlive && i<=1500; i+=20 ) {
	    try { sleep(20); } catch ( InterruptedException e) { } 
	}
	return !isAlive;
    }

/**
  * The thread body.
  */
    public void run() {
	isAlive = true;
	terminate = false;
        while ( ! terminate ) {
            int result = LibUsb.handleEventsTimeoutCompleted (context, 500, null);
            if ( (result!=LibUsb.SUCCESS) ) System.err.println("Event handler: "+LibUsb.strError(result));
        }
	isAlive = false;
    }
}
