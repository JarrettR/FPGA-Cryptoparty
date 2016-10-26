#!/usr/bin/python
# -*- coding: utf-8 -*-
################################################################################
#                              python_ztex.py 
#    Top-level simulation of complete ZTEX 1.15y board
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

from python_sha1 import Sha1Model
from python_hmac import HmacModel

import cocotb
from cocotb.decorators import coroutine
from cocotb.triggers import RisingEdge, ReadOnly, NextTimeStep, Event
from cocotb.drivers import BusDriver, ValidatedBusDriver
from cocotb.utils import hexdump
from cocotb.binary import BinaryValue
from cocotb.result import ReturnValue, TestError

class ZtexDriver(BusDriver):
    """
    ZTEX Driver
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
        
        
class ZtexModel(object):
    
    def __init__(self, HmacObj, Sha1Obj):
        self.Hmac = HmacObj
        self.Sha1 = Sha1Obj
        self.reset()
        
        
    def reset(self):
        #pmk = '9051ba43660caec7a909fbbe6b91e4685f1457b5a2e23660d728afbd2c7abfba'
        #apMac = '001dd0f694b0'
        #cMac = '489d2477179a'
        #apNonce = '87f2718bad169e4987c94255395e054bcaf77c8d791698bf03dc85ed3c90832a'
        #cNonce = '143fbb4333341f36e17667f88aa02c5230ab82c508cc4bd5947dd7e50475ad36'
        self.ssid = 'testSSID'
        self.pmk = '01b809f9ab2fb5dc47984f52fb2d112e13d84ccb6b86d4a7193ec5299f851c48'
        self.apMac = '001e2ae0bdd0'
        self.cMac = 'cc08e0620bc8'
        self.apNonce = '61c9a3f5cdcdf5fae5fd760836b8008c863aa2317022c7a202434554fb38452b'
        self.cNonce = '60eff10088077f8b03a0e2fc2fc37e1fe1f30f9f7cfbcfb2826f26f3379c4318'
        
        #ptk = objPrf.PRF(pmk, apMac, cMac, apNonce, cNonce)
        goal = "bf49a95f0494f44427162f38696ef8b6"
        #print "Result: " + ptk
        
        self.data = "0103005ffe0109002000000000000000010000000000000000000000000000000000000" + \
            "00000000000000000000000000000000000000000000000000000000000000000000000000" + \
            "00000000000000000000000000000000000000000000000000000"

        #mic = objPrf.MIC(ptk, data)
        
        self.mkStart = "0000000000"
        self.mkEnd = "FFFFFFFFF"
        self.goal = "45282522bc6707d6a70a0317a3ed48f0"
        
    def genPacket(self):
        packet = ''
        
        packet = packet + '{}'.format(self.ssid)
        packet = packet + '{}'.format(self.data)
        packet = packet + '{}'.format(self.apNonce)
        packet = packet + '{}'.format(self.cNonce)
        packet = packet + '{}'.format(self.apMac)
        packet = packet + '{}'.format(self.cMac)
        packet = packet + '{}'.format(self.mkStart)
        packet = packet + '{}'.format(self.mkEnd)
        packet = packet + '{}'.format(self.goal)
        
        return packet
        
    def addByte(self, input):
        self.shiftMessage()
        self.message[0] = input
        self.messageLength = self.messageLength + 1
        
    def shiftMessage(self):
        for x in range(63, 1, -1):
            self.message[x] = self.message[x - 1]

    def load(self, secret, value):
        self.addSecret(secret)
        
        shaBi = self.Sha1.hashString(self.generateString(self.Bi) + value)
        shaBiDec = shaBi.decode("hex")
        
        Bo = self.generateString(self.Bo) + shaBiDec
        self.shaBo = self.Sha1.hashString(Bo)
        
        return self.shaBo


if __name__ == "__main__":
    objSha = Sha1Model()
    objHmac = HmacModel(objSha)
    
    print "What"
    