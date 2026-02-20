#!/bin/sh

MOUNTPOINT="/mnt/data"
FSTAB_LINE="UUID=01DC07A56B39A350 /mnt/data ntfs-3g defaults,uid=1000,gid=1000,dmask=022,fmask=133 0 0"

# Verifica se está rodando como root
if [ "$(id -u)" -ne 0 ]; then
    echo "Execute como root (sudo)."
    exit 1
fi

# Cria diretório se não existir
if [ ! -d "$MOUNTPOINT" ]; then
    mkdir -p "$MOUNTPOINT"
    echo "Diretório $MOUNTPOINT criado."
else
    echo "Diretório $MOUNTPOINT já existe."
fi

# Adiciona linha ao fstab apenas se não existir
if ! grep -Fxq "$FSTAB_LINE" /etc/fstab; then
    echo "$FSTAB_LINE" >> /etc/fstab
    echo "Entrada adicionada ao /etc/fstab."
    systemctl daemon-reload
    mount -a
else
    echo "Entrada já existe no /etc/fstab."
fi


