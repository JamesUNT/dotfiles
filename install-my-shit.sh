#!/bin/bash

# Define usuário e diretório home (suporta execução via sudo)
REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(eval echo ~$REAL_USER)

# 1. Adiciona repositório comunitário
echo "repository=https://repo.voiders.dev" | sudo tee /etc/xbps.d/10-voiders-community.conf

# 2. Atualiza pacotes e instala ambiente gráfico base, Noctalia e Zellij
sudo xbps-install -Syu
sudo xbps-install -y \
  wayland xorg-server-xwayland dbus mesa-dri vulkan-loader pipewire wireplumber bluez \
  niri seatd polkit polkit-gnome \
  xdg-desktop-portal xdg-desktop-portal-gnome \
  greetd tuigreet yazi nerd-fonts alacritty noctalia zellij

# 3. Ativa serviços no runit
for svc in dbus polkitd seatd bluetoothd greetd; do
    sudo ln -sf /etc/sv/$svc /var/service/
done

# 4. Configura permissões de hardware (Corrigido espaçamento na lista de grupos)
sudo usermod -aG bluetooth,_seatd $REAL_USER

# 5. Configura login via tuigreet
sudo mkdir -p /etc/greetd
sudo tee /etc/greetd/config.toml > /dev/null <<EOF
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --cmd niri-session"
user = "_greetd"
EOF

# 6. Prepara arquivos do Niri
NIRI_DIR="$USER_HOME/.config/niri"
sudo -u $REAL_USER mkdir -p "$NIRI_DIR"

if [ -f /usr/share/doc/niri/config.kdl ]; then
    sudo -u $REAL_USER cp /usr/share/doc/niri/config.kdl "$NIRI_DIR/config.kdl"
else
    sudo -u $REAL_USER touch "$NIRI_DIR/config.kdl"
fi

# 7. Adiciona autostart no Niri
sudo -u $REAL_USER tee -a "$NIRI_DIR/config.kdl" > /dev/null <<EOF

// Autostart 
spawn-at-startup "pipewire"
spawn-at-startup "wireplumber"
spawn-at-startup "/usr/libexec/polkit-gnome-authentication-agent-1"
spawn-at-startup "noctalia"
EOF

# 8. Configura o Zellij
ZELLIJ_DIR="$USER_HOME/.config/zellij"
sudo -u $REAL_USER mkdir -p "$ZELLIJ_DIR"

# Gera o arquivo de configuração (config.kdl) com os padrões do Zellij
sudo -u $REAL_USER zellij setup --dump-config | sudo -u $REAL_USER tee "$ZELLIJ_DIR/config.kdl" > /dev/null

echo "Instalação concluída! Reinicie a máquina para aplicar."
