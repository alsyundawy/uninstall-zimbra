#!/bin/bash

######################################################################
# Nama Script   : uninstall_zimbra.sh
# Fungsi         : Menghapus Zimbra secara bersih dari sistem Linux
# Pembuat        : [Nama Anda] 
# Tanggal Dibuat : [Tanggal pembuatan, misalnya: 27 November 2024]
# Keterangan     : Skrip ini akan menghentikan layanan Zimbra, menghapus
#                  paket, file konfigurasi, direktori terkait, user/group,
#                  serta repository Zimbra dari sistem tanpa menghapus skrip ini setelah selesai.
######################################################################

echo "=== Menghentikan semua layanan Zimbra ==="
su - zimbra -c "zmcontrol stop" || echo "Layanan Zimbra sudah berhenti atau pengguna 'zimbra' tidak ditemukan."

echo "=== Menghapus paket Zimbra ==="
if command -v yum >/dev/null 2>&1; then
    yum remove -y zimbra-\*
elif command -v apt-get >/dev/null 2>&1; then
    apt-get purge -y zimbra-\*
else
    echo "Manajer paket tidak terdeteksi! Harap hapus paket Zimbra secara manual."
    exit 1
fi

echo "=== Menghapus repository Zimbra ==="
# Menghapus repository Zimbra pada Ubuntu/Debian
if [ -d /etc/apt/sources.list.d ]; then
    rm -f /etc/apt/sources.list.d/zimbra*.list
    echo "Repository Zimbra untuk Ubuntu/Debian telah dihapus."
fi

# Menghapus repository Zimbra pada Rocky Linux/CentOS
if [ -d /etc/yum.repos.d ]; then
    rm -f /etc/yum.repos.d/zimbra*.repo
    echo "Repository Zimbra untuk Rocky Linux/CentOS telah dihapus."
fi

echo "=== Menghapus direktori Zimbra ==="
rm -rf /opt/zimbra /etc/zimbra /var/log/zimbra /tmp/installdata

echo "=== Menghapus cron jobs pengguna 'zimbra' ==="
crontab -u zimbra -r || echo "Cron jobs untuk 'zimbra' tidak ditemukan."

echo "=== Menghapus user dan grup Zimbra ==="
userdel -r zimbra 2>/dev/null || echo "Pengguna 'zimbra' tidak ditemukan."
groupdel zimbra 2>/dev/null || echo "Grup 'zimbra' tidak ditemukan."

echo "=== Membersihkan file tambahan terkait Zimbra ==="
find / -name "*zimbra*" -exec rm -rf {} \; 2>/dev/null

echo "=== Verifikasi bahwa semua paket Zimbra telah dihapus ==="
if command -v yum >/dev/null 2>&1; then
    rpm -qa | grep zimbra && echo "Beberapa paket Zimbra masih ada, hapus secara manual!" || echo "Paket Zimbra telah dihapus."
elif command -v apt-get >/dev/null 2>&1; then
    dpkg -l | grep zimbra && echo "Beberapa paket Zimbra masih ada, hapus secara manual!" || echo "Paket Zimbra telah dihapus."
fi

echo "=== Proses selesai! Disarankan untuk reboot server. ==="
