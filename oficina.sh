#!/bin/bash

# --- 1. CONFIGURAÇÃO DE AMBIENTE E CORES ---
termux-setup-storage
sleep 1

BASE_DIR="$HOME/Oficina_Dados"
PASTA_DB="$BASE_DIR/Banco"
PASTA_PDF="/sdcard/Documents/Oficina_PDFs"
PASTA_BACKUP_LOCAL="/sdcard/Documents/Backup_Oficina"
ARQUIVO_LOG_SYNC="/tmp/last_sync.txt"

mkdir -p "$PASTA_DB" "$PASTA_PDF" "$PASTA_BACKUP_LOCAL"
echo "Nunca" > "$ARQUIVO_LOG_SYNC"

# Arquivos de Dados
ARQUIVO_DB="$PASTA_DB/historico_revisoes.csv"
ARQUIVO_ESTOQUE="$PASTA_DB/estoque.csv"
ARQUIVO_MAQUINAS="$PASTA_DB/maquinas.csv"

# Cores e Estilo
AMARELO='\033[1;33m'
AZUL='\033[1;34m'
VERDE='\033[0;32m'
VERMELHO='\033[0;31m'
NC='\033[0m' 
LARGURA_IMPRESSAO="580" 

# Inicializa CSVs se vazios
[ ! -f "$ARQUIVO_DB" ] && echo "DATA;PATRIMONIO;MODELO;PECAS;OBS" > "$ARQUIVO_DB"
[ ! -f "$ARQUIVO_ESTOQUE" ] && echo "CODIGO;DESCRICAO;QTD" > "$ARQUIVO_ESTOQUE"
[ ! -f "$ARQUIVO_MAQUINAS" ] && echo "PATRIMONIO;MODELO;DESCRICAO;UNIDADE" > "$ARQUIVO_MAQUINAS"

# --- 2. FUNÇÕES DE SISTEMA ---

imprimir_zpl() {
    CONTEUDO=$1
    echo -e "$CONTEUDO" > "$HOME/temp_print.zpl"
    termux-am broadcast -a ru.a402d.rawbtprint.action.PRINT \
        -e "base64" "$(base64 -w 0 "$HOME/temp_print.zpl")" > /dev/null
    echo ">>> Enviado para a ISD-12 (RawBT)"
}

sincronizar_nuvem_inicial() {
    echo -e "${AZUL}Verificando nuvem (Google Drive)...${NC}"
    if rclone copy gdrive:Pasta_Oficina_Drive "$BASE_DIR" --update; then
        echo -e "${VERDE}[OK] Banco de Dados atualizado!${NC}"
        date +"%H:%M:%S" > "$ARQUIVO_LOG_SYNC"
    else
        echo -e "${AMARELO}[!] Modo Offline: Nuvem inacessível.${NC}"
    fi
    sleep 1
}

auto_backup_nuvem() {
    while true; do
        sleep 300 
        if rclone sync "$BASE_DIR/" gdrive:Pasta_Oficina_Drive --quiet > /dev/null 2>&1; then
            date +"%H:%M:%S" > "$ARQUIVO_LOG_SYNC"
        else
            echo -e "ERRO-$(date +"%H:%M")" > "$ARQUIVO_LOG_SYNC"
            echo -e "\a" # Beep de alerta se falhar
        fi
    done
}

# --- 3. INÍCIO DO PROCESSO ---
sincronizar_nuvem_inicial
auto_backup_nuvem &
PID_BACKUP=$!

# --- 4. MENU PRINCIPAL ---
while true; do
    clear
    LARGURA_TELA=$(tput cols)
    TITULO=" SISTEMA MARQUES v10.0 - OFICINA (TAB A11) "
    printf "%${LARGURA_TELA}s\n" | tr " " "="
    printf "%$(((LARGURA_TELA+${#TITULO})/2))s\n" "$TITULO"
    printf "%${LARGURA_TELA}s\n" | tr " " "="
    
    echo -e "${AZUL}  MOVIMENTAÇÃO E BUSCA              ESTOQUE E FROTA${NC}"
    echo "  -----------------------           -----------------------"
    printf "  1. %-25s  8. %-25s\n" "BUSCAR HISTÓRICO" "CONSULTAR ESTOQUE (Tela)"
    printf "  2. ${VERDE}%-22s${NC}  9. %-25s\n" "NOVA REVISÃO (Baixa)" "IMPRIMIR SALDO (Ticket)"
    printf "  3. %-25s  10. %-25s\n" "RELATÓRIO MENSAL" "CADASTRAR MÁQUINA"
    printf "  4. %-25s  11. %-25s\n" "GERAR RELATÓRIO TXT" "RELATÓRIO POR UNIDADE"
    printf "  5. %-25s  12. ${AMARELO}%-22s${NC}\n" "ETIQUETA PRATELEIRA" "SAIR E BACKUP NUVEM"
    printf "  6. %-25s  13. %-25s\n" "ENTRADA DE MATERIAL" "TESTAR IMPRESSORA"
    printf "  7. %-25s  14. %-25s\n" "FOLHA INVENTÁRIO" "TERMO ENCERRAMENTO"
    
    STATUS_ATUAL=$(cat "$ARQUIVO_LOG_SYNC")
    echo -e "  --------------------------------------------------------"
    if [[ "$STATUS_ATUAL" == ERRO* ]]; then
        echo -e "  ${VERMELHO}STATUS NUVEM: FALHA NA CONEXÃO (${STATUS_ATUAL/ERRO-/})${NC}"
    else
        echo -e "  ${VERDE}STATUS NUVEM: Sincronizado às $STATUS_ATUAL${NC}"
    fi
    echo -ne "  ${AMARELO}AGUARDANDO COMANDO (1-14):${NC} "
    read OPCAO

    case $OPCAO in
        1) read -p "Patrimônio: " B; grep -i "$B" "$ARQUIVO_DB" | column -s ';' -t; read -p "Enter..." ;;
        2) read -p "Nº Patrimônio: " PAT
           MAQ=$(grep -i "^$PAT;" "$ARQUIVO_MAQUINAS")
           if [ -n "$MAQ" ]; then 
               MOD=$(echo "$MAQ" | cut -d';' -f2); DES=$(echo "$MAQ" | cut -d';' -f3); UNI=$(echo "$MAQ" | cut -d';' -f4)
               echo -e "${VERDE}Máquina: $DES ($MOD) | Setor: $UNI${NC}"
           else read -p "Modelo: " MOD; read -p "Descrição: " DES; UNI="N/A"; fi
           read -p "Obs: " OBS
           CUPOM="^XA^PW$LARGURA_IMPRESSAO^LL1000^CI28^FO30,50^CF0,35^FDMAQUINA: $DES^FS^FO30,90^FDMOD: $MOD | PAT: $PAT^FS"
           CUPOM+="^CF0,25^FO30,140^FDDATA: $(date +%d/%m/%Y)^FS^FO30,170^GB$((LARGURA_IMPRESSAO-60)),2,2^FS"
           P_LOG=""; L=210
           while true; do
               read -p "Cód. Peça (Vazio p/ sair): " C_P; [ -z "$C_P" ] && break
               read -p "Qtd: " Q_U; EX=$(grep -i "^$C_P;" "$ARQUIVO_ESTOQUE")
               if [ -n "$EX" ]; then
                   D_E=$(echo "$EX" | cut -d';' -f2); Q_E=$(echo "$EX" | cut -d';' -f3)
                   if [ "$Q_E" -ge "$Q_U" ]; then
                       N_Q=$((Q_E - Q_U)); sed -i "/^$C_P;/d" "$ARQUIVO_ESTOQUE"; echo "$C_P;$D_E;$N_Q" >> "$ARQUIVO_ESTOQUE"
                       CUPOM+="^FO30,$L^FD- $D_E^FS^FO$((LARGURA_IMPRESSAO-120)),$L^FD$Q_U un^FS"
                       [ "$N_Q" -lt 3 ] && { let L=L+30; CUPOM+="^FO30,$L^GB$((LARGURA_IMPRESSAO-60)),35,2^FS^FO40,$((L+5))^CF0,20^FD*REPOR: SALDO $N_Q*^FS"; 
                       echo -e "${VERMELHO}ALERTA: Estoque Crítico ($N_Q)!${NC}"; }
                       P_LOG+="$D_E($Q_U) "; let L=L+45
                   else echo "SALDO INSUFICIENTE!"; fi
               else echo "PEÇA NÃO CADASTRADA!"; fi
           done
           CUPOM+="^XZ"; echo "$(date +%d/%m/%Y);$PAT;$MOD;$P_LOG;$OBS" >> "$ARQUIVO_DB"; imprimir_zpl "$CUPOM"; read -p "OK. Enter..." ;;
        3) read -p "Mês/Ano (MM/AAAA): " M_R; grep "$M_R" "$ARQUIVO_DB" | column -s ';' -t; read -p "Enter..." ;;
        4) read -p "Mês/Ano: " M_R; N_TXT="$PASTA_PDF/Rel_${M_R//\//-}.txt"
           echo -e "OFICINA MARQUES - RELATÓRIO $M_R\n" > "$N_TXT"
           grep "$M_R" "$ARQUIVO_DB" | column -s ';' -t >> "$N_TXT"
           echo "Salvo em: Documents/Oficina_PDFs"; sleep 2 ;;
        5) read -p "Peça: " N_P; read -p "Cód: " C_B; ETI="^XA^PW$LARGURA_IMPRESSAO^LL400^FO20,20^GB$((LARGURA_IMPRESSAO-40)),360,4^FS^CF0,50^FO40,110^FD${N_P^^}^FS^CF0,35^FO40,220^FDCOD: $C_B^FS^FO40,270^BY2^BCN,70,Y,N,N^FD${C_B//./}^FS^XZ"; imprimir_zpl "$ETI"; read -p "Enter..." ;;
        6) read -p "Cód: " C_N; read -p "Desc: " D_N; read -p "Qtd: " Q_N; EX=$(grep -i "^$C_N;" "$ARQUIVO_ESTOQUE"); if [ -z "$EX" ]; then echo "$C_N;$D_N;$Q_N" >> "$ARQUIVO_ESTOQUE"; else Q_A=$(echo "$EX" | cut -d';' -f3); T_Q=$((Q_A + Q_N)); sed -i "/^$C_N;/d" "$ARQUIVO_ESTOQUE"; echo "$C_N;$D_N;$T_Q" >> "$ARQUIVO_ESTOQUE"; fi; echo "Estoque Atualizado!"; sleep 1 ;;
        7) echo "Gerando Folha Inventário..."; LIS="^XA^PW$LARGURA_IMPRESSAO^LL3000^CI28^FO30,50^CF0,45^FDFOLHA INVENTARIO - $(date +%d/%m/%Y)^FS^FO30,110^GB$((LARGURA_IMPRESSAO-60)),3,3^FS"; V_L=170; while IFS=';' read -r C D Q; do [[ "$C" == "CODIGO" ]] && continue; LIS+="^FO30,$V_L^FD$D^FS^FO$((LARGURA_IMPRESSAO-150)),$V_L^FD$Q^FS^FO$((LARGURA_IMPRESSAO-80)),$V_L^FD____^FS"; let V_L=V_L+40; done < "$ARQUIVO_ESTOQUE"; LIS+="^XZ"; imprimir_zpl "$LIS"; read -p "Enter..." ;;
        8) read -p "Busca Peça: " T; grep -i "$T" "$ARQUIVO_ESTOQUE" | column -s ';' -t; read -p "Enter..." ;;
        9) read -p "Busca: " T_I; RES=$(grep -i "$T_I" "$ARQUIVO_ESTOQUE" | head -n 1); if [ -n "$RES" ]; then C_EX=$(echo "$RES" | cut -d';' -f1); D_EX=$(echo "$RES" | cut -d';' -f2); Q_EX=$(echo "$RES" | cut -d';' -f3); TIC="^XA^PW$LARGURA_IMPRESSAO^LL300^CI28^FO30,50^GB$((LARGURA_IMPRESSAO-60)),200,3^FS^CF0,45^FO50,100^FD$D_EX^FS^CF0,35^FO50,175^FDCOD: $C_EX^FS^CF0,50^FO$((LARGURA_IMPRESSAO-200)),170^FDQTD: $Q_EX^FS^XZ"; imprimir_zpl "$TIC"; fi; read -p "Enter..." ;;
        10) read -p "Patrimônio: " C_P; read -p "Modelo: " C_M; read -p "Desc: " C_D; read -p "Unidade: " C_U; echo "$C_P;$C_M;$C_D;$C_U" >> "$ARQUIVO_MAQUINAS"; echo "Máquina Cadastrada!"; sleep 1 ;;
        11) read -p "Unidade: " B_U; grep -i "$B_U" "$ARQUIVO_MAQUINAS" | column -s ';' -t; read -p "Enter..." ;;
        12) echo "Encerrando e sincronizando nuvem..."
            kill $PID_BACKUP 2>/dev/null
            rclone sync "$BASE_DIR/" gdrive:Pasta_Oficina_Drive && echo "[OK] Nuvem Atualizada."
            cp -r "$BASE_DIR/"* "$PASTA_BACKUP_LOCAL/" && echo "[OK] Backup Local Feito."
            sleep 1; exit ;;
        13) imprimir_zpl "^XA^FO50,50^CF0,40^FDTESTE OK - ISD-12^FS^XZ" ;;
        14) T_E="^XA^PW$LARGURA_IMPRESSAO^LL600^CI28^FO20,20^GB$((LARGURA_IMPRESSAO-40)),550,4^FS^CF0,50^FO50,80^FDTERMO DE ENCERRAMENTO^FS^CF0,30^FO50,200^FDDATA: $(date +%d/%m/%Y)^FS^FO50,250^FDInventario Concluido no Tab A11.^FS^FO100,450^GB300,2,2^FS^FO120,480^FDMARQUES^FS^XZ"; imprimir_zpl "$T_E"; read -p "Termo impresso. Enter..." ;;
    esac
done
