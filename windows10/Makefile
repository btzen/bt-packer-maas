#!/usr/bin/make -f

PACKER_LOG ?= 0
export PACKER_LOG

ISO ?=

.PHONY: all clean

all: windows

OVMF_VARS.fd: /usr/share/OVMF/OVMF_VARS*.ms.fd
	cp -v $< $@

extra_drivers:
	mkisofs -o drivers.iso -V 'Extra Drivers' -input-charset utf-8 -r -J drivers

btfiles:
	mkisofs -o bt_files.iso -V 'BT Files' -input-charset utf-8 -r -J bt_files

.INTERMEDIATE: extra_drivers btfiles

windows: clean OVMF_VARS.fd extra_drivers btfiles
	packer init . && packer build -var iso_path=${ISO} windows.pkr.hcl

clean:
	${RM} -rf output-* windows10.dd.gz drivers.iso bt_files.iso OVMF_VARS.fd
