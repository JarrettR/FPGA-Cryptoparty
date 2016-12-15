#!/usr/bin/python
# -*- coding: utf-8 -*-
################################################################################
#                                test_gentenhex.py 
#    Tests for the master key generation module - Modify Makefile to run 
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

import binstr

_debug = False

@cocotb.coroutine
def reset(dut):
    yield RisingEdge(dut.clk_i)
    dut.rst_i <= 0

@cocotb.coroutine
def wait_process(dut):
    while True:
        #print_mk(dut) 
        yield RisingEdge(dut.clk_i)
        
        if int(str(dut.complete_o), 2) == 1:
            break
            
    
def print_mk(dut):
    print chr(int(str(dut.test_mk_val0), 2)) + \
        chr(int(str(dut.test_mk_val1), 2)) + \
        chr(int(str(dut.test_mk_val2), 2)) + \
        chr(int(str(dut.test_mk_val3), 2)) + \
        chr(int(str(dut.test_mk_val4), 2)) + \
        chr(int(str(dut.test_mk_val5), 2)) + \
        chr(int(str(dut.test_mk_val6), 2)) + \
        chr(int(str(dut.test_mk_val7), 2)) + \
        chr(int(str(dut.test_mk_val8), 2)) + \
        chr(int(str(dut.test_mk_val9), 2))
    print dut.complete_o #dut.carry#, dut.continue
        
@cocotb.test()
def A_load_config_test(dut):
    """
    Test correct start/end parameters get loaded into DUT
    """
    log = SimLog("cocotb.%s" % dut._name)
    #log.setLevel(logging.DEBUG)
    cocotb.fork(Clock(dut.clk_i, 1000).start())
    
    mk_start = '1222222222'
    mk_end = '1222222f22'
    
    #Todo: fix this garbage when GHDL implements arrays in their VPI
    dut.test_start_val0 <= ord(mk_start[0])
    dut.test_start_val1 <= ord(mk_start[1])
    dut.test_start_val2 <= ord(mk_start[2])
    dut.test_start_val3 <= ord(mk_start[3])
    dut.test_start_val4 <= ord(mk_start[4])
    dut.test_start_val5 <= ord(mk_start[5])
    dut.test_start_val6 <= ord(mk_start[6])
    dut.test_start_val7 <= ord(mk_start[7])
    dut.test_start_val8 <= ord(mk_start[8])
    dut.test_start_val9 <= ord(mk_start[9])
    
    dut.test_end_val0 <= ord(mk_end[0])
    dut.test_end_val1 <= ord(mk_end[1])
    dut.test_end_val2 <= ord(mk_end[2])
    dut.test_end_val3 <= ord(mk_end[3])
    dut.test_end_val4 <= ord(mk_end[4])
    dut.test_end_val5 <= ord(mk_end[5])
    dut.test_end_val6 <= ord(mk_end[6])
    dut.test_end_val7 <= ord(mk_end[7])
    dut.test_end_val8 <= ord(mk_end[8])
    dut.test_end_val9 <= ord(mk_end[9])
    
    dut.init_load_i <= 1
    yield RisingEdge(dut.clk_i)
    dut.rst_i <= 1
    
    yield RisingEdge(dut.clk_i)
    dut.rst_i <= 0
    yield RisingEdge(dut.clk_i)
    dut.init_load_i <= 0
    
    yield wait_process(dut)
    #print_mk(dut) 
    
    if mk_end[1] != chr(int(str(dut.test_mk_val1), 2)):
        raise TestFailure("MK Final Value 1 Mismatch")
    if mk_end[3] != chr(int(str(dut.test_mk_val3), 2)):
        raise TestFailure("MK Final Value 3 Mismatch")
    if mk_end[7] != chr(int(str(dut.test_mk_val7), 2)):
        raise TestFailure("MK Final Value 7 Mismatch")
    if mk_end[9] != chr(int(str(dut.test_mk_val9), 2)):
        raise TestFailure("MK Final Value 9 Mismatch")
    else:
        log.info("MK Generation Ok!")

        
@cocotb.test()
def B_load_second_test(dut):
    """
    Test proper reset procedure
    """
    log = SimLog("cocotb.%s" % dut._name)
    #log.setLevel(logging.DEBUG)
    cocotb.fork(Clock(dut.clk_i, 1000).start())
    
    mk_start = '1022222222'
    mk_end = '10222222f2'
    
    #Todo: fix this garbage when GHDL implements arrays in their VPI
    dut.test_start_val0 <= ord(mk_start[0])
    dut.test_start_val1 <= ord(mk_start[1])
    dut.test_start_val2 <= ord(mk_start[2])
    dut.test_start_val3 <= ord(mk_start[3])
    dut.test_start_val4 <= ord(mk_start[4])
    dut.test_start_val5 <= ord(mk_start[5])
    dut.test_start_val6 <= ord(mk_start[6])
    dut.test_start_val7 <= ord(mk_start[7])
    dut.test_start_val8 <= ord(mk_start[8])
    dut.test_start_val9 <= ord(mk_start[9])
    
    dut.test_end_val0 <= ord(mk_end[0])
    dut.test_end_val1 <= ord(mk_end[1])
    dut.test_end_val2 <= ord(mk_end[2])
    dut.test_end_val3 <= ord(mk_end[3])
    dut.test_end_val4 <= ord(mk_end[4])
    dut.test_end_val5 <= ord(mk_end[5])
    dut.test_end_val6 <= ord(mk_end[6])
    dut.test_end_val7 <= ord(mk_end[7])
    dut.test_end_val8 <= ord(mk_end[8])
    dut.test_end_val9 <= ord(mk_end[9])
    
    dut.init_load_i <= 1
    yield RisingEdge(dut.clk_i)
    dut.rst_i <= 1
    
    yield RisingEdge(dut.clk_i)
    dut.rst_i <= 0
    yield RisingEdge(dut.clk_i)
    dut.init_load_i <= 0
    
    yield wait_process(dut)
    #print_mk(dut) 
    
    if mk_end[1] != chr(int(str(dut.test_mk_val1), 2)):
        raise TestFailure("MK Final Value 1 Mismatch")
    if mk_end[3] != chr(int(str(dut.test_mk_val3), 2)):
        raise TestFailure("MK Final Value 3 Mismatch")
    if mk_end[7] != chr(int(str(dut.test_mk_val7), 2)):
        raise TestFailure("MK Final Value 7 Mismatch")
    if mk_end[9] != chr(int(str(dut.test_mk_val9), 2)):
        raise TestFailure("MK Final Value 9 Mismatch")
    else:
        log.info("MK Generation Ok!")
