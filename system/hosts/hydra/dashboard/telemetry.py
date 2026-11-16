import glob
import json
import os
import socket
import subprocess
import sys
import time

STATE_DIR = "/run/hydra-dashboard"
PREV_CPU = os.path.join(STATE_DIR, "cpu-prev")
OUT_FILE = os.path.join(STATE_DIR, "status.json")
TMP_FILE = os.path.join(STATE_DIR, "status.json.tmp")


def load_config(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def sample_cpu():
    with open("/proc/stat", encoding="utf-8") as f:
        parts = f.readline().split()
    vals = [int(x) for x in parts[1:9]]
    return sum(vals), vals[3] + vals[4]


def read_cpu_percent():
    total, idle = sample_cpu()
    p_total, p_idle = 0, 0
    if os.path.exists(PREV_CPU):
        try:
            with open(PREV_CPU, encoding="utf-8") as f:
                p_total, p_idle = (int(x) for x in f.read().split())
        except (ValueError, OSError):
            p_total = 0

    if p_total == 0:
        p_total, p_idle = total, idle
        time.sleep(0.1)
        total, idle = sample_cpu()

    dt = total - p_total
    di = idle - p_idle
    pct = max(0, min(100, round((dt - di) * 100 / dt))) if dt > 0 else 0

    with open(PREV_CPU, "w", encoding="utf-8") as f:
        f.write(f"{total} {idle}")
    return pct


def read_cpu_temp():
    preferred = ("coretemp", "k10temp", "zenpower", "cpu_thermal")
    fallback = None
    for hw in sorted(glob.glob("/sys/class/hwmon/hwmon*")):
        name_path = os.path.join(hw, "name")
        temp_path = os.path.join(hw, "temp1_input")
        if not (os.path.isfile(name_path) and os.path.isfile(temp_path)):
            continue
        try:
            with open(name_path, encoding="utf-8") as nf:
                name = nf.read().strip()
            with open(temp_path, encoding="utf-8") as tf:
                temp_c = round(int(tf.read().strip()) / 1000)
            if name in preferred:
                return temp_c
            if fallback is None and name == "acpitz":
                fallback = temp_c
        except (ValueError, OSError):
            continue
    return fallback


def read_meminfo():
    info = {}
    with open("/proc/meminfo", encoding="utf-8") as f:
        for line in f:
            k, v = line.split(":", 1)
            info[k] = int(v.strip().split()[0]) * 1024

    mem_total = info.get("MemTotal", 0)
    mem_avail = info.get("MemAvailable", info.get("MemFree", 0))
    mem_used = max(0, mem_total - mem_avail)
    mem_pct = round(mem_used * 100 / mem_total) if mem_total > 0 else 0

    swap_total = info.get("SwapTotal", 0)
    swap_free = info.get("SwapFree", 0)
    swap_used = max(0, swap_total - swap_free)
    swap_pct = round(swap_used * 100 / swap_total) if swap_total > 0 else 0

    return {
        "memory": {
            "used_bytes": mem_used,
            "total_bytes": mem_total,
            "percent": mem_pct,
        },
        "swap": {
            "used_bytes": swap_used,
            "total_bytes": swap_total,
            "percent": swap_pct,
        },
    }


def read_disks(disks):
    results = []
    for item in disks:
        mount = item["mount"]
        label = item["label"]
        try:
            if mount != "/" and not os.path.ismount(mount):
                results.append({
                    "mount": mount,
                    "label": label,
                    "mounted": False,
                })
                continue
            st = os.statvfs(mount)
        except OSError:
            results.append({
                "mount": mount,
                "label": label,
                "mounted": False,
            })
            continue

        total = st.f_blocks * st.f_frsize
        avail = st.f_bavail * st.f_frsize
        used = total - (st.f_bfree * st.f_frsize)
        denom = used + avail
        pct = round(used * 100 / denom) if denom > 0 else 0
        results.append({
            "mount": mount,
            "label": label,
            "mounted": True,
            "used_bytes": used,
            "avail_bytes": avail,
            "total_bytes": total,
            "percent": pct,
        })
    return results


def check_port(port):
    try:
        with socket.create_connection(("127.0.0.1", port), timeout=0.8):
            return True
    except OSError:
        return False


def read_services(systemctl, services):
    units = [s["unit"] for s in services]
    try:
        res = subprocess.run(
            [systemctl, "is-active", *units],
            capture_output=True,
            text=True,
            timeout=5,
        )
        states = res.stdout.splitlines()
    except (subprocess.SubprocessError, OSError):
        states = []

    statuses = {}
    for idx, srv in enumerate(services):
        unit_state = states[idx].strip() if idx < len(states) else "unknown"
        if unit_state == "active":
            status = "up" if check_port(srv["port"]) else "starting"
        elif unit_state == "activating":
            status = "starting"
        elif unit_state == "inactive" and not srv["autoStart"]:
            status = "off"
        else:
            status = "down"

        statuses[srv["name"]] = {
            "status": status,
            "autoStart": srv["autoStart"],
        }
    return statuses


def main():
    cfg = load_config(sys.argv[1])
    os.makedirs(STATE_DIR, mode=0o755, exist_ok=True)
    with open("/proc/uptime", encoding="utf-8") as f:
        uptime = int(float(f.read().split()[0]))
    with open("/proc/loadavg", encoding="utf-8") as f:
        load = " ".join(f.read().split()[:3])

    mem = read_meminfo()
    data = {
        "updated_at": int(time.time()),
        "system": {
            "uptime": uptime,
            "load": load,
            "cpu": {
                "percent": read_cpu_percent(),
                "temp_c": read_cpu_temp(),
            },
            "memory": mem["memory"],
            "swap": mem["swap"],
        },
        "disks": read_disks(cfg["disks"]),
        "services": read_services(cfg["systemctl"], cfg["services"]),
    }

    with open(TMP_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, separators=(",", ":"))
    os.chmod(TMP_FILE, 0o644)
    os.replace(TMP_FILE, OUT_FILE)


if __name__ == "__main__":
    main()
