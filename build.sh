#!/bin/sh

set -e

WORKDIR=${WORKDIR:-/tmp/gelipwfromtpm-workdir}
MNTDIR=${MNTDIR:-/tmp/gelipwfromtpm-mntdir}
IMGFNAM=${IMGFNAM:-/boot/initramfs}
SIZE=${SIZE:-24m}
MDUNIT=${MDUNIT:-md1}

CP="cp -a -v"

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
  ${CP} /bin/${FNAM} ${WORKDIR}/bin/
done

${CP} ./rc ${WORKDIR}/etc/
chmod 755 ${WORKDIR}/etc/rc

for FNAM in libedit libc libncursesw libgeom libutil libbsdxml libsbuf libthr libcrypto libkiconv libmd; do
  ${CP} /lib/${FNAM}.so* ${WORKDIR}/lib/
done

${CP} /lib/geom/geom_eli.so ${WORKDIR}/lib/geom/

${CP} /libexec/ld-elf.so* ${WORKDIR}/libexec/

for FNAM in init geli mount mount_msdosfs reboot; do
  ${CP} /sbin/${FNAM} ${WORKDIR}/sbin/
done

for FNAM in tpm2_nvread tpm2_dictionarylockout; do
  ${CP} /usr/local/bin/${FNAM} ${WORKDIR}/usr/local/bin/
done

${CP} /usr/local/lib/libtss2-* ${WORKDIR}/usr/local/lib/

for FNAM in libuuid; do
  ${CP} /usr/local/lib/${FNAM}.so* ${WORKDIR}/usr/local/lib/
done

for FNAM in truss; do
  ${CP} /usr/bin/${FNAM} ${WORKDIR}/usr/bin/
done

for FNAM in libsysdecode; do
  ${CP} /usr/lib/${FNAM}.so* ${WORKDIR}/usr/lib/
done

rm -ivf ${IMGFNAM}
truncate -s ${SIZE} ${IMGFNAM}
mdconfig ${IMGFNAM}
newfs /dev/${MDUNIT}
mount /dev/${MDUNIT} ${MNTDIR}
cp -a ${WORKDIR}/* ${MNTDIR}/
umount ${MNTDIR}
mdconfig -du ${MDUNIT}
chflags -R noschg ${WORKDIR}
rm -rf ${WORKDIR}
rmdir -v ${MNTDIR}

