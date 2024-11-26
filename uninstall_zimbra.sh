#!/bin/bash

# Skrip untuk menghapus Zimbra secara bersih dari sistem
# Tidak akan menghapus dirinya sendiri setelah selesai

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
