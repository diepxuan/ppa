import time
import threading
import logging
from .serviceContext import ServiceContext


class ServiceScheduler:
    def __init__(self, ctx: ServiceContext):
        self.ctx = ctx
        self.tasks = []

    def register(self, name, interval, target):
        self.tasks.append(
            {
                "name": name,
                "interval": interval,
                "target": target,
                "next_run": time.time(),
            }
        )

    def run(self):
        logging.info("Scheduler started")

        while not self.ctx.shutdown_event.is_set():
            now = time.time()

            for task in self.tasks:
                if now >= task["next_run"]:
                    self._run_task(task)
                    task["next_run"] = now + task["interval"]

            # Event-driven wait (KHÔNG busy loop)
            self.ctx.shutdown_event.wait(timeout=1)

        logging.info("Scheduler stopped")

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
