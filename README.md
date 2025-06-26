# 🔐 Basic Auth Manager untuk Apache2 / LAMPP

Sebuah script Bash sederhana untuk mengaktifkan dan menonaktifkan **Basic Authentication** (`.htaccess` + `.htpasswd`) pada server **Apache2** atau **LAMPP**.

## 📦 Fitur
- Aktifkan Basic Auth hanya dengan beberapa input.
- Nonaktifkan dan hapus konfigurasi `.htaccess` dan `.htpasswd`.
- Mendukung input **path .htaccess**, **username**, dan **password** sesuai keinginan pengguna.
- Otomatis menyimpan konfigurasi path untuk kebutuhan disable.
- Kompatibel dengan server **Apache2 (Linux)** dan **LAMPP (XAMPP for Linux)**.

## ⚠️ Catatan Penting
Script ini **harus dijalankan dengan `sudo` atau sebagai root**.

## 🧰 Persyaratan
- OS: Linux (debian base)
- Apache2 atau LAMPP
- Package `apache2-utils` (script akan otomatis menginstalnya jika belum tersedia)

## 🚀 Cara Menjalankan

```bash
sudo ./otoauth.sh
