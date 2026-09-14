#!/bin/bash

# Define usuário e diretório home (suporta execução via sudo)
REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(eval echo ~$REAL_USER)

# Função para exibir a arte ASCII e destacar a etapa atual
print_step() {
    echo -e "\n\033[38;5;33m▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄\033[0m"
    echo -e "\033[1;32m 🚀 ETAPA $1/8\033[0m ➔ \033[1;37m$2\033[0m"
    echo -e "\033[38;5;33m▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀\033[0m\n"
    sleep 1
}

# Arte de Cabeçalho Inicial
clear
echo -e "\033[1;32m"
echo "  _    _       _     _    _      _                  "
echo " | |  | |     (_)   | |  | |    (_)                 "
echo " | |  | | ___  _  __| |  | |     _ _ __  _   ___  __"
echo " | |/\| |/ _ \| |/ _\` |  | |    | | '_ \| | | \ \/ /"
echo " \  /\  / (_) | | (_| |  | |____| | | | | |_| |>  < "
echo "  \/  \/ \___/|_|\__,_|  |______|_|_| |_|\__,_/_/\_\\"
echo -e "\033[0m"
echo -e " \033[1;36mAutomação: Ambiente Grafico + AMD Drivers\033[0m"
echo -e " Usuário alvo: \033[1;33m$REAL_USER\033[0m\n"
sleep 2

print_step 1 "Instalando ambiente gráfico e drivers AMD"
sudo xbps-install -Syu
sudo xbps-install -y \
  wayland xorg-server-xwayland dbus mesa-dri vulkan-loader pipewire wireplumber bluez \
  niri seatd polkit polkit-gnome \
  xdg-desktop-portal xdg-desktop-portal-gnome \
  greetd tuigreet yazi nerd-fonts alacritty zellij \
  waybar mako swaybg swayidle \
  linux-firmware-amd vulkan-radeon amd-ucode mesa-vaapi

print_step 2 "Atualizando a imagem de inicialização (Initramfs)"
sudo xbps-reconfigure -f linux

print_step 3 "Ativando serviços runit e limpando conflitos do TTY1"
for svc in dbus polkitd seatd bluetoothd greetd; do
    sudo ln -sf /etc/sv/$svc /var/service/
done
sudo rm -f /var/service/agetty-tty1

print_step 4 "Configurando permissões de hardware (Seatd e Bluetooth)"
sudo usermod -aG bluetooth,_seatd $REAL_USER

print_step 5 "Configurando gerenciador de login (Tuigreet)"
sudo mkdir -p /etc/greetd
sudo tee /etc/greetd/config.toml > /dev/null <<EOF
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --cmd niri-session"
user = "_greetd"
EOF

print_step 6 "Preparando arquivos do Niri no diretório do usuário"
NIRI_DIR="$USER_HOME/.config/niri"
sudo -u $REAL_USER mkdir -p "$NIRI_DIR"

if [ -f /usr/share/doc/niri/config.kdl ]; then
    sudo -u $REAL_USER cp /usr/share/doc/niri/config.kdl "$NIRI_DIR/config.kdl"
else
    sudo -u $REAL_USER touch "$NIRI_DIR/config.kdl"
fi

print_step 7 "Injetando autostarts no arquivo de configuração do Niri"
sudo -u $REAL_USER tee -a "$NIRI_DIR/config.kdl" > /dev/null <<EOF

// Autostart 
spawn-at-startup "pipewire"
spawn-at-startup "wireplumber"
spawn-at-startup "/usr/libexec/polkit-gnome-authentication-agent-1"
spawn-at-startup "waybar"
spawn-at-startup "mako"
spawn-at-startup "swaybg" "-c" "#1e1e2e"
spawn-at-startup "swayidle" "-w" "timeout" "300" "niri msg action power-off-monitors"
EOF

print_step 8 "Gerando arquivo de configuração padrão do Zellij"
ZELLIJ_DIR="$USER_HOME/.config/zellij"
sudo -u $REAL_USER mkdir -p "$ZELLIJ_DIR"
sudo -u $REAL_USER zellij setup --dump-config | sudo -u $REAL_USER tee "$ZELLIJ_DIR/config.kdl" > /dev/null

echo -e "\n\033[1;32m ████████████████████████████████████████████████████████\033[0m"
echo -e " \033[1;32m▶ INSTALAÇÃO CONCLUÍDA COM SUCESSO!\033[0m"
echo -e "\033[1;32m ████████████████████████████████████████████████████████\033[0m"
echo -e "\n Reinicie a máquina com \033[1;33msudo reboot\033[0m para aplicar as alterações."
