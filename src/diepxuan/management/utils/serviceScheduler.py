import time
import threading
import logging
import sys
from .serviceContext import ServiceContext
from .system_os import _os_distro, _init_system


def _get_os():
    if sys.platform.startswith("linux"):
        return "linux"
    if sys.platform == "darwin":
        return "macos"
    return "unknown"


class ServiceScheduler:
    def __init__(self, ctx: ServiceContext):
        self.ctx = ctx
        self.tasks = []
        self.os = _os_distro()
        self.init = _init_system()

    def register(
        self,
        name,
        interval,
        target,
        os=None,
        init=None,
        next_run=time.time(),
    ):
        self.tasks.append(
            {
                "name": name,
                "interval": interval,
                "target": target,
                "os": os,  # ["linux", "darwin", "debian", "ubuntu"]
                "init": init,  # ["systemd", "launchd"]
                "next_run": next_run,
            }
        )

    def run(self):
        logging.info("Scheduler started")

        while not self.ctx.shutdown_event.is_set():
            now = time.time()

            for task in self.tasks:
                if not self._should_run(task):
                    continue

                if now >= task["next_run"]:
                    self._run_task(task)
                    task["next_run"] = now + task["interval"]

            # Event-driven wait (KHÔNG busy loop)
            self.ctx.shutdown_event.wait(timeout=1)

        logging.info("Scheduler stopped")

    def _should_run(self, task):
        if task["os"] and self.os not in task["os"]:
            return False
        if task["init"] and self.init not in task["init"]:
            return False
        return True

    def _run_task(self, task):
        def wrapper():
            try:
                task["target"]()
            except Exception as e:
                logging.error(f"Task {task['name']} error: {e}")

        t = threading.Thread(
            target=wrapper,
            name=task["name"],
            daemon=False,  # QUAN TRỌNG
        )
        t.start()
        self.ctx.register_thread(t)
