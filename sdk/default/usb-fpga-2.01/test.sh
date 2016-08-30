#make -C ../../java distclean all || exit
make distclean all || exit
java -cp Default.jar Default -f $@
