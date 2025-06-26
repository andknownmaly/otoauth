#!/bin/bash

AUTH_REALM="Restricted Area"
SESSION_TIMEOUT=10800  # 3 jam dalam detik

function enable_auth() {
    mkdir /opt/otoauth
    #echo "[*] Masukkan path lengkap untuk menyimpan file .htpasswd (contoh: /opt/lampp/htdocs/.htpasswd)"
    #read -r HTPASSWD_FILE
    #echo
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

    # Buat .htpasswd
    echo "[*] Membuat file .htpasswd..."
    htpasswd -cb "$HTPASSWD_FILE" "$AUTH_USER" "$PASSWORD"

    # Cek kalau .htaccess sudah ada
    if [ -f "$HTACCESS_FILE" ]; then
        echo "[!] File .htaccess sudah ada. Timpa isinya? (y/n)"
        read -r confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            echo "[*] Batal."
            return
        fi
    fi

    # Buat .htaccess
    echo "[*] Menulis konfigurasi Basic Auth ke .htaccess..."
    cat <<EOF > "$HTACCESS_FILE"
AuthType Basic
AuthName "$AUTH_REALM"
AuthUserFile $HTPASSWD_FILE
Require valid-user

# Simpan otentikasi di sisi browser selama 3 jam
Header set Cache-Control "private, max-age=$SESSION_TIMEOUT"
EOF

    echo "[+] Basic Auth diaktifkan pada '$HTACCESS_FILE'"
}

function disable_auth() {
    echo "[*] Masukkan path file .htpasswd yang ingin dihapus:"
    read -r HTPASSWD_FILE
    echo "[*] Masukkan path file .htaccess yang ingin dihapus:"
    read -r HTACCESS_FILE

    echo "[?] Yakin ingin menghapus file-file ini?"
    echo "    - $HTPASSWD_FILE"
    echo "    - $HTACCESS_FILE"
    echo "Ketik 'YA' untuk melanjutkan:"
    read -r confirm

    if [[ "$confirm" == "YA" ]]; then
        rm -f "$HTPASSWD_FILE" "$HTACCESS_FILE"
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

# Looping menu
while true; do
    menu
    echo
    read -rp "Tekan ENTER untuk kembali ke menu..." _
done
