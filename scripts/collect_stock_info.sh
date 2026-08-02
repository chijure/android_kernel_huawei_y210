#!/bin/bash
# Dump the relevant stock-kernel driver information from the connected device.
# Usage: scripts/collect_stock_info.sh [serial]
set -euo pipefail

DEVICE_SERIAL="${1:-${ADB_SERIAL:-}}"
ADB_BIN="${ADB_BIN:-adb}"
OUT_DIR="${OUT_DIR:-stock-dump}"

ADB_CMD=("$ADB_BIN")
if [[ -n "$DEVICE_SERIAL" ]]; then
    ADB_CMD+=("-s" "$DEVICE_SERIAL")
fi

mkdir -p "$OUT_DIR"

echo "==> Enumerando dispositivos ADB"
"${ADB_CMD[@]}" devices

run_shell() {
    local cmd="$1"
    "${ADB_CMD[@]}" shell "$cmd"
}

run_root() {
    local cmd="$1"
    "${ADB_CMD[@]}" shell su -c "$cmd"
}

dump_cmd() {
    local label="$1"
    local cmd="$2"
    local outfile="$3"
    local require_root="${4:-1}"

    echo "==> ${label}"
    if [[ "$require_root" -eq 1 ]]; then
        run_root "$cmd" | tee "${OUT_DIR}/${outfile}"
    else
        run_shell "$cmd" | tee "${OUT_DIR}/${outfile}"
    fi
}

echo "==> Verificando acceso root (su)"
run_root "id"

dump_cmd "/proc/version" "cat /proc/version" "proc_version.txt"
dump_cmd "/proc/cmdline" "cat /proc/cmdline" "proc_cmdline.txt"
dump_cmd "/proc/modules" "cat /proc/modules" "proc_modules.txt"
dump_cmd "/proc/devices" "cat /proc/devices" "proc_devices.txt"
dump_cmd "/proc/bus/input/devices" "cat /proc/bus/input/devices" "input_devices.txt"
dump_cmd "/proc/interrupts" "cat /proc/interrupts" "interrupts.txt"
dump_cmd "Listado de drivers platform" "ls /sys/bus/platform/drivers" "platform_drivers.txt"
dump_cmd "Listado de dispositivos platform" "ls /sys/devices/platform" "platform_devices.txt"
dump_cmd "Framebuffer name" "cat /sys/class/graphics/fb0/name" "fb0_name.txt"
dump_cmd "Framebuffer modes" "cat /sys/class/graphics/fb0/modes" "fb0_modes.txt"
dump_cmd "Listado de /sys/class/graphics" "ls /sys/class/graphics" "graphics_class.txt"
dump_cmd "Driver MIPI NT35310 entries" "ls /sys/bus/platform/drivers/mipi_cmd_nt35310_hvga" "mipi_nt35310_driver.txt"
dump_cmd "dmesg completo" "dmesg" "dmesg-stock.txt"

echo "==> Recolección finalizada. Archivos guardados en ${OUT_DIR}"
