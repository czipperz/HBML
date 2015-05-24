# Maintainer: Czipperz <czipperz@gmail.com>
pkgname=hbml-git
pkgver=0.8
pkgrel=1
pkgdesc='Concise and better HTML'
arch=("any")
requires=("git" "rakudo")
url='https://github.com/czipperz/hbml'

_gitname="hbml"
_gitroot="git://github.com/czipperz/${_gitname}.git"

source=("$_gitroot")

package() {
	cd $srcdir/$_gitname
	install -Dm755 allInOne $pkgdir/usr/bin/hbml
}
md5sums=('SKIP')
