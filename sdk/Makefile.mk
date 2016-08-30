# This Makefile defines the standard rules for building FX2 projects.
#
# The following variables are used:
#
# ZTEXPREFIX
#   Defines the location of the EZ-USB SDK
#   Must be defined!
#   Example: ZTEXPREFIX=../../..
#
# JARTARGET
#   The name of the jar archive
#   Example: JARTARGET=UCEcho.jar
#
# CLASSTARGETS
#   Java Classes that have to be build 
#   Example: CLASSTARGETS=UCEcho.class
#
# CLASSEXTRADEPS
#   Extra dependencies for Java Classes
#   Example: CLASSEXTRADEPS:=$(wildcard $(ZTEXPREFIX)/java/ztex/*.java)
#
# IHXTARGETS
#   FX2 ihx files (firmware ROM files) that have to be build 
#   Example: IHXTARGETS=ucecho.ihx
#
# IHXEXTRADEPS
#   Extra Dependencies for ihx files
#   Example: IHXEXTRADEPS:=$(wildcard $(ZTEXPREFIX)/fx2/*.h)
#
# IMGTARGETS
#   FX3 img files (firmware ROM files) that have to be build 
#   Example: IMGTARGETS=ucecho.img
#
# IMGEXTRA_C_SOURCES
#   extra C sources
#
# IMGEXTRA_A_SOURCES
#   extra Assembler sources
#
# EXTRAJARFILES
#   Extra files that should be included into the jar archive
#   Example: EXTRAJARFILES=ucecho.ihx fpga/ucecho.bin
#
# EXTRAJARFLAGS
#   Extra flags for the jar command
#   Example: EXTRAJARFLAGS=-C com
#
# EXTRACLEANFILES
#   Extra files that should be cleaned by target "clean"
#
# EXTRADISTCLEANFILES
#   Extra files that should be cleaned by target "distclean"


.PHONY: all ihx jar clean distclean default avr avrclean avrdistclean
.SUFFIXES: .img .ihx .class .jar .java .c .o .S .elf

FX3FWROOT=$(FX3_INSTALL_PATH)/firmware
FX3PFWROOT=$(FX3_INSTALL_PATH)/firmware/u3p_firmware
FX3UTILROOT=$(FX3_INSTALL_PATH)/util

JAVAC=$(JAVAC_PATH)javac -Xlint:deprecation
JAR=$(JAVAC_PATH)jar
SDCC=$(ZTEXPREFIX)/bin/bmpsdcc.sh
ARMCC=$(ARMGCC_INSTALL_PATH)/bin/arm-none-eabi-gcc
ARMAS=$(ARMGCC_INSTALL_PATH)/bin/arm-none-eabi-gcc
ARMLD=$(ARMGCC_INSTALL_PATH)/bin/arm-none-eabi-ld
ARMAR=$(ARMGCC_INSTALL_PATH)/bin/arm-none-eabi-ar
ELF2IMG=$(FX3UTILROOT)/elf2img/elf2img

CLASSPATH:=.:$(ZTEXPREFIX)/usb4java:$(ZTEXPREFIX)/java:$(CLASSPATH)
INCLUDES=-I $(ZTEXPREFIX)/fx2/

# ARMASMFLAGS
ARMASMFLAGS= -Wall -c -mcpu=arm926ej-s -mthumb-interwork

#LDFLAGS
ARMLDLIBS=$(FX3PFWROOT)/lib/$(CYCONFOPT)/cyu3sport.a \
          $(FX3PFWROOT)/lib/$(CYCONFOPT)/cyu3lpp.a \
          $(FX3PFWROOT)/lib/$(CYCONFOPT)/cyfxapi.a \
          $(FX3PFWROOT)/lib/$(CYCONFOPT)/cyu3threadx.a \
          $(ARMGCC_INSTALL_PATH)/arm-none-eabi/lib/libc.a \
          $(ARMGCC_INSTALL_PATH)/lib/gcc/arm-none-eabi/*/libgcc.a
ARMLDFLAGS=--entry CyU3PFirmwareEntry $(ARMLDLIBS) -T $(FX3FWROOT)/common/fx3_512k.ld -d --gc-sections --no-wchar-size-warning 

# ARMCCFLAGS
ARMINCLUDES=-I. -I $(ZTEXPREFIX)/fx3/ -I$(FX3PFWROOT)/inc
ARMCCFLAGS= -g -DTX_ENABLE_EVENT_TRACE -DDEBUG -DCYU3P_FX3=1 -D__CYU3P_TX__=1 -Wall -std=gnu99 -mcpu=arm926ej-s -mthumb-interwork $(ARMINCLUDES)
ifeq ($(CYCONFOPT), fx3_release)
    ARMCCFLAGS+= -Os
else
    ARMCCFLAGS+= -O3
endif

ifeq ($(CYCONFOPT),)
    CYCONFOPT=fx3_release
endif

IMGEXTRA_C_OBJECTS=$(EXTRA_C_SOURCES:%.c=./%.o)
IMGEXTRA_A_OBJECTS=$(EXTRA_A_SOURCES:%.S=./%.o)

all : ihx img jar 
ihx : $(IHXTARGETS)
img : $(IMGTARGETS)
jar : $(JARTARGET)

include $(ZTEXPREFIX)/Makefile.conf

%.ihx: %.c $(IHXEXTRADEPS)
	$(SDCC) $< "$(INCLUDES)"

%.class: %.java $(CLASSEXTRADEPS)
	$(JAVAC) -cp "$(CLASSPATH)" $<

$(JARTARGET) : $(CLASSTARGETS) $(EXTRAJARFILES)
	$(JAR) cf $(JARTARGET) *.class $(EXTRAJARFILES) $(EXTRAJARFLAGS) -C $(ZTEXPREFIX)/usb4java . $(shell cd $(ZTEXPREFIX)/java; ls ztex/*.class | while read a; do echo "-C $(ZTEXPREFIX)/java '$$a'"; done)


%.o: %.c
	$(ARMCC) $(ARMCCFLAGS) -c -o $@ $< 

%.o: %.S
	$(ARMAS) $(ARMASMFLAGS) -o $@ $<

cyfxtx.o: $(FX3FWROOT)/common/cyfxtx.c
	$(ARMCC) $(ARMCCFLAGS) -c -o "$@" "$<"
    
cyfx_gcc_startup.o: $(FX3FWROOT)/common/cyfx_gcc_startup.S
	 $(ARMAS) $(ARMASMFLAGS) -o "$@" "$<"

%.elf: cyfx_gcc_startup.o cyfxtx.o %.o $(IMGEXTRA_A_OBJECTS) $(IMGEXTRA_C_OBJECTS)
	$(ARMLD) $+ $(ARMLDFLAGS) -Map $(basename $@).map -o $@

%.img: %.elf
	$(ELF2IMG) -o $@ -i $<


clean: 
	rm -f *~ *.bak *.old
	rm -f *.class 
	rm -f *.rel *.rst *.lnk *.lst *.map *.asm *.sym *.mem *.tmp.c 
	rm -f *.o *.elf *.map *.tmp.c 
	rm -f $(EXTRACLEANFILES)

distclean: clean
	rm -f $(JARTARGET)
	rm -f *.ihx
	rm -f *.img
	rm -f $(EXTRADISTCLEANFILES)
	
avr:
	if [ -d avr ]; then make -C avr all; fi

avrclean:
	if [ -d avr ]; then make -C avr clean; fi

avrdistclean:
	if [ -d avr ]; then make -C avr distclean; fi
