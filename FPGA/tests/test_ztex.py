#!/usr/bin/python
# -*- coding: utf-8 -*-
################################################################################
#                                test_ztex.py 
#    Top level regresssion tests for ZTEX 1.15y board - Modify Makefile to run 
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

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.result import TestFailure
from cocotb.log import SimLog
from cocotb.wavedrom import Wavedrom
import random
from shutil import copyfile
from python_sha1 import Sha1Model, Sha1Driver
from python_hmac import HmacModel, HmacDriver
from python_prf import PrfModel, PrfDriver

_debug = False


@cocotb.coroutine
def load_data(dut, log, mockObject, words):
    for i in range(words):
        #input = 0xffffffff
        input = random.randint(0, 0xff)
        if mockObject != None:
            mockObject.addByte(input)
        if dut != None:
            dut.read_i <= input
            yield RisingEdge(dut.fxclk_i)
        if _debug == True:
            log.info(str(i) + " - {} - ".format(int(str(dut.pbuffer1.i), 2)) + " {}".format(convert_hex(dut.pbuffer1.test_word_2)) + " {}".format(convert_hex(dut.pbuffer1.test_word_3)))

@cocotb.coroutine
def reset(dut):
    dut.reset_i <= 1
    yield RisingEdge(dut.fxclk_i)
    dut.reset_i <= 0

@cocotb.test()
def A_load_data_test(dut):
    """
    Tests that initial data loads properly
    """
    log = SimLog("cocotb.%s" % dut._name)
    cocotb.fork(Clock(dut.fxclk_i, 10000).start())
    
    objSha = Sha1Model()
    objHmac = HmacModel(objSha)
    objPrf = PrfModel(objHmac)
    
    #pmk = '9051ba43660caec7a909fbbe6b91e4685f1457b5a2e23660d728afbd2c7abfba'
    #apMac = '001dd0f694b0'
    #cMac = '489d2477179a'
    #apNonce = '87f2718bad169e4987c94255395e054bcaf77c8d791698bf03dc85ed3c90832a'
    #cNonce = '143fbb4333341f36e17667f88aa02c5230ab82c508cc4bd5947dd7e50475ad36'
    
    pmk = '01b809f9ab2fb5dc47984f52fb2d112e13d84ccb6b86d4a7193ec5299f851c48'
    apMac = '001e2ae0bdd0'
    cMac = 'cc08e0620bc8'
    apNonce = '61c9a3f5cdcdf5fae5fd760836b8008c863aa2317022c7a202434554fb38452b'
    cNonce = '60eff10088077f8b03a0e2fc2fc37e1fe1f30f9f7cfbcfb2826f26f3379c4318'
    
    ptk = objPrf.PRF(pmk, apMac, cMac, apNonce, cNonce)
    
    print "Goal  : bf49a95f0494f44427162f38696ef8b6"
    print "Result: " + ptk
    
    data = "0103005ffe0109002000000000000000010000000000000000000000000000000000000" + \
        "00000000000000000000000000000000000000000000000000000000000000000000000000" + \
        "00000000000000000000000000000000000000000000000000000"
    

    mic = objPrf.MIC(ptk, data)
    
    print "Goal  : 45282522bc6707d6a70a0317a3ed48f0"
    print "Result: " + mic
    
    yield reset(dut)
    #yield load_data(dut, log, mockSha1, 16)

        
#@cocotb.test()
def Z_wavedrom_test(dut):
    """
    Generate a JSON wavedrom diagram of a trace
    """
    log = SimLog("cocotb.%s" % dut._name)
    cocotb.fork(Clock(dut.fxclk_i, 100).start())

def convert_hex(input):
    input = str(input)
    replaceCount = []
    while 'UUUU' in input: 
        replaceCount.append(input.find('UUUU') / 4)
        input = input.replace('UUUU', '1111', 1)
    
    try:
        output = list("{:x}".format(int(str(input), 2)))
    except:
        output = list("{}".format(str(input)))
    
    
    for x in replaceCount:
        if len(output) > x:
            output[x] = 'U'
        else:
            output.append('U')
        
    return "".join(output)