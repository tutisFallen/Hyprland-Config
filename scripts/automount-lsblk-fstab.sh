#!/usr/bin/env bash
set -euo pipefail

# automount-lsblk-fstab.sh
# Adaptação para montar automaticamente partições listadas no lsblk
# via /etc/fstab, com integração de desktop (Thunar/GVFS).
#
# Uso:
#   sudo bash ~/scripts/automount-lsblk-fstab.sh
#   sudo bash ~/scripts/automount-lsblk-fstab.sh --dry-run

DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

if [[ $EUID -ne 0 ]]; then
  echo "Use como root: sudo bash $0 [--dry-run]"
  exit 1
fi

USER_NAME="${SUDO_USER:-tutis}"
UID_NUM="$(id -u "$USER_NAME")"
GID_NUM="$(id -g "$USER_NAME")"

FSTAB="/etc/fstab"
BACKUP="/etc/fstab.bak.$(date +%Y%m%d-%H%M%S)"
BASE_MNT="/mnt/auto"

mkdir -p "$BASE_MNT"

run() {
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "[dry-run] $*"
  else
    eval "$*"
  fi
}

is_system_uuid() {
  local uuid="$1"
  # já existe com ponto de montagem de sistema crítico
  grep -qE "UUID=${uuid}[[:space:]]+/( |$|home|boot|var|usr|opt)" "$FSTAB"
}

already_in_fstab() {
  local uuid="$1"
  grep -qE "^UUID=${uuid}[[:space:]]" "$FSTAB"
}

sanitize_name() {
  local raw="$1"
  echo "$raw" | tr ' ' '_' | tr -cd '[:alnum:]_.-'
}

echo "[1/6] Backup do fstab: $BACKUP"
run "cp '$FSTAB' '$BACKUP'"

echo "[2/6] Coletando partições do lsblk..."
mapfile -t PARTS < <(lsblk -rno PATH,TYPE | awk '$2=="part"{print $1}')

echo "[3/6] Avaliando partições..."
ADDED=0
for dev in "${PARTS[@]}"; do
  fstype="$(blkid -o value -s TYPE "$dev" 2>/dev/null || true)"
  uuid="$(blkid -o value -s UUID "$dev" 2>/dev/null || true)"
  label="$(blkid -o value -s LABEL "$dev" 2>/dev/null || true)"

  [[ -z "$fstype" || -z "$uuid" ]] && continue
  [[ "$fstype" == "swap" ]] && continue

  if is_system_uuid "$uuid"; then
    continue
  fi

  if already_in_fstab "$uuid"; then
    continue
  fi

  # ignora partições já montadas em pontos de sistema (extra segurança)
  current_target="$(findmnt -rn -S "UUID=$uuid" -o TARGET 2>/dev/null || true)"
  if [[ -n "$current_target" ]] && [[ "$current_target" =~ ^/(|home|boot|var|usr|opt)$ ]]; then
    continue
  fi

  name="$(sanitize_name "${label:-$uuid}")"
  mnt="${BASE_MNT}/${name}"
  run "mkdir -p '$mnt'"

  case "$fstype" in
    ntfs|ntfs3)
      type_use="ntfs3"
      opts="rw,uid=${UID_NUM},gid=${GID_NUM},umask=000,nofail,x-systemd.device-timeout=10,x-gvfs-show"
      pass="0"
      ;;
    exfat|vfat|fat|fat32|msdos)
      type_use="$fstype"
      opts="rw,uid=${UID_NUM},gid=${GID_NUM},umask=000,nofail,x-systemd.device-timeout=10,x-gvfs-show"
      pass="0"
      ;;
    ext4|ext3|ext2|xfs|btrfs)
      type_use="$fstype"
      opts="defaults,rw,nofail,x-systemd.device-timeout=10,x-gvfs-show"
      pass="2"
      ;;
    *)
      type_use="$fstype"
      opts="defaults,rw,nofail,x-systemd.device-timeout=10,x-gvfs-show"
      pass="2"
      ;;
  esac

  line="UUID=${uuid}  ${mnt}  ${type_use}  ${opts}  0  ${pass}"
  echo "  + $dev ($fstype) -> $mnt"
  run "printf '%s\n' '$line' >> '$FSTAB'"
  ADDED=$((ADDED+1))
done

echo "[4/6] Ajuste legado: removendo x-systemd.automount antigo do /etc/fstab"
run "sed -i 's/,x-systemd\\.automount//g' '$FSTAB'"

echo "[5/6] Recarregando systemd e montando"
run "systemctl daemon-reload"
run "mount -a"

echo "[6/6] Concluído. Entradas adicionadas: $ADDED"
if [[ $DRY_RUN -eq 1 ]]; then
  echo "(modo dry-run: nenhuma alteração real foi aplicada)"
fi
