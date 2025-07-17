#!/usr/bin/make -f

PACKER_LOG ?= 0
export PACKER_LOG

ISO ?=

.PHONY: all

all: windows

OVMF_VARS.fd: /usr/share/OVMF/OVMF_VARS*.ms.fd
	cp -v $< $@

extra_drivers:
	mkisofs -o drivers.iso -V 'Extra Drivers' -input-charset utf-8 -r -J drivers

bt_files:
	mkisofs -o bt_files.iso -V 'BT Files' -input-charset utf-8 -r -J bt_files

.INTERMEDIATE: OVMF_VARS.fd extra_drivers bt_files

windows: OVMF_VARS.fd extra_drivers bt_files
	packer init . && packer build -var iso_path=${ISO} windows.pkr.hcl
