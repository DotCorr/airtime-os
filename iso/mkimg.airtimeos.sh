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
	kernel_cmdline="quiet vt.global_cursor_default=0"
	syslinux_serial=""
	apks="$apks alpine-base $(cat /os/packages.txt | tr '\n' ' ')"
	apkovl="genapkovl-airtimeos.sh"
	hostname="airtimeos"
}
