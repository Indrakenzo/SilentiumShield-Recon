#!/bin/bash

# ==============================================================================
# REPOSITORY: SILENTIUM SHIELD RECON FRAMEWORK
# AUTHOR    : INDRAYAZA Z, S.E
# TYPE      : AUTOMATED RECONNAISSANCE LAUNCHER
# ==============================================================================

# --- WARNA (Agar Tampilan Terminal Keren) ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m'
BOLD='\033[1m'

# --- BANNER UTAMA ---
function print_banner() {
    clear
    echo -e "${CYAN}======================================================================================${RESET}"
    echo -e "${YELLOW}${BOLD}                     INDRAYAZA Z, S.E - SILENTIUM SHIELD${RESET}"
    echo -e "${GREEN}   KONSULTAN BISNIS - VIRTUAL ASSISTEN AI (KOLABORASI HATI MANUSIA - LOGIKA KECERDASAN ROBOT)${RESET}"
    echo -e "${CYAN}======================================================================================${RESET}"
    echo -e "${BLUE}[*] Tool Otomatisasi Scanning & Reconnaissance Tingkat Lanjut${RESET}"
    echo -e "${BLUE}[*] Waktu Sistem : $(date)${RESET}"
    echo -e "${CYAN}======================================================================================${RESET}"
    echo ""
}

# --- CEK DEPENDENSI (Memastikan tools terinstall) ---
function check_tools() {
    echo -e "${YELLOW}[!] Mengecek ketersediaan tools...${RESET}"
    for tool in nmap nikto gobuster whatweb host whois; do
        if ! command -v $tool &> /dev/null; then
            echo -e "${RED}[X] $tool tidak ditemukan! Harap install dulu (sudo apt install $tool)${RESET}"
            exit 1
        fi
    done
    echo -e "${GREEN}[V] Semua tools siap digunakan!${RESET}"
    sleep 1
}

# --- LOGIKA SCANNING ---
function start_recon() {
    # Input Target
    echo -n -e "${BOLD}Masukan Domain Target (contoh: scanme.nmap.org): ${RESET}"
    read DOMAIN
    
    if [ -z "$DOMAIN" ]; then
        echo -e "${RED}[!] Target tidak boleh kosong!${RESET}"
        exit 1
    fi

    # Buat Folder Hasil
    DIR_DATE="results/${DOMAIN}_$(date +%Y%m%d_%H%M)"
    mkdir -p $DIR_DATE
    
    echo -e "\n${YELLOW}[+] Membuat folder hasil di: ${DIR_DATE}${RESET}"
    echo -e "${YELLOW}[+] Memulai Sequence 'SILENTIUM SHIELD'...${RESET}\n"

    # 1. IP Resolver & Whois
    echo -e "${CYAN}[1/5] MENCARI IP & DATA WHOIS...${RESET}"
    IP=$(host $DOMAIN | head -n 1 | awk '{print $4}')
    echo -e "${GREEN}[+] IP Target Terdeteksi: $IP${RESET}"
    whois $DOMAIN > $DIR_DATE/whois.txt

    # 2. Nmap (Network Scanning)
    echo -e "\n${CYAN}[2/5] MEMINDAI JARINGAN (NMAP)...${RESET}"
    nmap -sC -sV -O $IP -oN $DIR_DATE/nmap_scan.txt --stats-every 10s

    # 3. WhatWeb (Cek Teknologi)
    echo -e "\n${CYAN}[3/5] ANALISIS TEKNOLOGI WEBSITE...${RESET}"
    whatweb $DOMAIN --log-verbose=$DIR_DATE/whatweb.txt --color=never

    # 4. Nikto (Cek Kerentanan Web)
    echo -e "\n${CYAN}[4/5] MEMINDAI KERENTANAN WEB (NIKTO)...${RESET}"
    nikto -h $DOMAIN -output $DIR_DATE/nikto_scan.txt

    # 5. Gobuster (Cari Folder Tersembunyi)
    echo -e "\n${CYAN}[5/5] MENCARI DIREKTORI TERSEMBUNYI...${RESET}"
    WORDLIST="/usr/share/wordlists/dirb/common.txt"
    if [ -f "$WORDLIST" ]; then
        gobuster dir -u http://$DOMAIN -w $WORDLIST -o $DIR_DATE/gobuster.txt
    else
        echo -e "${RED}[!] Wordlist default tidak ditemukan, melewati Gobuster.${RESET}"
    fi

    # Penutup
    echo -e "\n${CYAN}=========================================================================${RESET}"
    echo -e "${GREEN}${BOLD}   MISI SELESAI. SEMUA DATA TERSIMPAN DI FOLDER: ${DIR_DATE} ${RESET}"
    echo -e "${CYAN}=========================================================================${RESET}"
}

# --- EKSEKUSI ---
print_banner
check_tools
start_recon
