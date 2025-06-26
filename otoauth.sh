#!/bin/bash

#HTPASSWD_FILE="/opt/lampp/htdocs/.htpasswd"
#HTACCESS_FILE="/opt/lampp/htdocs/.htaccess"
#AUTH_USER="admin"
AUTH_REALM="Restricted Area"
SESSION_TIMEOUT=10800 # 3 jam dalam detik

function enable_auth() {
    echo "[*] Masukkan letak kamu menyimpan HTPASSWD"
    read -s HTPASSWD_FILE
    echo
    echo "[*] Masukkan letak root web"
    read -s HTACCESS_FILE
    echo
    echo "[*] Masukkan username"
    read -s AUTH_USER
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
    htpasswd -cb "$HTPASSWD_FILE.htpasswd" "$AUTH_USER" "$PASSWORD"

    # Buat .htaccess
    cat <<EOF > "$HTACCESS_FILE"
AuthType Basic
AuthName "$AUTH_REALM"
AuthUserFile "$HTPASSWD_FILE"
Require valid-user

# Simpan otentikasi di sisi browser selama 3 jam
Header set Cache-Control "private, max-age=$SESSION_TIMEOUT"
EOF

    echo "[+] Basic Auth diaktifkan di /"
}

function disable_auth() {
    echo "[*] Menghapus Basic Auth..."
    rm -f "$HTPASSWD_FILE" "$HTACCESS_FILE"
    echo "[+] Basic Auth dinonaktifkan"
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
    read pilihan

    case $pilihan in
        1)
            enable_auth
            ;;
        2)
            disable_auth
            ;;
        0)
            echo "Keluar."
            exit 0
            ;;
        *)
            echo "[!] Pilihan tidak valid."
            ;;
    esac
}

# Looping menu
while true; do
    menu
    echo
    read -p "Tekan ENTER untuk kembali ke menu..." _
done
