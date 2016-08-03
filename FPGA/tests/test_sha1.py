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
            log.info(str(i) + " - " + "{} - ".format(dut.pinput1.i.value.hex()) + " {:08x} - ".format(input) + convert_hex(dut.dat_i) + " - " + convert_hex(dut.pinput1.test_word_5))

        
@cocotb.coroutine
def reset(dut):
    dut.rst_i <= 1
    yield RisingEdge(dut.clk_i)
    dut.rst_i <= 0
    yield RisingEdge(dut.clk_i)
    #log.info("Reset!")

@cocotb.test()
def A_load_data_test(dut):
    """Test for data properly shifted in"""
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
            "Adder result is incorrect: {0} != {1}".format(convert_hex(dut.test_sha1_load_o), mockOut))
    else:
        log.info("Ok!")
        
        
@cocotb.test()
def B_reset_test(dut):
    """Testing synchronous reset"""
    log = SimLog("cocotb.%s" % dut._name)
    cocotb.fork(Clock(dut.clk_i, 10000).start())
    
    mockObject = Sha1Model()
    
    yield reset(dut)
    if convert_hex(dut.dat_1_o) != '0':
        raise TestFailure(
            "Reset failed!")
    yield load_data(dut, log, mockObject, 18)
    if convert_hex(dut.dat_1_o) == '0':
        raise TestFailure(
            "Data not populated!")
    else:
        log.info("Testing reset")
    yield reset(dut)
    if convert_hex(dut.dat_1_o) != '0':
        raise TestFailure(
            "Reset failed!")
    else:
        log.info("Reset Ok!")
    yield load_data(dut, log, mockObject, 19)

    mockOut = "{:08x}".format(mockObject.W[15])

    if convert_hex(dut.test_sha1_load_o).zfill(8) != mockOut:
        raise TestFailure(
            "Adder result is incorrect: {0} != {1}".format(convert_hex(dut.test_sha1_load_o), mockOut))
    else:
        log.info("Ok!")
        
        

        
        
@cocotb.test()
def D_wavedrom_test(dut):
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
            dut.pinput1.i,
            dut.pinput1.load_i,
            dut.pinput1.test_word_1,
            dut.pinput1.test_word_2,
            dut.pinput1.test_word_3,
            dut.pinput1.test_word_4,
            dut.pinput1.test_word_5,
            dut.pinput1.valid_o
            ]

    with cocotb.wavedrom.trace(*args, clk=dut.clk_i) as waves:
    
        yield RisingEdge(dut.clk_i)
        yield reset(dut)
        yield load_data(dut, log, mockObject, 16)
        mockObject.processInput()
        
        if _debug == True:
            log.info("{:08x}".format(mockObject.W[16 - 3]))
            log.info("{:08x}".format(mockObject.W[16 - 8]))
            log.info("{:08x}".format(mockObject.W[16 - 14]))
            log.info("{:08x}".format(mockObject.W[16 - 16]))
            log.info("{:08x}".format(mockObject.W[16]))
            
        yield load_data(dut, log, mockObject, 70)
        
        if _debug == True:
            log.info(dut.pinput1.test_word_1.value.hex())
            log.info(dut.pinput1.test_word_2.value.hex())
            log.info(dut.pinput1.test_word_3.value.hex())
            log.info(dut.pinput1.test_word_4.value.hex())
            log.info(dut.pinput1.test_word_5.value.hex())
            log.info(dut.pinput1.test_word_5)
            #log.info(waves.dumpj(header = {'text':'D_wavedrom_test', 'tick':-2}, config = {'hscale':3}))
            
        waves.write('wavedrom.json', header = {'text':'D_wavedrom_test', 'tick':-2}, config = {'hscale':3})
        
        #hackhack todo: do a better solution for this
        src = 'wavedrom.json'
        dst = '/home/www/projects/fpga/wavedrom.json'
        copyfile(src, dst)

        
@cocotb.test()
def C_process_first_input_test(dut):
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
    
    mockOut = "0x{:08x}".format(mockObject.W[16])
    
    if dut.pinput1.test_word_1.value.hex() != mockOut:
        raise TestFailure(
            "First load incorrect: {0} != {1}".format(dut.pinput1.test_word_1.value.hex(), mockOut))
    elif dut.pinput1.test_word_5.value.hex() != "0x{:08x}".format(mockObject.W[79]):
        raise TestFailure(
            "First load incorrect: {0} != {1}".format(dut.pinput1.test_word_5.value.hex(), "0x{:08x}".format(mockObject.W[79])))
    else:
        log.info("First load ok!")
        
        
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