# Simple tests for an adder module
import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.result import TestFailure
import random


def adder_model(a, b):
    """ model of adder """
    return a + b

@cocotb.coroutine
def clock_gen(signal):
    while True:
        signal <= 0
        yield Timer(5000)
        signal <= 1
        yield Timer(5000)
    
@cocotb.test()
def stream_passthrough(dut):
    """Test for basic input and output stream"""
    yield Timer(2)
    input = random.randint(0, 255)

    dut.dat_i = input
    

    yield RisingEdge(dut.clk_i)

    if int(dut.x) != adder_model(A, B):
        raise TestFailure(
            "Adder result is incorrect: %s != 15" % str(dut.x))
    else:  # these last two lines are not strictly necessary
        dut.log.info("Ok!")
        
        
@cocotb.test()
def adder_basic_test(dut):
    """Test for 5 + 10"""
    yield Timer(2)
    A = 5
    B = 10

    dut.a = A
    dut.b = B

    yield Timer(2)

    if int(dut.x) != adder_model(A, B):
        raise TestFailure(
            "Adder result is incorrect: %s != 15" % str(dut.x))
    else:  # these last two lines are not strictly necessary
        dut.log.info("Ok!")


@cocotb.test()
def adder_randomised_test(dut):
    """Test for adding 2 random numbers multiple times"""
    yield Timer(2)

    for i in range(10):
        A = random.randint(0, 15)
        B = random.randint(0, 15)

        dut.a = A
        dut.b = B

        yield Timer(2)

        if int(dut.x) != adder_model(A, B):
            raise TestFailure(
                "Randomised test failed with: %s + %s = %s" %
                (int(dut.a), int(dut.b), int(dut.x)))
        else:  # these last two lines are not strictly necessary
            dut.log.info("Ok!")