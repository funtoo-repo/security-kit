# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit go-module

SRC_URI="https://github.com/getsops/sops/tarball/b3e5ac783934aba952829be4956b8d282a242def -> sops-3.11.0-b3e5ac7.tar.gz
https://direct-github.funmore.org/8e/06/d9/8e06d965ad8447982e1f9269e6dbc04c6374694b193e3dc9280ee74ac581e27669813c9e2daeea97ff9540efebe09fadd22397a91bbe2958cf946d9dbcb56391 -> sops-3.11.0-funtoo-go-bundle-0a417c565ff8b873b63c290511d63723e5f8fcacebd3347481930e565c499d33cb90b2412e1ec97e6057ca613eb1e106ce9708bc820e6e54e92b92175e2e86ec.tar.gz"
KEYWORDS="*"

DESCRIPTION="Simple and flexible tool for managing secrets"
HOMEPAGE="https://github.com/getsops/sops"
LICENSE="MPL-2.0"
SLOT="0"
S="${WORKDIR}/getsops-sops-b3e5ac7"

DOCS=( {CHANGELOG,README}.rst )

src_compile() {
	CGO_ENABLED=0 \
		go build -v -ldflags "-s -w" -o "${PN}" ./cmd/sops
}

src_install() {
	einstalldocs
	dobin ${PN}
}