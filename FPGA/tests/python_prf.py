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
import hmac
import random
from binascii import a2b_hex, b2a_hex 
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
        
    def PRF(self, pmk, apMac, cMac, apNonce, cNonce):
        
        b = min(apMac, cMac) + max(apMac, cMac) + min(apNonce, cNonce) + max(apNonce, cNonce)
        print b
        r = ""
        
        #Note: The spec says to loop this waaaay too many times and then truncate output
        for x in xrange(4):
            r = r + self.objHmac.load(self.toAscii(pmk), self.a + self.toAscii("00" + b + "{:02x}".format(x)))
            print r
        
        out = r
        return out[0:32]

    def MIC(self, ptk, data):
        ptk = self.toAscii(ptk)
        data = self.toAscii(data)
        
        #Todo: investigate why my function breaks here (data length?)
        out = hmac.new(ptk[0:16],data).hexdigest()       
        
        return out[0:32]

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
    
    pmk = '9051ba43660caec7a909fbbe6b91e4685f1457b5a2e23660d728afbd2c7abfba'
    apMac = '001dd0f694b0'
    cMac = '489d2477179a'
    apNonce = '87f2718bad169e4987c94255395e054bcaf77c8d791698bf03dc85ed3c90832a'
    cNonce = '143fbb4333341f36e17667f88aa02c5230ab82c508cc4bd5947dd7e50475ad36'
    
    ptk = '489d2477179a'
    
    print "Result: " + objPrf.PRF(pmk, apMac, cMac, apNonce, cNonce)
    print "Goal:   " + ptk
    
    pmk = '01b809f9ab2fb5dc47984f52fb2d112e13d84ccb6b86d4a7193ec5299f851c48'
    apMac = '001e2ae0bdd0'
    cMac = 'cc08e0620bc8'
    apNonce = '61c9a3f5cdcdf5fae5fd760836b8008c863aa2317022c7a202434554fb38452b'
    cNonce = '60eff10088077f8b03a0e2fc2fc37e1fe1f30f9f7cfbcfb2826f26f3379c4318'
    
    ptk = 'bf49a95f0494f44427162f38696ef8b6'
    
    print "Result: " + objPrf.PRF(pmk, apMac, cMac, apNonce, cNonce)
    print "Goal:   " + ptk
    