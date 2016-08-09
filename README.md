FPGA-Cryptoparty
================
Old Bitcoin mining rigs are useful again!

This is a low-level investigation on the WPA2 encryption scheme.
By implementing some clever routing schemes, modern FPGAs should be a strong contender against general purpose CUDA GPUs for hashing performance.

Some discussion, and a few approaches that have been experimented with are [here](http://jrainimo.com/build/?cat=6).

Currently, this is being developed on the [GHDL](https://github.com/tgingold/ghdl) simulator with the [Cocotb](https://github.com/potentialventures/cocotb) testing framework.


== To develop ==
Run `sh install.sh`, which should first install GHDL and then Cocotb, both located in the `tools` directory.
Updating submodules is done by running `sh update-submodules.sh`, which may or may not break stuff.

To run tests, type `cd FPGA/tests` and then `make`. The design will be simulated, regression tests run, and then waveforms generated.


If you're running this from a server with NGINX running, the waveforms can be viewed in an auto-updating webpage.
Modify the file at `tools/www/wavedrom-nginx.conf` with appropriate paths, and then add the line `include <path to tools/www/wavedrom-nginx.conff>` (also with appropriate path) in `/etc/nginx/sites-enabled/default` (or your NGINX config).

The page will update a few seconds after you make your project, assuming the test finished properly.
