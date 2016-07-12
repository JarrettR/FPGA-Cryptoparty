git submodule update --init
apt-get update
apt-get install -y gnat
cd tools/ghdl && (./configure --prefix=/usr/local) && make && make install && cd ../..
