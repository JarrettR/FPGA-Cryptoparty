import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.result import TestFailure
from cocotb.log import SimLog
from cocotb.wavedrom import Wavedrom
import random
from shutil import copyfile
from python_sha1 import Sha1Model, Sha1Driver

_debug = True

@cocotb.coroutine
def load_data(dut, log, mockObject, words):
    for i in range(words):
        #input = 0xffffffff
        input = random.randint(0, 0xffffffff)
        mockObject.addWord(input)
        dut.dat_i <= input
        yield RisingEdge(dut.clk_i)
        if _debug == True:
            log.info(str(i) + " - {} - ".format(int(str(dut.pbuffer1.i), 2)) + " {}".format(convert_hex(dut.pbuffer1.test_word_2)) + " {}".format(convert_hex(dut.pbuffer1.test_word_3)))

        
@cocotb.coroutine
def reset(dut):
    dut.rst_i <= 1
    yield RisingEdge(dut.clk_i)
    dut.rst_i <= 0
    #yield RisingEdge(dut.clk_i)
    #log.info("Reset!")

@cocotb.test()
def A_load_data_test(dut):
    """
    Test for data properly shifted in
    w(0) gets loaded in LAST
    """
    log = SimLog("cocotb.%s" % dut._name)
    cocotb.fork(Clock(dut.clk_i, 10000).start())
    
    mockObject = Sha1Model()
    
    yield reset(dut)
    yield load_data(dut, log, mockObject, 16)

    #mockObject.displayAll()
    mockOut = "{:08x}".format(mockObject.W[15])

    #print convert_hex(dut.dat_1_o) + " " + convert_hex(dut.dat_2_o) + " " + convert_hex(dut.dat_3_o) + " " + convert_hex(dut.dat_4_o) + " " + convert_hex(dut.dat_5_o)

    if convert_hex(dut.test_sha1_load_o).zfill(8) != mockOut:
        raise TestFailure(
            "Load data is incorrect: {0} != {1}".format(convert_hex(dut.test_sha1_load_o), mockOut))
    else:
        log.info("Ok!")
        
        
@cocotb.test()
def B_reset_test(dut):
    """Testing synchronous reset"""
    log = SimLog("cocotb.%s" % dut._name)
    cocotb.fork(Clock(dut.clk_i, 10000).start())
    
    mockObject = Sha1Model()
    
    yield reset(dut)
    yield RisingEdge(dut.clk_i)
    
    if dut.i.value != 0:
        raise TestFailure(
            "Reset 1 failed!")
    yield load_data(dut, log, mockObject, 18)
    if convert_hex(dut.dat_1_o) == '0':
        raise TestFailure(
            "Data not populated!")
    else:
        log.info("Testing reset")
    yield reset(dut)
    yield RisingEdge(dut.clk_i)
    
    if dut.i.value != 0:
        raise TestFailure(
            "Reset 2 failed!")
    else:
        log.info("Reset Ok!")
    yield load_data(dut, log, mockObject, 19)

    mockOut = "{:08x}".format(mockObject.W[15])

    if convert_hex(dut.test_sha1_load_o).zfill(8) != mockOut:
        raise TestFailure(
            "Reload is incorrect: {0} != {1}".format(convert_hex(dut.test_sha1_load_o), mockOut))
    else:
        log.info("Ok!")
        
        

        
        
@cocotb.test()
def Z_wavedrom_test(dut):
    """
    Generate a JSON wavedrom diagram of a trace
    """
    log = SimLog("cocotb.%s" % dut._name)
    cocotb.fork(Clock(dut.clk_i, 100).start())
    
    mockObject = Sha1Model()
    shaObject = Sha1Driver(dut, None, dut.clk_i)
    
    #yield load_data(dut, log, mockObject, 80)
    
    
    args = [
            dut.rst_i,
            dut.dat_i,
            dut.i,
            dut.i_mux,
            dut.pinput1.i,
            dut.pinput1.load_i,
            dut.pinput1.test_word_1,
            dut.pinput1.test_word_2,
            dut.pinput1.test_word_3,
            dut.pinput1.test_word_4,
            dut.pinput1.test_word_5,
            dut.pinput1.valid_o,
            dut.pbuffer1.i,
            dut.pbuffer1.rst_i,
            dut.pbuffer1.load_i,
            dut.pbuffer1.new_i,
            dut.pbuffer1.test_word_1,
            dut.pbuffer1.test_word_2,
            dut.pbuffer1.test_word_3,
            dut.pbuffer1.test_word_4,
            dut.pbuffer1.test_word_5,
            dut.pbuffer1.valid_o
            ]

    with cocotb.wavedrom.trace(*args, clk=dut.clk_i) as waves:
    
        yield RisingEdge(dut.clk_i)
        yield reset(dut)
        yield load_data(dut, log, mockObject, 16)
        mockObject.processInput()
        mockObject.processBuffer()
        
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
            #log.info(dut.pinput1.test_word_1.value.hex())
            #log.info(dut.pinput1.test_word_2.value.hex())
            #log.info(dut.pinput1.test_word_3.value.hex())
            #log.info(dut.pinput1.test_word_4.value.hex())
            #log.info(dut.pinput1.test_word_5.value.hex())
            #log.info(dut.pinput1.test_word_5)
            #log.info(waves.dumpj(header = {'text':'D_wavedrom_test', 'tick':-2}, config = {'hscale':3}))
            
        waves.write('wavedrom.json', header = {'text':'D_wavedrom_test', 'tick':-1}, config = {'hscale':5})
        

        
@cocotb.test()
def D_process_first_input_test(dut):
    """Test input data properly processed during first stage"""
    log = SimLog("cocotb.%s" % dut._name)
    cocotb.fork(Clock(dut.clk_i, 10000).start())
    
    mockObject = Sha1Model()

    yield reset(dut)
    #yield load_data(dut, log, mockObject, 16)

    #mockObject.processInput()
    #mockObject.displayAll()
    
    yield load_data(dut, log, mockObject, 16)
    mockObject.processInput()
    yield load_data(dut, log, mockObject, 68)
    
    mockOut = "{:08x}".format(mockObject.W[16])
    
    if convert_hex(dut.pinput1.test_word_1.value) != mockOut:
        raise TestFailure(
            "First load incorrect: {0} != {1}".format(convert_hex(dut.pinput1.test_word_1.value), mockOut))
    elif convert_hex(dut.pinput1.test_word_5.value) != "{:08x}".format(mockObject.W[79]):
        raise TestFailure(
            "First load incorrect: {0} != {1}".format(convert_hex(dut.pinput1.test_word_5.value), "{:08x}".format(mockObject.W[79])))
    else:
        log.info("First load ok!") 

        
@cocotb.test()
def E_process_second_input_test(dut):
    """Test second set of input data processed"""
    log = SimLog("cocotb.%s" % dut._name)
    cocotb.fork(Clock(dut.clk_i, 10000).start())
    
    mockObject = Sha1Model()

    yield reset(dut)
    log.info("Second load not tested!")
        
        
@cocotb.test()
def F_process_first_buffer_test(dut):
    """Test data after processing the first message buffer"""
    log = SimLog("cocotb.%s" % dut._name)
    cocotb.fork(Clock(dut.clk_i, 10000).start())
    
    mockObject = Sha1Model()

    yield reset(dut)
    #yield load_data(dut, log, mockObject, 16)

    #mockObject.processInput()
    #mockObject.displayAll()
    
    yield load_data(dut, log, mockObject, 16)
    mockObject.processInput()
    mockObject.processBuffer()
    yield load_data(dut, log, mockObject, 68)
    
    mockOut = "{:08x}".format(mockObject.H0)
    
    if convert_hex(dut.pbuffer1.test_word_4.value) != mockOut:
        raise TestFailure(
            "First buffer incorrect: {0} != {1}".format(convert_hex(dut.pinput1.test_word_4.value), mockOut))
    else:
        log.info("First buffer ok!") 
        
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