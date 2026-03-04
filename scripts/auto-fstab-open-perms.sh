#!/usr/bin/env bash
set -euo pipefail

# auto-fstab-open-perms.sh
# Gera entradas no /etc/fstab para discos de dados
# e monta em /mnt/auto/<label_ou_uuid>

if [[ $EUID -ne 0 ]]; then
  echo "Execute como root: sudo bash $0"
  exit 1
fi

USER_NAME="${SUDO_USER:-tutis}"
UID_NUM="$(id -u "$USER_NAME")"
GID_NUM="$(id -g "$USER_NAME")"

FSTAB="/etc/fstab"
BACKUP="/etc/fstab.bak.$(date +%Y%m%d-%H%M%S)"

echo "[1/5] Backup do fstab em: $BACKUP"
cp "$FSTAB" "$BACKUP"

echo "[2/5] Detectando partições..."
mapfile -t PARTS < <(lsblk -rno NAME,TYPE | awk '$2=="part"{print $1}')

echo "[3/5] Gerando entradas..."
for p in "${PARTS[@]}"; do
  DEV="/dev/$p"

  # ignora swap
  FSTYPE="$(blkid -o value -s TYPE "$DEV" 2>/dev/null || true)"
  [[ -z "$FSTYPE" ]] && continue
  [[ "$FSTYPE" == "swap" ]] && continue

  # ignora partições já usadas pelo sistema no fstab (/, /home, /boot etc)
  UUID="$(blkid -o value -s UUID "$DEV" 2>/dev/null || true)"
  [[ -z "$UUID" ]] && continue
  if grep -qE "UUID=$UUID[[:space:]]+/( |$|home|boot|var|usr|opt)" "$FSTAB"; then
    continue
  fi

  # ignora se já existe no fstab
  if grep -q "UUID=$UUID" "$FSTAB"; then
    continue
  fi

  LABEL_RAW="$(blkid -o value -s LABEL "$DEV" 2>/dev/null || true)"
  LABEL_SAFE="$(echo "${LABEL_RAW:-$UUID}" | tr ' ' '_' | tr -cd '[:alnum:]_.-')"
  MNT="/mnt/auto/$LABEL_SAFE"
  mkdir -p "$MNT"

  # opções por filesystem
  case "$FSTYPE" in
    ntfs|ntfs3)
      OPTS="rw,uid=$UID_NUM,gid=$GID_NUM,umask=000,nofail,x-systemd.device-timeout=10,x-gvfs-show"
      TYPE_USE="ntfs3"
      PASS="0"
      ;;
    exfat|vfat|fat|fat32|msdos)
      OPTS="rw,uid=$UID_NUM,gid=$GID_NUM,umask=000,nofail,x-systemd.device-timeout=10,x-gvfs-show"
      TYPE_USE="$FSTYPE"
      PASS="0"
      ;;
    ext4|ext3|ext2|xfs|btrfs)
      OPTS="defaults,rw,nofail,x-systemd.device-timeout=10,x-gvfs-show"
      TYPE_USE="$FSTYPE"
      PASS="2"
      ;;
    *)
      # fallback genérico
      OPTS="defaults,rw,nofail,x-systemd.device-timeout=10,x-gvfs-show"
      TYPE_USE="$FSTYPE"
      PASS="2"
      ;;
  esac

  echo "UUID=$UUID  $MNT  $TYPE_USE  $OPTS  0  $PASS" >> "$FSTAB"
  echo "  + $DEV ($FSTYPE) -> $MNT"
done

echo "[4/5] Testando fstab..."
mount -a

echo "[5/5] Concluído."
echo "Agora os discos vão montar automaticamente no boot."
