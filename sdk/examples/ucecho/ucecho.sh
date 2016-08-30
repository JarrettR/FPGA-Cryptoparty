#make -C ../../default/usb-fpga-2.14 distclean all || exit 1
#make distclean all || exit 1
#java -cp ../../default/DefaultUpdater DefaultUpdater
java -cp UCEcho.jar UCEcho $@
