#!/bin/sh

set -e

WORKDIR=${WORKDIR:-/tmp/gelipwfromtpm-workdir}
MNTDIR=${MNTDIR:-/tmp/gelipwfromtpm-mntdir}
IMGFNAM=${IMGFNAM:-/boot/initramfs}
SIZE=${SIZE:-24m}
MDUNIT=${MDUNIT:-md1}

echo "WORKDIR: ${WORKDIR}"
echo "IMGFNAM: ${IMGFNAM}"

mkdir -p ${MNTDIR}

mkdir -p ${WORKDIR}/bin
mkdir -p ${WORKDIR}/boot
mkdir -p ${WORKDIR}/dev
mkdir -p ${WORKDIR}/etc
mkdir -p ${WORKDIR}/lib/geom
mkdir -p ${WORKDIR}/libexec
mkdir -p ${WORKDIR}/sbin
mkdir -p ${WORKDIR}/tmp
mkdir -p ${WORKDIR}/usr/local/bin
mkdir -p ${WORKDIR}/usr/local/lib
mkdir -p ${WORKDIR}/usr/bin
mkdir -p ${WORKDIR}/usr/lib

for FNAM in sh ls kenv cat; do
  cp -v /bin/${FNAM} ${WORKDIR}/bin/
done

cp -v ./rc ${WORKDIR}/etc/

for FNAM in libedit libc libncursesw libgeom libutil libbsdxml libsbuf libthr libcrypto libkiconv libmd; do
  cp -v /lib/${FNAM}.so* ${WORKDIR}/lib/
done

cp -v /lib/geom/geom_eli.so ${WORKDIR}/lib/geom/

cp -v /libexec/ld-elf.so* ${WORKDIR}/libexec/

for FNAM in init geli mount mount_msdosfs reboot; do
  cp -v /sbin/${FNAM} ${WORKDIR}/sbin/
done

for FNAM in tpm2_nvread tpm2_dictionarylockout; do
  cp -v /usr/local/bin/${FNAM} ${WORKDIR}/usr/local/bin/
done

cp -a /usr/local/lib/libtss2-* ${WORKDIR}/usr/local/lib/

for FNAM in libuuid; do
  cp -v /usr/local/lib/${FNAM}.so* ${WORKDIR}/usr/local/lib/
done

for FNAM in truss; do
  cp -v /usr/bin/${FNAM} ${WORKDIR}/usr/bin/
done

for FNAM in libsysdecode; do
  cp -v /usr/lib/${FNAM}.so* ${WORKDIR}/usr/lib/
done

rm -ivf ${IMGFNAM}
truncate -s ${SIZE} ${IMGFNAM}
mdconfig ${IMGFNAM}
newfs /dev/${MDUNIT}
mount /dev/${MDUNIT} ${MNTDIR}
cp -a ${WORKDIR}/* ${MNTDIR}/
umount ${MNTDIR}
mdconfig -du ${MDUNIT}
rm -rf ${WORKDIR}
rmdir -v ${MNTDIR}

