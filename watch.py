import time
import os
import subprocess
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

# 项目路径
WATCH_DIR = r"D:\浏览\eclipse-jee\daima2\jj"
# 忽略 .git 文件夹
IGNORE_DIR = ".git"

class GitAutoBackupHandler(FileSystemEventHandler):
    def on_modified(self, event):
        # 忽略目录、忽略.git内部文件
        if event.is_directory or IGNORE_DIR in event.src_path:
            return
        
        time.sleep(0.5)  # 短暂延时，防止重复触发
        os.chdir(WATCH_DIR)

        # 检查是否有实际文件改动
        result = subprocess.run(
            ["git", "status", "--porcelain"],
            capture_output=True, text=True, encoding="utf-8"
        )
        # 无改动则退出
        if not result.stdout.strip():
            return

        print(f"检测到代码变更: {event.src_path}")
        try:
            subprocess.run(["git", "add", "."], check=True)
            subprocess.run(["git", "commit", "-m", f"自动备份: {time.strftime('%Y-%m-%d %H:%M:%S')}"], check=True)
            subprocess.run(["git", "push", "origin", "main"], check=True)
            print("✅ 备份并推送成功\n")
        except Exception as e:
            print(f"❌ 备份失败: {e}\n")

if __name__ == "__main__":
    event_handler = GitAutoBackupHandler()
    observer = Observer()
    observer.schedule(event_handler, WATCH_DIR, recursive=True)
    observer.start()
    print("🔍 实时监控已启动，修改代码自动备份到 GitHub")
    print("按 Ctrl + C 停止监控\n")

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()