import threading
import logging


class ServiceContext:
    def __init__(self):
        self.shutdown_event = threading.Event()
        self.threads = []

    def stop(self):
        logging.info("ServiceContext: shutdown requested")
        self.shutdown_event.set()

    def register_thread(self, t: threading.Thread):
        self.threads.append(t)

    def join_all(self, timeout=10):
        for t in self.threads:
            if t.is_alive():
                t.join(timeout=timeout)
