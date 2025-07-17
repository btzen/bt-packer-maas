packer {
  required_version = ">= 1.11.0"
  required_plugins {
    qemu = {
      version = ">= 1.1.0, < 1.1.2"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "iso_path" {
  type    = string
  default = ""
}

variable "filename" {
  type        = string
  default     = "windows10.dd.gz"
}

locals {
  baseargs = [
    ["-cpu", "host"],
    ["-serial", "stdio"],
    ["-drive", "if=pflash,format=raw,id=ovmf_code,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.ms.fd"],
    ["-drive", "if=pflash,format=raw,id=ovmf_vars,file=OVMF_VARS.fd"],
    ["-drive", "file=output-windows_builder/packer-windows_builder,format=raw"],
    ["-cdrom", "${var.iso_path}"],
    ["-drive", "file=drivers.iso,media=cdrom,index=3"],
    ["-drive", "file=bt_files.iso,media=cdrom,index=4"],
    ["-boot", "d"],
    ["-device", "nec-usb-xhci"],
    ["-device", "usb-tablet"]
  ]
}

source "qemu" "windows_builder" {
  accelerator      = "kvm"
  boot_command     = ["<return>"]
  boot_wait        = "2s"
  communicator     = "none"
  disk_interface   = "sata"
  disk_image       = "false"
  disk_size        = "32G"
  floppy_files     = ["./http/Autounattend.xml", "./http/logon.ps1", "./http/sysprep_manual.ps1", "./http/rh.cer"]
  floppy_label     = "flop"
  format           = "raw"
  headless         = "false"
  http_directory   = "http"
  iso_checksum     = "none"
  iso_url          = "${var.iso_path}"
  machine_type     = "q35"
  memory           = "8192"
  cpus             = "8"
  net_device       = "e1000"
  qemuargs         = local.baseargs
  shutdown_timeout = "2h"
  vnc_bind_address = "0.0.0.0"
}

build {
  sources = ["source.qemu.windows_builder"]

  post-processor "shell-local" {
    inline = [
      "echo 'Syncing output-windows_builder/packer-windows_builder...'",
      "sync -f output-windows_builder/packer-windows_builder",
      "IMG_FMT=raw",
      "source scripts/setup-nbd",
      "TMP_DIR=$(mktemp -d /tmp/packer-maas-XXXX)",
      "echo 'Adding curtin-hooks to image...'",
      "mount -t ntfs $${nbd}p4 $TMP_DIR",
      "mkdir -p $TMP_DIR/curtin",
      "cp ./curtin/* $TMP_DIR/curtin/",
      "sync -f $TMP_DIR/curtin",
      "umount $TMP_DIR",
      "qemu-nbd -d $nbd",
      "rmdir $TMP_DIR"
    ]
    inline_shebang = "/bin/bash -e"
  }

  post-processor "compress" {
    output = "${var.filename}"
  }
}
