import logging
import signal
import subprocess
import sys
import os
import threading
import time

from . import register_command
from .vm import _vm_sync
from .route import _route_monitor
from .system import _is_root, _sys_update
from .serviceContext import ServiceContext
from .serviceScheduler import ServiceScheduler


@register_command
def d_service():
    if not _is_root():
        return

    logging.info("Starting ductnd service")

    ctx = ServiceContext()
    setup_signal_handlers(ctx)

    scheduler = ServiceScheduler(ctx)

    # ---- Đăng ký task (tách biệt rõ ràng) ----
    scheduler.register(
        name="vm_sync",
        interval=10,
        target=_vm_sync,
        init="systemd",
    )

    scheduler.register(
        name="sys_update",
        interval=12 * 60 * 60,
        target=_sys_update,
        init="systemd",
    )

    scheduler.register(
        name="route_monitor",
        interval=5,
        target=_route_monitor,
        init="systemd",
    )

    from .dns import macos_dns_watch

    scheduler.register(
        name="macos_dns_watch",
        interval=10,  # 10s là hợp lý
        target=macos_dns_watch,
        init="launchd",
    )

    # ---- Chạy scheduler ----
    try:
        scheduler.run()
    except Exception as e:
        logging.error(f"Service fatal error: {e}")
    finally:
        logging.info("Shutting down service...")
        ctx.join_all(timeout=10)
        logging.info("Service stopped cleanly")


def setup_signal_handlers(ctx: ServiceContext):
    def handler(signum, frame):
        logging.info(f"[{signal.Signals(signum).name}] Shutdown signal received")
        ctx.stop()

    signal.signal(signal.SIGTERM, handler)
    signal.signal(signal.SIGINT, handler)


# # --- Biến toàn cục để xử lý tín hiệu ---
# shutdown_flag = False


# # --- Hàm xử lý tín hiệu ---
# def signal_handler(signum, frame):
#     global shutdown_flag
#     logging.info(f"[{signal.Signals(signum).name}] Bắt đầu quá trình tắt dịch vụ...")
#     shutdown_flag = True
#     # (Bạn có thể thêm logic giết tiến trình con ở đây nếu cần)


# @register_command
# def d_service():
#     if _is_root() is False:
#         return
#     logging.info("Bắt đầu service.")

#     # Đăng ký các hàm xử lý tín hiệu
#     signal.signal(signal.SIGTERM, signal_handler)
#     signal.signal(signal.SIGINT, signal_handler)

#     processes = {}
#     counter = 0

#     try:
#         while not shutdown_flag:
#             # Kiểm tra và dọn dẹp các tiến trình đã hoàn thành
#             for name, p in list(processes.items()):
#                 if not p.is_alive():
#                     # logging.info(f"Tác vụ '{name}' đã hoàn thành.")
#                     del processes[name]

#             if (
#                 counter % 10 == 0 and "vm_sync_thread" not in processes
#             ):  # 10 giây chạy một lần
#                 # logging.info("Kích hoạt tác vụ '_vm_sync'.")
#                 thread = threading.Thread(target=_vm_sync, name="vm_sync_thread")
#                 thread.daemon = True
#                 thread.start()
#                 processes["vm_sync_thread"] = thread

#             if (
#                 counter % (12 * 60 * 60) == 0 and "sys_update_thread" not in processes
#             ):  # 12 giờ chạy một lần
#                 thread = threading.Thread(target=_sys_update, name="sys_update_thread")
#                 thread.daemon = True
#                 thread.start()
#                 processes["sys_update_thread"] = thread

#             if (
#                 counter % 5 == 0 and "sys_route_monitor" not in processes
#             ):  # 5 giây chạy một lần
#                 thread = threading.Thread(
#                     target=_route_monitor, name="sys_route_monitor"
#                 )
#                 thread.daemon = True
#                 thread.start()
#                 processes["sys_route_monitor"] = thread

#             # if counter % 5 == 0 and "route_check" not in processes:
#             #     logging.info("Kích hoạt tác vụ 'route_check'.")
#             #     processes["route_check"] = subprocess.Popen(
#             #         [
#             #             "python",
#             #             "-c",
#             #             "import time; print('Route Check running...'); time.sleep(3)",
#             #         ]
#             #     )

#             # Ngủ 1 giây (hoặc có thể ngủ lâu hơn nếu không có gì làm)
#             time.sleep(1)
#             counter = (counter + 1) % (2 * 24 * 60 * 60)  # Reset mỗi 2 ngày
#     except KeyboardInterrupt:
#         logging.info("Nhận được tín hiệu thoát. Đang thoát dịch vụ...")
#     except Exception as e:
#         logging.error(f"Dịch vụ gặp lỗi không mong muốn: {e}")
#     finally:
#         logging.info("Đã tắt dịch vụ.")

#     logging.info("Đang tắt service...")
#     # Chờ các tiến trình con còn lại hoàn thành trước khi thoát hẳn
#     for p in processes.values():
#         p.wait()

#     logging.info("Đã tắt service.")
