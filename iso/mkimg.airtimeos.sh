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

# own every boot pixel: no menu, no timeout, branded entry (the only text GRUB
# can flash is "Booting 'AirtimeOS'" for a fraction of a second)
grub_gen_config() {
	local _initrd="/boot/initramfs-lts"
	local _p
	if [ -n "$initrd_ucode" ]; then
		for _p in $initrd_ucode; do
			_initrd="$_p $_initrd"
		done
	fi
	cat <<- EOF
	set timeout=0
	set timeout_style=hidden
	set default=0

	menuentry "AirtimeOS" {
		linux	/boot/vmlinuz-lts $initfs_cmdline $kernel_cmdline
		initrd	$_initrd
	}
	EOF
}
