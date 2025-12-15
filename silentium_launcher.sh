#!/bin/bash

# ==============================================================================
# REPOSITORY: SILENTIUM SHIELD RECON FRAMEWORK V2.0 (TURBO EDITION)
# AUTHOR    : INDRAYAZA Z, S.E
# TYPE      : AUTOMATED RECONNAISSANCE LAUNCHER
# ==============================================================================

# --- WARNA ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m'
BOLD='\033[1m'

# --- BANNER ---
function print_banner() {
    clear
    echo -e "${CYAN}======================================================================================${RESET}"
    echo -e "${YELLOW}${BOLD}                     INDRAYAZA Z, S.E - SILENTIUM SHIELD${RESET}"
    echo -e "${GREEN}   KONSULTAN BISNIS - VIRTUAL ASSISTEN AI (KOLABORASI HATI MANUSIA - LOGIKA KECERDASAN ROBOT)${RESET}"
    echo -e "${CYAN}======================================================================================${RESET}"
    echo -e "${BLUE}[*] Tool Otomatisasi Scanning & Reconnaissance (Versi 2.0 - Optimized)${RESET}"
    echo -e "${CYAN}======================================================================================${RESET}"
    echo ""
}

# --- AUTO INSTALL DEPENDENSI (Agar Script Anti-Ribet) ---
function check_tools() {
    echo -e "${YELLOW}[!] Mengecek kelengkapan sistem...${RESET}"
    deps=(nmap nikto gobuster whatweb host whois curl)
    
    for tool in "${deps[@]}"; do
        if ! command -v $tool &> /dev/null; then
            echo -e "${RED}[X] $tool tidak ditemukan! Mencoba install otomatis...${RESET}"
            if [ "$tool" == "host" ]; then
                sudo apt install -y dnsutils
            else
                sudo apt install -y $tool
            fi
        fi
    done
    echo -e "${GREEN}[V] Sistem Siap Tempur!${RESET}"
    sleep 1
}

# --- LOGIKA UTAMA ---
function start_recon() {
    # 1. Input Target
    echo -n -e "${BOLD}Masukan Domain Target (contoh: scanme.nmap.org): ${RESET}"
    read DOMAIN
    if [ -z "$DOMAIN" ]; then echo -e "${RED}Target kosong!${RESET}"; exit 1; fi

    # 2. Pilihan Mode Kecepatan
    echo -e "\n${BOLD}Pilih Mode Scanning:${RESET}"
    echo -e "${CYAN}[1] TURBO MODE${RESET} (Cepat: 1-3 Menit. Scan Port Utama, No Nikto, Fast Gobuster)"
    echo -e "${CYAN}[2] DEEP MODE ${RESET} (Lama: 10-20 Menit. Full Nmap, Nikto, Deep Gobuster)"
    echo -n -e "Pilihan Anda (1/2): "
    read MODE

    DIR_DATE="results/${DOMAIN}_$(date +%Y%m%d_%H%M)"
    mkdir -p $DIR_DATE
    
    echo -e "\n${YELLOW}[+] Target: $DOMAIN | Output: $DIR_DATE${RESET}"

    # --- PHASE 1: RESOLVING ---
    IP=$(host $DOMAIN | head -n 1 | awk '{print $4}')
    echo -e "${GREEN}[+] IP: $IP${RESET}"
    whois $DOMAIN > $DIR_DATE/whois.txt

    # --- PHASE 2: NMAP (Dioptimalkan) ---
    echo -e "\n${CYAN}[PHASE 1] NETWORK SCANNING (NMAP)${RESET}"
    if [ "$MODE" == "1" ]; then
        # Turbo: Hanya scan 1000 port teratas, Timing T4 (Aggressive), Tanpa DNS resolution (-n)
        echo -e "${YELLOW}[*] Menjalankan Nmap Turbo Mode...${RESET}"
        nmap -T4 -F -n $IP -oN $DIR_DATE/nmap_fast.txt
    else
        # Deep: Scan Service Version, OS, Script, Timing T4
        echo -e "${YELLOW}[*] Menjalankan Nmap Deep Mode (Sabar ya...)${RESET}"
        nmap -sC -sV -O -T4 $IP -oN $DIR_DATE/nmap_full.txt
    fi

    # --- PHASE 3: WEB RECON ---
    echo -e "\n${CYAN}[PHASE 2] WEB TECHNOLOGY${RESET}"
    whatweb $DOMAIN --log-verbose=$DIR_DATE/whatweb.txt --color=never

    # --- PHASE 4: VULNERABILITY (NIKTO) ---
    if [ "$MODE" == "2" ]; then
        echo -e "\n${CYAN}[PHASE 3] NIKTO VULN SCAN${RESET}"
        echo -e "${YELLOW}[!] Membatasi waktu scan Nikto maks 10 menit agar tidak hang...${RESET}"
        # -maxtime 10m: Berhenti paksa jika lebih dari 10 menit
        nikto -h $DOMAIN -maxtime 10m -output $DIR_DATE/nikto_scan.txt
    else
        echo -e "\n${YELLOW}[!] Skip Nikto di Turbo Mode (Hemat Waktu)${RESET}"
    fi

    # --- PHASE 5: GOBUSTER (Dipercepat) ---
    echo -e "\n${CYAN}[PHASE 4] DIRECTORY HUNTING${RESET}"
    WORDLIST="/usr/share/wordlists/dirb/common.txt"
    
    if [ -f "$WORDLIST" ]; then
        if [ "$MODE" == "1" ]; then
            # Turbo: 50 Threads, Timeout cepat
            gobuster dir -u http://$DOMAIN -w $WORDLIST -t 50 --timeout 2s -o $DIR_DATE/gobuster.txt
        else
            # Deep: 20 Threads (Lebih teliti), Timeout standar
            gobuster dir -u http://$DOMAIN -w $WORDLIST -t 20 -o $DIR_DATE/gobuster.txt
        fi
    else
        echo -e "${RED}[!] Wordlist tidak ditemukan.${RESET}"
    fi

    echo -e "\n${GREEN}${BOLD}SELESAI. DATA TERSIMPAN DI FOLDER: ${DIR_DATE} ${RESET}"
}

print_banner
check_tools
start_recon
