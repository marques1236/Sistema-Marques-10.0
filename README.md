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

markdown

# 🛠️ Sistema Marques v10.0 - Gestão de Frota

Sistema de automação para oficinas e gestão de frotas, desenvolvido em **Bash Script**. O foco é a agilidade no lançamento de revisões, controle de estoque e emissão de tickets de serviço (térmicos), com sincronização automática em nuvem.

## 🚀 Funcionalidades
- **Controle de Estoque:** Baixa automática de peças no lançamento da revisão.
- **Histórico de Máquinas:** Consulta rápida por patrimônio.
- **Impressão de Tickets:** Suporte para impressoras térmicas via USB (Linux) ou Bluetooth/Rede (Android via RawBT).
- **Backup em Nuvem:** Sincronização em tempo real com Google Drive via Rclone.
- **Relatórios:** Geração de arquivos TXT mensais e por unidade.

## 📋 Pré-requisitos

Para que o script funcione perfeitamente, você precisará instalar as seguintes dependências:

### No Linux (Ubuntu/Debian/Raspberry Pi):
```bash
sudo apt update
sudo apt install rclone bsdmainutils -y

Use o código com cuidado.
bsdmainutils fornece o comando column, usado para formatar as tabelas no terminal.
No Android (Termux):

    Instale o app Termux.
    Instale o app RawBT (para impressão).
    No Termux, execute:

bash

pkg install rclone termux-api -y

Use o código com cuidado.
⚙️ Configuração do Backup (Google Drive)
O script utiliza o Rclone. Antes de rodar, você deve configurar o acesso ao seu drive:

    Digite rclone config.
    Crie um novo "remote" com o nome exato de gdrive.
    Siga as instruções na tela para autorizar sua conta Google.

📂 Estrutura de Pastas
O sistema organiza os dados automaticamente em:

    ~/Oficina_Dados/Banco/: Arquivos CSV (Banco de dados).
    ~/Oficina_Dados/PDFs/: Relatórios gerados.

⚖️ Licença
Este projeto está sob a licença GNU GPLv3. Isso significa que o software é livre para uso, modificação e distribuição, garantindo que o código permaneça aberto e acessível a todos, sem custos de licenciamento.
Desenvolvido por: Luís Pedro Pereira Marques

