git submodule update --init
apt-get update
apt-get install -y pip
cd tools/wpa2slow && (pip install -e .) && cd ../..
apt-get install -y gnat
cd tools/ghdl && (./configure --prefix=/usr/local) && make && make install && cd ../..
