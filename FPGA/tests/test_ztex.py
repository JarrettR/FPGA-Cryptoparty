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
import logging
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.result import TestFailure
from cocotb.log import SimLog
from cocotb.wavedrom import Wavedrom
import random
from shutil import copyfile
import wpa2slow
from wpa2slow.handshake import Handshake
from wpa2slow.sha1 import Sha1Model #, Sha1Driver
from wpa2slow.hmac import HmacModel #, HmacDriver
from wpa2slow.compare import PrfModel #, PrfDriver
from python_ztex import ZtexModel, ZtexDriver

import binstr

_debug = False

@cocotb.coroutine
def reset(dut):
    dut.rst_i <= 1
    yield RisingEdge(dut.clk_i)
    dut.rst_i <= 0

@cocotb.coroutine
def preamble(dut, data, length):
    #Todo: setup file loading, handshake objects, etc
    for x in xrange(length):
        dut.dat_i <= data[x]
        yield RisingEdge(dut.clk_i)

@cocotb.coroutine
def load_data(dut, data, length):
    for x in xrange(length):
        dut.dat_i <= data[x]
        yield RisingEdge(dut.clk_i)

@cocotb.coroutine
def load_file(dut, filename):
    f = open(filename, 'rb')
    
    while f:
        fbyte = f.read(1)
        
        if not fbyte:
            break
            
        #print fbyte
        #print "{:02x}".format(ord(fbyte))
        dut.dat_i <= ord(fbyte)
        yield RisingEdge(dut.clk_i)
        dat_i_test = dut.test_byte_1
    
        #print dat_i_test
        
    f.close()

#@cocotb.test()
def A_load_packet_test(dut):
    """
    Test proper load of filedata into DUT
    """
    log = SimLog("cocotb.%s" % dut._name)
    log.setLevel(logging.DEBUG)
    cocotb.fork(Clock(dut.clk_i, 1000).start())
    
    filename = '../test_data/wpa2-psk-linksys.hccap'
    
    obj = wpa2slow.handshake.Handshake()
    objSha = wpa2slow.sha1.Sha1Model()
    objHmac = wpa2slow.hmac.HmacModel(objSha)
    objPbkdf2 = wpa2slow.pbkdf2.Pbkdf2Model()
    objPrf = wpa2slow.compare.PrfModel(objHmac)
    
    (ssid, mac1, mac2, nonce1, nonce2, eapol, eapol_size, keymic) = obj.load(filename)
    
    dut.cs_i <= 1
    yield reset(dut)
    yield RisingEdge(dut.clk_i)
    
    yield load_file(dut, filename)
    
    packet_test1 = dut.test_ssid_1
    packet_test2 = dut.test_ssid_2
    packet_test3 = dut.test_ssid_3
    
    if ord(ssid[0][0]) != int(str(ssid_test1), 2):
        raise TestFailure("ssid_test1 differs from mock")
    elif ord(ssid[0][3]) != int(str(ssid_test2), 2):
        raise TestFailure("ssid_test2 differs from mock")
    elif ord(ssid[0][6]) != int(str(ssid_test3), 2):
        raise TestFailure("ssid_test3 differs from mock")
    elif ord(ssid[0][6]) == int(str(ssid_test1), 2):    #Todo: remove false positive if 1st and 7th chars equal
        raise TestFailure("SSID comparisons failing.")
    else:
        log.info("SSID Ok!")
    
@cocotb.test()
def B_load_ssid_test(dut):
    """
    Test correct SSID gets loaded into DUT
    """
    log = SimLog("cocotb.%s" % dut._name)
    log.setLevel(logging.DEBUG)
    cocotb.fork(Clock(dut.clk_i, 1000).start())
    
    filename = '../test_data/wpa2-psk-linksys.hccap'
    
    obj = wpa2slow.handshake.Handshake()
    objSha = wpa2slow.sha1.Sha1Model()
    objHmac = wpa2slow.hmac.HmacModel(objSha)
    objPbkdf2 = wpa2slow.pbkdf2.Pbkdf2Model()
    objPrf = wpa2slow.compare.PrfModel(objHmac)
    
    (ssid, mac1, mac2, nonce1, nonce2, eapol, eapol_size, keymic) = obj.load(filename)
    
    dut.cs_i <= 1
    yield reset(dut)
    yield RisingEdge(dut.clk_i)
    
    yield load_file(dut, filename)
    
    ssid_test1 = dut.test_ssid_1
    ssid_test2 = dut.test_ssid_2
    ssid_test3 = dut.test_ssid_3
    
    if ord(ssid[0][0]) != int(str(ssid_test1), 2):
        raise TestFailure("ssid_test1 differs from mock")
    elif ord(ssid[0][3]) != int(str(ssid_test2), 2):
        raise TestFailure("ssid_test2 differs from mock")
    elif ord(ssid[0][6]) != int(str(ssid_test3), 2):
        raise TestFailure("ssid_test3 differs from mock")
    elif ord(ssid[0][6]) == int(str(ssid_test1), 2):    #Todo: remove false positive if 1st and 7th chars equal
        raise TestFailure("SSID comparisons failing.")
    else:
        log.info("SSID Ok!")
        
    mac_test1 = dut.test_mac_1
    mac_test2 = dut.test_mac_2
    mac_test3 = dut.test_mac_3
        
    if ord(mac1[0][0]) != int(str(mac_test1), 2):
        raise TestFailure("mac_test1 differs from mock")
    elif ord(mac1[0][3]) != int(str(mac_test2), 2):
        raise TestFailure("mac_test2 differs from mock")
    elif ord(mac2[0][5]) != int(str(mac_test3), 2):
        raise TestFailure("mac_test3 differs from mock")
    elif ord(mac1[0][5]) == int(str(mac_test1), 2):    #Todo: remove false positive
        raise TestFailure("MAC comparisons failing.")
    else:
        log.info("MAC Ok!")
        
    nonce_test1 = dut.test_nonce_1
    nonce_test2 = dut.test_nonce_2
    nonce_test3 = dut.test_nonce_3
        
    if ord(nonce1[0][0]) != int(str(nonce_test1), 2):
        raise TestFailure("nonce_test1 differs from mock")
    elif ord(nonce1[0][3]) != int(str(nonce_test2), 2):
        raise TestFailure("nonce_test2 differs from mock")
    elif ord(nonce2[0][6]) != int(str(nonce_test3), 2):
        raise TestFailure("nonce_test3 differs from mock")
    elif ord(nonce1[0][5]) == int(str(nonce_test1), 2):    #Todo: remove false positive
        raise TestFailure("nonce comparisons failing.")
    else:
        log.info("Nonce Ok!")

        
@cocotb.test()
def C_load_data_test(dut):
    """
    Fills up all required values from packet
    """
    log = SimLog("cocotb.%s" % dut._name)
    cocotb.fork(Clock(dut.clk_i, 1000).start())
    
    outStr = ''
    
    yield reset(dut)
    yield RisingEdge(dut.clk_i)
        
        
    if outStr == "00000000fe":
        raise TestFailure("Wrong loaded values!")
    else:
        log.info("Ok!")

#@cocotb.test()
def Z_wavedrom_test(dut):
    """
    Generate a JSON wavedrom diagram of a trace
    """
    log = SimLog("cocotb.%s" % dut._name)
    cocotb.fork(Clock(dut.clk_i, 1000).start())
    
    mockObject = ZtexModel()
    #shaObject = Sha1Driver(dut, None, dut.clk_i)
    
    #yield load_data(dut, log, mockObject, 80)
    
    
    args = [
            dut.rst_i,
            dut.cs_i,
            dut.cont_i,
            dut.clk_i,
            dut.din_i,
            dut.dout_i,
            dut.SLOE,
            dut.SLRD,
            dut.SLWR,
            dut.FIFOADR0,
            dut.FIFOADR1,
            dut.PKTEND,
            dut.FLAGA,
            dut.FLAGB
            ]

    with cocotb.wavedrom.trace(*args, clk=dut.clk_i) as waves:
    
        yield RisingEdge(dut.clk_i)
        yield reset(dut)
        
        yield load_data(dut, log, mockObject, 16)
        
        if _debug == True:
            log.info(convert_hex(dut.pbuffer1.test_word_3).zfill(8))
        yield load_data(dut, log, mockObject, 60)
        
        
            
        if _debug == True:
            log.info(convert_hex(dut.pbuffer1.test_word_3).zfill(8))
            #log.info("{:08x}".format(mockObject.W[78]))
            #log.info("{:08x}".format(mockObject.W[79]))
            #log.info("{:08x}".format(mockObject.W[16 - 14]))
            #log.info("{:08x}".format(mockObject.W[16 - 16]))
            #log.info("{:08x}".format(mockObject.W[16]))
            
        yield load_data(dut, log, mockObject, 90)
        
        if _debug == True:
            log.info(convert_hex(dut.pbuffer1.test_word_3).zfill(8))
            log.info(convert_hex(dut.pbuffer1.test_word_4).zfill(8))
            #log.info(dut.pinput1.test_word_1.value.hex())
            #log.info(dut.pinput1.test_word_2.value.hex())
            #log.info(dut.pinput1.test_word_3.value.hex())
            #log.info(dut.pinput1.test_word_4.value.hex())
            #log.info(dut.pinput1.test_word_5.value.hex())
            #log.info(dut.pinput1.test_word_5)
            #log.info(waves.dumpj(header = {'text':'D_wavedrom_test', 'tick':-2}, config = {'hscale':3}))
            
        waves.write('wavedrom.json', header = {'text':'D_wavedrom_test', 'tick':-1}, config = {'hscale':5})
        

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