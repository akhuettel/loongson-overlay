# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

if [[ ${PV} == *9999* ]]; then
	SRC_ECLASS="git-r3"
	EGIT_REPO_URI="https://anongit.gentoo.org/git/proj/catalyst.git"
	EGIT_BRANCH="master"
else
	SRC_URI="https://gitweb.gentoo.org/proj/catalyst.git/snapshot/${P}.tar.bz2"
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86"
fi

PYTHON_COMPAT=( python3_{8..10} )
DISTUTILS_USE_SETUPTOOLS=no

inherit distutils-r1 ${SRC_ECLASS}

DESCRIPTION="Release metatool used for creating releases based on Gentoo Linux"
HOMEPAGE="https://wiki.gentoo.org/wiki/Catalyst"

LICENSE="GPL-2+"
SLOT="0"
IUSE="ccache doc +iso system-bootloader"

DEPEND="
	app-text/asciidoc
	>=dev-python/snakeoil-0.6.5[${PYTHON_USEDEP}]
	dev-python/fasteners[${PYTHON_USEDEP}]
"
RDEPEND="
	>=dev-python/snakeoil-0.6.5[${PYTHON_USEDEP}]
	dev-python/fasteners[${PYTHON_USEDEP}]
	>=dev-python/pydecomp-0.3[${PYTHON_USEDEP}]
	app-arch/lbzip2
	app-crypt/shash
	sys-fs/dosfstools
	|| (
		app-arch/tar[xattr]
		app-arch/libarchive[xattr]
	)
	amd64? ( >=sys-boot/syslinux-3.72 )
	x86? ( >=sys-boot/syslinux-3.72 )
	ccache? ( dev-util/ccache )
	iso? ( app-cdr/cdrtools )
	kernel_linux? ( app-misc/zisofs-tools >=sys-fs/squashfs-tools-2.1 )
"
COMMON_PDEPEND_X86="
	>=sys-apps/memtest86+-5.01-r4
	sys-boot/syslinux
	sys-boot/shim
"
PDEPEND="
	system-bootloader? (
		amd64? (
			${COMMON_PDEPEND_X86}
			sys-boot/grub:2[grub_platforms_efi-32,grub_platforms_efi-64]
		)
		x86? (
			${COMMON_PDEPEND_X86}
			sys-boot/grub:2[grub_platforms_efi-32]
		)
		loong? (
			sys-boot/grub:2[grub_platforms_efi-64]
			sys-boot/loongarch-acpi-tables-fix
		)
	)
"

PATCHES=(
	"${FILESDIR}"/0001-add-support-for-ARCH-loong.patch
	"${FILESDIR}"/0002-targets-add-support-for-building-LoongArch-LiveCDs.patch
	"${FILESDIR}"/0003-functions.sh-use-normal-bzip2-instead-of-lbzip2-whic.patch
	"${FILESDIR}"/0004-refine-LoongArch-bootloader-setup.patch
	"${FILESDIR}"/0005-prepend-early-initrd-for-loong.patch
)

python_prepare_all() {
	python_setup
	echo VERSION="${PV}" "${PYTHON}" setup.py set_version
	VERSION="${PV}" "${PYTHON}" setup.py set_version || die
	distutils-r1_python_prepare_all
}

python_compile_all() {
	# build the man pages and docs
	emake
}

python_install_all() {
	distutils-r1_python_install_all
	if use doc; then
		dodoc files/HOWTO.html files/docbook-xsl.css
	fi
}
