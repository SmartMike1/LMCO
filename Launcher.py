import os
import io
import zipfile
import requests
import threading
import subprocess
import traceback
import tkinter as tk
from tkinter import ttk, messagebox

# ==== Настройки ====
GITHUB_API_RELEASES_LATEST = "https://api.github.com/repos/SmartMike1/LMCO/releases/latest"
GITHUB_ZIP_URL = "https://github.com/SmartMike1/LMCO/archive/refs/heads/main.zip"
LOCAL_VERSION_FILE = "version.txt"
APP_DIR = "Main"
EXECUTABLE_NAME = "Diplom.exe"
EXECUTABLE_PATH = os.path.join(APP_DIR, EXECUTABLE_NAME)
START_BAT_PATH = os.path.join(APP_DIR, "start.bat")
REPO_SUBDIR = "LMCO-main/"  # Внутри ZIP-архива

def get_local_version():
    try:
        with open(LOCAL_VERSION_FILE, "r") as f:
            return f.read().strip()
    except FileNotFoundError:
        return "0.0.0"

def get_remote_release_info():
    try:
        response = requests.get(GITHUB_API_RELEASES_LATEST, timeout=10)
        response.raise_for_status()
        data = response.json()
        tag_name = data.get("tag_name", "0.0.0")
        assets = data.get("assets", [])
        exe_url = None
        for asset in assets:
            if asset["name"] == EXECUTABLE_NAME:
                exe_url = asset["browser_download_url"]
        return tag_name, exe_url
    except Exception:
        return None, None

def download_executable(url, log):
    log("🔄 Скачивание Diplom.exe...")
    response = requests.get(url, stream=True)
    response.raise_for_status()
    os.makedirs(APP_DIR, exist_ok=True)
    with open(EXECUTABLE_PATH, "wb") as f:
        for chunk in response.iter_content(chunk_size=8192):
            if chunk:
                f.write(chunk)
    log("✅ Diplom.exe обновлён.")

def download_and_extract_files(log):
    log("📦 Обновление файлов проекта...")
    response = requests.get(GITHUB_ZIP_URL)
    with zipfile.ZipFile(io.BytesIO(response.content)) as zip_ref:
        for member in zip_ref.namelist():
            if member.startswith(REPO_SUBDIR):
                rel_path = member.replace(REPO_SUBDIR, "")
                if rel_path and not rel_path.endswith(EXECUTABLE_NAME):  # Не заменять .exe, мы его обновляем отдельно
                    full_path = os.path.join(APP_DIR, rel_path)
                    if member.endswith("/"):
                        os.makedirs(full_path, exist_ok=True)
                    else:
                        os.makedirs(os.path.dirname(full_path), exist_ok=True)
                        with open(full_path, "wb") as f:
                            f.write(zip_ref.read(member))
    log("✅ Файлы проекта обновлены.")

def run_main_script():
    try:
        subprocess.Popen(f'cmd /c "{START_BAT_PATH}"', shell=True)
    except Exception as e:
        with open("error.log", "a") as log_file:
            log_file.write(f"\n[Launcher Error] {e}\n")
            log_file.write(traceback.format_exc())

# ==== GUI интерфейс ====
class LauncherApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("LMCO-Group – обновление")
        self.geometry("400x150")
        self.resizable(False, False)

        self.label = ttk.Label(self, text="Подготовка к запуску...", font=("Segoe UI", 11))
        self.label.pack(pady=20)

        self.progress = ttk.Progressbar(self, mode="indeterminate")
        self.progress.pack(fill="x", padx=30)

        self.after(300, self.start_update_thread)

    def log(self, message):
        self.label.config(text=message)
        self.update_idletasks()

    def start_update_thread(self):
        threading.Thread(target=self.update_and_run, daemon=True).start()

    def update_and_run(self):
        try:
            self.progress.start()
            self.log("Проверка версии...")

            local_version = get_local_version()
            remote_version, exe_url = get_remote_release_info()

            if remote_version is None or exe_url is None:
                self.log("Не удалось получить данные релиза.")
            elif local_version != remote_version:
                self.log(f"Найдена новая версия: {remote_version}")
                download_executable(exe_url, self.log)
                download_and_extract_files(self.log)
                with open(LOCAL_VERSION_FILE, "w") as f:
                    f.write(remote_version)
            else:
                self.log("Обновление не требуется.")
                download_and_extract_files(self.log)  # всё равно обновим файлы

            self.log("Запуск приложения...")
            self.progress.stop()
            run_main_script()
            self.destroy()

        except Exception as e:
            self.progress.stop()
            messagebox.showerror("Ошибка запуска", f"Произошла ошибка: {e}")
            self.destroy()

if __name__ == "__main__":
    LauncherApp().mainloop()