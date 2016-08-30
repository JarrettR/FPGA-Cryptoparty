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
   Java host software API of ZTEX SDK
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

package ztex;

/** 
  * FX3 error strings
  */
public class Fx3Errors {
    public static String errStr (int err) {
        switch (err) {
	    case   0: return "(No Error)";
	    case   1: return "The OS object being accessed has been deleted";
	    case   2: return "Bad memory pool passed to a function";
	    case   3: return "Bad (NULL or unaligned) pointer passed to a function";
	    case   4: return "Non-zero wait requested from interrupt context";
	    case   5: return "Invalid size value passed into a function";
	    case   6: return "Invalid event group passed into a function";
	    case   7: return "Failed to set/get the event flags specified";
	    case   8: return "Invalid task option value specified for the function";
	    case   9: return "Invalid message queue passed to a function";
	    case  10: return "The message queue being read is empty";
	    case  11: return "The message queue being written to is full";
	    case  12: return "Invalid semaphore pointer passed to a function";
	    case  13: return "A semaphore get operation failed";
	    case  14: return "Invalid thread pointer passed to a function";
	    case  15: return "Invalid thread priority value passed to a function";
	    case  16: return "Failed to allocate memory";
	    case  17: return "Failed to delete an object because it is not idle";
	    case  18: return "Failed to resume a thread";
	    case  19: return "OS function failed because the current caller is not allowed";
	    case  20: return "Failed to suspend a thread";
	    case  21: return "Invalid timer pointer passed to a function";
	    case  22: return "Invalid (0) tick value passed to a timer function";
	    case  23: return "Failed to activate a timer";
	    case  24: return "Invalid thread pre-emption threshold value specified";
	    case  25: return "Thread suspension was cancelled";
	    case  26: return "Wait operation was aborted";
	    case  27: return "Failed to abort wait operation on a thread";
	    case  28: return "Invalid Mutex pointer passed to a function";
	    case  29: return "Failed to get a mutex";
	    case  30: return "Failed to put a mutex because it is not currently owned";
	    case  31: return "Error in priority inheritance";
	    case  32: return "Operation failed because relevant object is not idle or done";
	    case  64: return "One or more parameters to a function are invalid";
	    case  65: return "A null pointer has been passed in unexpectedly";
	    case  66: return "The object/module being referred to has not been started";
	    case  67: return "An object/module that is already active is being started";
	    case  68: return "Object/module referred to has not been configured";
	    case  69: return "Timeout on relevant operation";
	    case  70: return "Operation requested is not supported in current mode";
	    case  71: return "Invalid function call sequence";
	    case  72: return "Function call failed as it was aborted by another thread/isr";
	    case  73: return "DMA engine failed to completed requested operation";
	    case  74: return "Failure due to a non-specific system error";
	    case  75: return "Bad index value was passed in as parameter. Ex: for string descriptor";
	    case  76: return "Bad enumeration method specified";
	    case  77: return "Invalid configuration specified";
	    case  78: return "Internal DMA channel creation failed";
	    case  79: return "Internal DMA channel destroy failed";
	    case  80: return "Invalid descriptor type specified";
	    case  81: return "USB transfer was cancelled";
	    case  82: return "When a USB feature like remote wakeup is not enabled";
	    case  83: return "When a USB request / data transfer is stalled";
	    case  84: return "The block accessed has a fatal error and needs to be re-initialized";
	    case  85: return "Loss of bus arbitration, invalid bus behaviour or bus busy";
	    case  86: return "Failed to enter standby mode because one or more wakeup events are active";
	    case  96: return "Storage device's voltage range does not meet FX3S requirements";
	    case  97: return "Incorrect response received from storage device";
	    case  98: return "Storage device features are not supported by FX3S host";
	    case  99: return "Storage device failed to move to expected state";
	    case 100: return "Storage device failed to support required commands";
	    case 101: return "Response CRC error detected";
	    case 102: return "Out of range address provided for read/write/erase access";
	    case 103: return "Non-existent storage partition selected for transfer";
	    case 104: return "Access to port with no connected storage device";
	    case 105: return "Request to partition a device which is already partitioned";
	    case 106: return "Request to remove partitions on an unpartitioned device";
	    case 107: return "Incorrect partition selected";
	    case 108: return "Read/write transfer was aborted (user cancellation or timeout)";
	    case 109: return "Write request addressed to a write protected storage device";
	    case 110: return "Storage driver initialization failed";
	    case 111: return "Access to password locked SD card";
	    case 112: return "Failure while locking/unlocking the SD card";
	    case 113: return "Failure during SD force erase operation";
	    case 114: return "Block size specified for SDIO device is not supported";
	    case 115: return "Non-existent SDIO function being accessed";
	    case 116: return "Non-existent tuple of SDIO card being accessed";
	    case 117: return "IO operation to SDIO card aborted";
	    case 118: return "IO operation to SDIO card suspended";
	    case 119: return "Invalid command sent to the SDIO card";
	    case 120: return "Generic error reported by SDIO card";
	    case 121: return "SDIO command argument is out of range";
	    case 122: return "Access to uninitialized SDIO function";
	    case 123: return "Access to SDIO card which is not active";
	    case 124: return "The storage device is busy handling another request";
	    case 125: return "No metadata present on card";
	    case 126: return "Card RD/WR Threshold error crossed";
	    case 127: return "Card not responding to read/write transactions";
	}
	return "(Unknown Error)";
    }
}    

