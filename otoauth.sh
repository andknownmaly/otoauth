#!/bin/bash

TARGET_DIR="/opt/lampp/htdocs"
HTPASSWD_PATH="/opt/lampp/.htpasswd"
USERNAME="admin"
PASSWORD="admin"

if ! command -v htpasswd &> /dev/null; then
    echo "[!] apache2-utils belum terpasang. Menginstal..."
    sudo apt-get update && sudo apt-get install apache2-utils -y
fi

echo "Creating file .htpasswd..."
htpasswd -bc "$HTPASSWD_PATH" "$USERNAME" "$PASSWORD"

echo "Creating file .htaccess in $TARGET_DIR..."
cat <<EOF > "$TARGET_DIR/.htaccess"
AuthType Basic
AuthName "Restricted Area"
AuthUserFile $HTPASSWD_PATH
Require valid-user
EOF

echo "Restarting LAMPP..."
sudo /opt/lampp/lampp restart

echo "Basic Auth Configured."
