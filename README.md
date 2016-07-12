FPGA-Cryptoparty
================
Old Bitcoin mining rigs are useful again!

This is a low-level investigation on the WPA2 encryption scheme.
By implementing some clever routing schemes, modern FPGAs should be a strong contender against general purpose CUDA GPUs for hashing performance.

Some discussion, and a few approaches that have been experimented with are [here](http://jrainimo.com/build/?cat=6).

Currently, this is being developed on the [GHDL](https://github.com/tgingold/ghdl) simulator with the [Cocotb](https://github.com/potentialventures/cocotb) testing framework.

To begin, run `sh install.sh`, which should first install GHDL, repo located in `tools/ghdl` of this repository, and then Cocotb in `tools/cocotb`.


To run tests, type `cd FPGA/tests && make`