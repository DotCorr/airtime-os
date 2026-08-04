# Sourced after mkimg.base.sh (glob order) so these overrides actually win.
# Own every boot pixel: no menu, no timeout, branded entry.
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
