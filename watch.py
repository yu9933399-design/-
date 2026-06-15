import time
import os
import subprocess
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

# 你的项目路径
WATCH_DIR = r"D:\浏览\eclipse-jee\daima2\jj"

class GitAutoBackupHandler(FileSystemEventHandler):
    def on_modified(self, event):
        if event.is_directory:
            return
        try:
            print(f"检测到文件变化: {event.src_path}")
            os.chdir(WATCH_DIR)
            # 执行 git 命令
            subprocess.run(["git", "add", "."], check=True)
            subprocess.run(["git", "commit", "-m", f"自动备份: {time.ctime()}"], check=True)
            subprocess.run(["git", "push", "origin", "main"], check=True)
            print("✅ 已自动备份到 GitHub\n")
        except Exception as e:
            print(f"❌ 备份失败: {e}\n")

if __name__ == "__main__":
    event_handler = GitAutoBackupHandler()
    observer = Observer()
    observer.schedule(event_handler, WATCH_DIR, recursive=True)
    observer.start()
    print("🔍 已启动实时监控，修改文件将自动备份到 GitHub...")
    print("按 Ctrl+C 停止监控\n")
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()