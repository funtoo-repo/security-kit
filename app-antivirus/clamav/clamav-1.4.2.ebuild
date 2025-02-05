# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake flag-o-matic user

DESCRIPTION="Clam Anti-Virus Scanner"
HOMEPAGE="https://www.clamav.net/"
SRC_URI="https://www.clamav.net/downloads/production/clamav-1.4.2.tar.gz -> clamav-1.4.2.tar.gz"
S="${WORKDIR}"/"${P%%_p?}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="bzip2 doc clamonacc clamdtop clamsubmit iconv ipv6 libclamav-only milter metadata-analysis-api selinux uclibc unrar test xml"

REQUIRED_USE="libclamav-only? ( !clamonacc !clamdtop !clamsubmit !milter !metadata-analysis-api )"

RESTRICT="!test? ( test )"

CDEPEND="
	dev-libs/json-c:=
	bzip2? ( app-arch/bzip2 )
	clamdtop? ( sys-libs/ncurses:0 )
	clamsubmit? ( net-misc/curl )
	iconv? ( virtual/libiconv )
	milter? ( || ( mail-filter/libmilter mail-mta/sendmail ) )
	>=sys-libs/zlib-1.2.2:=
	sys-devel/libtool
	|| ( dev-libs/libpcre2 >dev-libs/libpcre-6 )
	dev-libs/libmspack
	dev-libs/libltdl
	dev-libs/openssl:0=
	dev-libs/tomsfastmath
	xml? ( dev-libs/libxml2 )
	elibc_musl? ( sys-libs/fts-standalone )
"

BDEPEND="
	virtual/pkgconfig
	virtual/rust
"

DEPEND="${CDEPEND}
	test? ( dev-libs/check )"

RDEPEND="${CDEPEND}
	selinux? ( sec-policy/selinux-clamav )"

HTML_DOCS=( docs/html )

pkg_setup() {
	enewgroup clamav
	enewuser clamav -1 -1 /dev/null clamav
}

src_prepare() {
	cmake_src_prepare
}

src_configure() {
	use elibc_musl && append-ldflags -lfts
	use ppc64 && append-flags -mminimal-toc
	use uclibc && export ac_cv_type_error_t=yes

	# CMAKE_BUILD_TYPE="RelWithDebInfo"

	mycmakeargs=(
		-DCMAKE_BUILD_TYPE='None'
		-DDATABASE_DIRECTORY="${EPREFIX}"/var/lib/clamav
		-DAPP_CONFIG_DIRECTORY="${EPREFIX}"/etc/
		-DCMAKE_INSTALL_SBINDIR="${EPREFIX}"/usr/sbin
		-DENABLE_EXTERNAL_MSPACK=ON
		-DENABLE_JSON_SHARED=ON
		-DENABLE_MILTER=$(usex milter ON OFF)
		-DENABLE_UNRAR=$(usex unrar ON OFF)
		-DENABLE_STATIC_LIB=OFF
		-DENABLE_TESTS=$(usex test ON OFF)
	)

	if use libclamav-only; then
		mycmakeargs+=(
			-DENABLE_LIBCLAMAV_ONLY=ON
			-DENABLE_APP=OFF
			-DENABLE_CLAMONACC=OFF
		)
	elif use clamonacc || use clamdtop || use clamsubmit || use milter; then
		mycmakeargs+=(
			-DENABLE_LIBCLAMAV_ONLY=OFF
			-DENABLE_APP=ON
			-DENABLE_CLAMONACC=$(usex clamonacc ON OFF)
		)
	fi

	cmake_src_configure
}

src_install() {
	cmake_src_install

	rm -rf "${ED}"/var/lib/clamav || die

	if ! use libclamav-only ; then
		newinitd "${FILESDIR}"/clamd.initd clamd
		newconfd "${FILESDIR}"/clamd.conf clamd

		keepdir /var/lib/clamav
		fowners clamav:clamav /var/lib/clamav
		keepdir /var/log/clamav
		fowners clamav:clamav /var/log/clamav

		dodir /etc/logrotate.d
		insinto /etc/logrotate.d
		newins "${FILESDIR}/clamd.logrotate" clamd
		newins "${FILESDIR}/freshclam.logrotate" freshclam
		use milter && \
			newins "${FILESDIR}/clamav-milter.logrotate" clamav-milter

		# Modify /etc/{clamd,freshclam}.conf to be usable out of the box
		sed -i -e "s:^\(Example\):\# \1:" \
			-e "s:.*\(PidFile\) .*:\1 ${EPREFIX}/run/clamd.pid:" \
			-e "s:.*\(LocalSocket\) .*:\1 ${EPREFIX}/run/clamav/clamd.sock:" \
			-e "s:.*\(User\) .*:\1 clamav:" \
			-e "s:^\#\(LogFile\) .*:\1 ${EPREFIX}/var/log/clamav/clamd.log:" \
			-e "s:^\#\(LogTime\).*:\1 yes:" \
			-e "s:^\#\(AllowSupplementaryGroups\).*:\1 yes:" \
			"${ED}"/etc/clamd.conf.sample || die

		sed -i -e "s:^\(Example\):\# \1:" \
			-e "s:.*\(PidFile\) .*:\1 ${EPREFIX}/run/freshclam.pid:" \
			-e "s:.*\(DatabaseOwner\) .*:\1 clamav:" \
			-e "s:^\#\(UpdateLogFile\) .*:\1 ${EPREFIX}/var/log/clamav/freshclam.log:" \
			-e "s:^\#\(NotifyClamd\).*:\1 ${EPREFIX}/etc/clamd.conf:" \
			-e "s:^\#\(ScriptedUpdates\).*:\1 yes:" \
			-e "s:^\#\(AllowSupplementaryGroups\).*:\1 yes:" \
			"${ED}"/etc/freshclam.conf.sample || die

		if use milter ; then
			# MilterSocket one to include ' /' because there is a 2nd line for
			# inet: which we want to leave
			##dodoc "${FILESDIR}"/clamav-milter.README.gentoo
			sed -i -e "s:^\(Example\):\# \1:" \
				-e "s:.*\(PidFile\) .*:\1 ${EPREFIX}/run/clamav-milter.pid:" \
				-e "s+^\#\(ClamdSocket\) .*+\1 unix:${EPREFIX}/run/clamav/clamd.sock+" \
				-e "s:.*\(User\) .*:\1 clamav:" \
				-e "s+^\#\(MilterSocket\) /.*+\1 unix:${EPREFIX}/run/clamav/clamav-milter.sock+" \
				-e "s:^\#\(AllowSupplementaryGroups\).*:\1 yes:" \
				-e "s:^\#\(LogFile\) .*:\1 ${EPREFIX}/var/log/clamav/clamav-milter.log:" \
				"${ED}"/etc/clamav-milter.conf.sample || die
			cat >> "${ED}"/etc/conf.d/clamd <<-EOF
				MILTER_NICELEVEL=19
				START_MILTER=no
			EOF

		fi

		local i
		for i in clamd freshclam clamav-milter
		do
			if [[ -f "${D}"/etc/"${i}".conf.sample ]]; then
				mv "${D}"/etc/"${i}".conf{.sample,} || die
			fi
		done

	fi

	if use doc; then
		local HTML_DOCS=( docs/html/. )
		einstalldocs

		if ! use libclamav-only ; then
			doman ${BUILD_DIR}/docs/man/*.[1-8]
		fi
	fi

	find "${ED}" -name '*.la' -delete || die
}

src_test() {
	if use libclamav-only ; then
		ewarn "Test target not available when USE=libclamav-only is set, skipping tests ..."
		return 0
	fi

	cmake_src_test
}

pkg_postinst() {
	if use milter ; then
		elog "For simple instructions how to setup the clamav-milter read the"
		elog "clamav-milter.README.gentoo in /usr/share/doc/${PF}"
	fi

	local databases=( "${EROOT}"/var/lib/clamav/main.c[lv]d )
	if [[ ! -f "${databases}" ]] ; then
		ewarn "You must run freshclam manually to populate the virus database"
		ewarn "before starting clamav for the first time."
	fi
}