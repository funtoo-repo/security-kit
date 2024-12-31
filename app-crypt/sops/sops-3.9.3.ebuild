# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit go-module

SRC_URI="https://github.com/getsops/sops/tarball/64ccb3508185ad6247f4e096266e701caa6648f4 -> sops-3.9.3-64ccb35.tar.gz
https://direct-github.funmore.org/12/b4/d1/12b4d146edc4f4ff157ccbf5b8458a3f1ce5ac67b61d433e68bd70ff0617bce1c6ca5ddedaa58a31bec4f0cffbc92c8c28dcf8079984a31862b271691e764d61 -> sops-3.9.3-funtoo-go-bundle-8ea42aed38c4bd4b83d082c0925b49cec6b6246193fe24877ee44c025737b043be01d5168166320bda5b1dddb4b6da5186d94dad6ffdae9a9d64b40c44a0ccd4.tar.gz"
KEYWORDS="*"

DESCRIPTION="Simple and flexible tool for managing secrets"
HOMEPAGE="https://github.com/getsops/sops"
LICENSE="MPL-2.0"
SLOT="0"
S="${WORKDIR}/getsops-sops-64ccb35"

DOCS=( {CHANGELOG,README}.rst )

src_compile() {
	CGO_ENABLED=0 \
		go build -v -ldflags "-s -w" -o "${PN}" ./cmd/sops
}

src_install() {
	einstalldocs
	dobin ${PN}
}