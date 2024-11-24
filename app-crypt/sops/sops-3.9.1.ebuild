# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit go-module

SRC_URI="https://github.com/getsops/sops/tarball/af949bd819de7094a450d6aab7a7a1ca2fa387be -> sops-3.9.1-af949bd.tar.gz
https://direct-github.funmore.org/b8/a9/e0/b8a9e04111c0c9788ecb32f90b53c8bdb0fa942a7ca252799e34fd381af72b4613ca43e55fe3f74c7f34e22dbfb8e64e084a6ba5babc3647148c9d4d94d854d0 -> sops-3.9.1-funtoo-go-bundle-2b8d674f65433b121e80b34f5cce186ea99350ed8a05c862f0ab9a7ef1722cce6e5a6eecfc43d0fb88a3e7c4af2cd9b942ce93a09760fcf13d6205e394a9cac7.tar.gz"
KEYWORDS="*"

DESCRIPTION="Simple and flexible tool for managing secrets"
HOMEPAGE="https://github.com/getsops/sops"
LICENSE="MPL-2.0"
SLOT="0"
S="${WORKDIR}/getsops-sops-af949bd"

DOCS=( {CHANGELOG,README}.rst )

src_compile() {
	CGO_ENABLED=0 \
		go build -v -ldflags "-s -w" -o "${PN}" ./cmd/sops
}

src_install() {
	einstalldocs
	dobin ${PN}
}