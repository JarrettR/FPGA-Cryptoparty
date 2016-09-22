#!/usr/bin/python
# -*- coding: utf-8 -*-
################################################################################
#                            python_prf.py 
#    WPA2 Pseudo Random Function mock object
#    Copyright (C) 2016  Jarrett Rainier
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
################################################################################
import hashlib #For testing mock objects
import random
from python_sha1 import Sha1Model
from python_hmac import HmacModel

import cocotb
from cocotb.decorators import coroutine
from cocotb.triggers import RisingEdge, ReadOnly, NextTimeStep, Event
from cocotb.drivers import BusDriver, ValidatedBusDriver
from cocotb.utils import hexdump
from cocotb.binary import BinaryValue
from cocotb.result import ReturnValue, TestError


class PrfDriver(BusDriver):
    """
    WPA2 PRF Driver
    """
    _signals = ["dat_i", "load_i", "rst_i"]
    _optional_signals = []

    def __init__(self, entity, name, clock):
        BusDriver.__init__(self, entity, name, clock)
        
        word   = BinaryValue(bits=32)
        single = BinaryValue(bits=1)

        word.binstr   = ("x" * 32)
        single.binstr = ("x")

        self.bus.load_i <= single
        self.bus.rst_i <= single
        self.bus.dat_i <= word


class PrfModel(object):

    def __init__(self, objHmac):
        self.objHmac = objHmac
        self.a = "Pairwise key expansion"
        self.reset()
        
    def reset(self):
        self.b = ''
        
    def run(self, pmk, apMac, cMac, apNonce, cNonce):
        
        b = min(apMac, cMac) + max(apMac, cMac) + min(apNonce, cNonce) + max(apNonce, cNonce)
        
        r = ""
        
        for x in xrange(3):
            r = r + self.objHmac.run(pmk, self.a + "\0" + b + chr(x))
        
        out = r
        return out[0:64]
        

    def hmac_sha1(self, in1, in2):
        i = 0
        out = ''
        
        x1 = in1
        x2 = in2
        for x in xrange(len(x1)):
            what = chr(ord(x1[x]) ^ ord(x2[x]))
            out += what
            
        return out
        
    def toAscii(self, input):
        str = ''
        #print input
        while len(input) > 0:
            #print input[-2:]
            str = chr(int(input[-2:], 16)) + str
            input = input[0:-2]
        return str
        
    def toHexString(self, input):
        str = ''
        #print input
        for x in xrange(len(input)):
            #print input[-2:]
            str += "{:02x}".format(ord(input[x]))
        return str

if __name__ == "__main__":
    objSha = Sha1Model()
    objHmac = HmacModel(objSha)
    objPrf = PrfModel(objHmac)
    
    pmk = ''
    apMac = ''
    cMac = ''
    apNonce = ''
    cNonce = ''
    
    print objPrf.run(pmk, apMac, cMac, apNonce, cNonce)
    