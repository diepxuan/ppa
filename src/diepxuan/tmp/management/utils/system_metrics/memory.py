import psutil, os


def memory_usage():
    try:
        return psutil.Process(os.getpid()).memory_info().rss
    except Exception:
        return 0
