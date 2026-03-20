# Sistema-Marques-10.0
Versão 10.0 otimizada para Tab A11
# 🛠️ Sistema Marques v10.0 - Gestão de Oficina

Sistema em Bash para controle de frota, estoque e revisões, otimizado para Android (Termux) e Tablets.

## 📋 Pré-requisitos
1. Instalar o **Termux** e **Termux:API**.
2. Instalar as dependências: `pkg install util-linux rclone termux-api`
3. Configurar o Rclone: `rclone config` (nome do remote: `gdrive`).

## 🚀 Como instalar
1. Baixe o script: `curl -O https://raw.githubusercontent.com`
2. Dê permissão: `chmod +x oficina.sh`
3. Execute: `./oficina.sh`

## 📂 Estrutura de Arquivos
- `oficina.sh`: Script principal.
- `Banco/`: Onde ficam os arquivos .csv (Estoque, Máquinas e Histórico).
