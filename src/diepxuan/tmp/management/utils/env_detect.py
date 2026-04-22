import os
import shutil
import subprocess
from . import register_command


class DetectVirtError(Exception):
    """Lỗi khi không thể xác định môi trường ảo hóa."""

    pass


def detect_virt():
    """Phát hiện môi trường ảo hóa: baremetal, vm, lxc, v.v."""
    if shutil.which("systemd-detect-virt"):
        result = subprocess.run(["systemd-detect-virt"], capture_output=True, text=True)
        if result.returncode == 0:
            virt = result.stdout.strip()
            if virt == "none":
                return "baremetal"
            elif virt == "lxc":
                return "lxc"
            elif virt in ("kvm", "qemu"):
                return "vm"
            else:
                return virt
        else:
            raise DetectVirtError("Không xác định được môi trường (returncode != 0)")
    else:
        raise DetectVirtError("systemd-detect-virt không tồn tại trên hệ thống")


def detect_dmi():
    paths = [
        "/sys/class/dmi/id/product_name",
        "/sys/class/dmi/id/sys_vendor",
    ]
    for path in paths:
        if os.path.exists(path):
            with open(path) as f:
                content = f.read().lower()
                if "qemu" in content or "kvm" in content:
                    return "vm"
                if "proxmox" in content:
                    return "vm"
    return "baremetal"


def detect_container_proc():
    try:
        with open("/proc/1/environ", "rb") as f:
            data = f.read().lower()
            if b"lxc" in data:
                return "lxc"
            if b"docker" in data:
                return "docker"
    except:
        pass

    try:
        with open("/proc/self/cgroup") as f:
            data = f.read().lower()
            if "lxc" in data:
                return "lxc"
            if "docker" in data:
                return "docker"
    except:
        pass

    return "baremetal"


def detect_environment():
    # Ưu tiên systemd
    try:
        env = detect_virt()
        return env
    except:
        pass

    # # Thử qua /proc
    env = detect_container_proc()
    if env != "baremetal":
        return env

    # # Thử qua DMI
    env = detect_dmi()
    return env


@register_command
def d_env_detect():
    """
    Kiểm tra biết máy hiện tại là VM (ảo hóa)/LXC container (Proxmox LXC)/Máy vật lý (bare metal)
    """
    print(detect_environment())
