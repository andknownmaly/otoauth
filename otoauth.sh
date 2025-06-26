#!/bin/bash

AUTH_REALM="Restricted Area"
SESSION_TIMEOUT=10800  # 3 jam dalam detik
CONFIG_FILE="/opt/otoauth/.config_auth"

function require_sudo() {
    if [ "$EUID" -ne 0 ]; then
        echo "[!] Script ini harus dijalankan dengan sudo atau sebagai root."
        echo "    Jalankan: sudo $0"
        exit 1
    fi
}

function enable_auth() {
    apt install -y apache2-utils
    mkdir -p /opt/otoauth
    HTPASSWD_FILE="/opt/otoauth/.htpasswd"
    
    echo "[*] Masukkan path lengkap file .htaccess yang ingin dikonfigurasi (contoh: /var/www/html/.htaccess)"
    read -r HTACCESS_FILE
    echo

    echo "[*] Masukkan username"
    read -r AUTH_USER
    echo

    echo "[*] Masukkan password untuk user '$AUTH_USER':"
    read -s PASSWORD
    echo

    echo "[*] Konfirmasi password:"
    read -s PASSWORD_CONFIRM
    echo

    if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]; then
        echo "[!] Password tidak cocok. Batal."
        return
    fi

    echo "[*] Membuat file .htpasswd..."
    htpasswd -cb "$HTPASSWD_FILE" "$AUTH_USER" "$PASSWORD"

    if [ -f "$HTACCESS_FILE" ]; then
        echo "[!] File .htaccess sudah ada. Timpa isinya? (y/n)"
        read -r confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            echo "[*] Batal."
            return
        fi
    fi

    echo "[*] Menulis konfigurasi Basic Auth ke .htaccess..."
    cat <<EOF > "$HTACCESS_FILE"
AuthType Basic
AuthName "$AUTH_REALM"
AuthUserFile $HTPASSWD_FILE
Require valid-user

Header set Cache-Control "private, max-age=$SESSION_TIMEOUT"
EOF

    echo "$HTPASSWD_FILE" > "$CONFIG_FILE"
    echo "$HTACCESS_FILE" >> "$CONFIG_FILE"

    echo "[+] Basic Auth diaktifkan pada '$HTACCESS_FILE'"
}

function disable_auth() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "[!] File konfigurasi tidak ditemukan. Batal."
        return
    fi

    readarray -t paths < "$CONFIG_FILE"
    HTPASSWD_FILE="${paths[0]}"
    HTACCESS_FILE="${paths[1]}"

    echo "[?] Yakin ingin menghapus file-file ini?"
    echo "    - $HTPASSWD_FILE"
    echo "    - $HTACCESS_FILE"
    echo "Ketik 'YA' untuk melanjutkan:"
    read -r confirm

    if [[ "$confirm" == "YA" ]]; then
        rm -f "$HTPASSWD_FILE" "$HTACCESS_FILE" "$CONFIG_FILE"
        echo "[+] Basic Auth dinonaktifkan dan file dihapus."
    else
        echo "[*] Batal."
    fi
}

function menu() {
    clear
    echo "=============================="
    echo "     Basic Auth Manager"
    echo "=============================="
    echo "1) Aktifkan Basic Auth"
    echo "2) Nonaktifkan Basic Auth"
    echo "0) Keluar"
    echo -n "Pilih opsi [0-2]: "
    read -r pilihan

    case $pilihan in
        1) enable_auth ;;
        2) disable_auth ;;
        0) echo "Keluar." ; exit 0 ;;
        *) echo "[!] Pilihan tidak valid." ;;
    esac
}

# Pastikan dijalankan sebagai root
require_sudo

# Looping menu
while true; do
    menu
    echo
    read -rp "Tekan ENTER untuk kembali ke menu..." _
done
