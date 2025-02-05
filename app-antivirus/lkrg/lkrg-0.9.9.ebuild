# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit linux-mod linux-info

DESCRIPTION="Linux Kernel Runtime Guard"
HOMEPAGE="https://lkrg.org"
SRC_URI="https://github.com/lkrg-org/lkrg/tarball/02bf2701ae0fd0c50741df00dc7ab72e3d9e8abb -> lkrg-0.9.9-02bf270.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
S="${WORKDIR}/lkrg-org-lkrg-02bf270"

MODULE_NAMES="lkrg(misc:${S}:${S})"

pkg_setup() {
	CONFIG_CHECK="HAVE_KRETPROBES KALLSYMS_ALL KPROBES JUMP_LABEL"
	CONFIG_CHECK+=" MODULE_UNLOAD !PREEMPT_RT ~STACKTRACE"
	linux-mod_pkg_setup

	# compile against selected (not running) target
	BUILD_PARAMS="P_KVER=${KV_FULL} P_KERNEL=${KERNEL_DIR}"
	BUILD_TARGETS="all"
}

src_unpack() {
	default
}

pkg_preinst() {
	linux-mod_pkg_preinst
	doinitd ${S}/scripts/bootup/openrc/lkrg
	insinto /etc/sysctl.d
	newins  ${S}/scripts/bootup/lkrg.conf 01-lkrg.conf
}

pkg_postinst() {
	linux-mod_pkg_postinst
	elog
	elog "It is recommended that before you setup LKRG to be started on bootup,"
	elog "you manually test loading the LKRG module into the kernel without making the setup permanent:"
	elog "    /etc/init.d/lkrg start"
	elog
	ewarn "In production environments there are strict requirements for secure"
	ewarn "loading and unloading LKRG module from the kernel. This requirements are already handled by the init script."
	ewarn "To take advantage of the init script consider adding lkrg to the boot runlevel:"
	ewarn "    rc-update add lkrg boot"
}