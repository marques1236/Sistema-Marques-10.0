#!/bin/bash

# CORES PARA O TERMINAL
VERDE='\033[0;32m'; NC='\033[0m'; AMARELO='\033[1;33m'

echo -e "${AMARELO}--- INICIANDO INSTALAÇÃO DO SISTEMA MARQUES 10.0 ---${NC}"

# 1. DETECTAR O SISTEMA
if [ -d "/data/data/com.termux" ]; then
    echo "Detectado: Ambiente Termux (Android)"
    pkg update && pkg upgrade -y
    pkg install rclone bsdmainutils termux-api -y
else
    echo "Detectado: Ambiente Linux (PC/Servidor)"
    sudo apt update
    sudo apt install rclone bsdmainutils -y
fi

# 2. CRIAR ESTRUTURA DE PASTAS
echo -e "${VERDE}Criando pastas em ~/Oficina_Dados...${NC}"
mkdir -p ~/Oficina_Dados/Banco ~/Oficina_Dados/PDFs

# 3. VERIFICAR RCLONE
echo -e "${AMARELO}IMPORTANTE: Para o backup funcionar, você deve configurar o Google Drive.${NC}"
echo "Deseja configurar o Rclone agora? (s/n)"
read -r RESP
if [[ "$RESP" =~ ^([sS][iI]|[sS])$ ]]; then
    rclone config
fi

echo -e "${VERDE}====================================================${NC}"
echo -e "Instalação concluída! Coloque seu script na pasta inicial."
echo -e "Para rodar: bash sistema_marques.sh"
echo -e "${VERDE}====================================================${NC}"
