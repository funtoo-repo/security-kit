# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

DESCRIPTION="nwipe secure disk eraser"
HOMEPAGE="https://github.com/martijnvanbrummelen/nwipe"
SRC_URI="https://github.com/martijnvanbrummelen/nwipe/tarball/2aa060531df1181efa93030a23b6edff4a8acd35 -> nwipe-0.39-2aa0605.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="smartmontools"

RDEPEND="
	sys-apps/dmidecode
	sys-block/parted
	sys-libs/ncurses:=
	smartmontools? ( sys-apps/smartmontools )
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

post_src_unpack() {
	if [ ! -d "${S}" ]; then
			mv martijnvanbrummelen-nwipe* "${S}" || die
	fi
}

src_prepare() {
	default
	eautoreconf
}