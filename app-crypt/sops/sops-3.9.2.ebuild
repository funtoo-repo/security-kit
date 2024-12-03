# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit go-module

SRC_URI="https://github.com/getsops/sops/tarball/3ab69975bc1f7a75a5e75ab1cee5da8a6a07bf34 -> sops-3.9.2-3ab6997.tar.gz
https://direct-github.funmore.org/26/31/92/26319238c9ff46162595b8fe2eeac521d15b26afcff4fc2561f268200fc800cf015700c773d4fb8ab3491fc3aae9c46036ec00bdee12d71e277c3c33439cbbf1 -> sops-3.9.2-funtoo-go-bundle-e17b836849e35131abfbe520255ad640f457cfd164240ca0eb29ec28cb3c34d8cffaeaff3e88a5332d856d319d106938f2f5955e2b859c260f9844a951b79d8f.tar.gz"
KEYWORDS="*"

DESCRIPTION="Simple and flexible tool for managing secrets"
HOMEPAGE="https://github.com/getsops/sops"
LICENSE="MPL-2.0"
SLOT="0"
S="${WORKDIR}/getsops-sops-3ab6997"

DOCS=( {CHANGELOG,README}.rst )

src_compile() {
	CGO_ENABLED=0 \
		go build -v -ldflags "-s -w" -o "${PN}" ./cmd/sops
}

src_install() {
	einstalldocs
	dobin ${PN}
}