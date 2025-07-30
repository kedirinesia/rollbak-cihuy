#!/bin/bash

# Script untuk testing deep link agenpayment://login
# Pastikan device Android terhubung dan aplikasi agenpayment sudah terinstall

echo "Testing Deep Link: agenpayment://login"
echo "======================================"

# Cek apakah device Android terhubung
if ! adb devices | grep -q "device$"; then
    echo "❌ Error: Tidak ada device Android yang terhubung"
    echo "Pastikan device terhubung dan USB debugging aktif"
    exit 1
fi

echo "✅ Device Android terdeteksi"
echo ""

# Test deep link
echo "🚀 Menjalankan deep link: agenpayment://login"
adb shell am start -W -a android.intent.action.VIEW -d "agenpayment://login" id.agenpayment.app

echo ""
echo "✅ Deep link berhasil dijalankan"
echo "Aplikasi seharusnya terbuka dan navigasi ke halaman login"
echo ""
echo "Untuk testing manual, buka browser dan ketik: agenpayment://login" 