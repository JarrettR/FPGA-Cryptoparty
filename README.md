FPGA-Cryptoparty
================
Old Bitcoin mining rigs are useful again!

This is a low-level investigation on the WPA2 encryption scheme.
By implementing some clever routing schemes, modern FPGAs should be a strong contender against general purpose CUDA GPUs for hashing performance.


Currently, this is being ported to the GHDL simulator with the Cocotb testing framework.

To run tests, type `cd FPGA/tests && make`