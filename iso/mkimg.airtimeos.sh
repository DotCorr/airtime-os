profile_airtimeos() {
	profile_standard
	title="AirtimeOS"
	desc="Airtime kiosk — live/demo ISO"
	profile_abbrev="airtimeos"
	image_ext="iso"
	arch="x86_64"
	output_format="iso"
	kernel_flavors="lts"
	kernel_addons=""
	kernel_cmdline="quiet loglevel=1 vt.global_cursor_default=0 console=tty1 console=ttyS0,115200 splash"
	syslinux_serial=""
	apks="$apks alpine-base linux-lts grub-efi grub-bios dosfstools efibootmgr $(cat /os/packages.txt | tr '\n' ' ')"
	apkovl="genapkovl-airtimeos.sh"
	hostname="airtimeos"
}

# branded framebuffer splash shown by the initramfs for the whole early boot
# (Alpine init: KOPT splash + /media/*/fbsplash.ppm, centered via IMG_ALIGN=CM)
build_fbsplash() {
	cp /os/iso/fbsplash.ppm "$DESTDIR"/fbsplash.ppm
}

section_fbsplash() {
	build_section fbsplash $(checksum < /os/iso/fbsplash.ppm)
}
