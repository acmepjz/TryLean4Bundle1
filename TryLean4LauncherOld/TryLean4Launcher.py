import gettext, locale, os, os.path
import zipfile
import tkinter as tk
from tkinter import messagebox, ttk
from time import sleep
import http_serve
from http_serve import InMemoryZipHTTPRequestHandler, ServerThread

def init_locale():
    for key in ["LANGUAGE", "LC_ALL", "LC_MESSAGES", "LANG"]:
        if key in os.environ:
            return True
    def_locale = locale.getdefaultlocale()[0]
    os.environ["LANG"] = def_locale

class MainWindow:
    def __init__(self, root):
        init_locale()
        gettext.install('messages', 'locale')

        self.root = root
        self.server_thread = None
        self.has_cache = False

        root.title(_("Try Lean4 Windows Bundle Launcher"))

        mainframe = ttk.Frame(root)
        mainframe.pack(fill=tk.BOTH, expand=True)

        notebook = ttk.Notebook(mainframe)
        notebook.pack(fill=tk.BOTH, expand=True, padx=4, pady=4)

        mainframe = ttk.Frame(notebook)
        notebook.add(mainframe, text=_("Home"))
        mainframe.columnconfigure(0, weight=1)
        mainframe.rowconfigure(0, weight=1)
        mainframe.rowconfigure(1, weight=1)

        frame = ttk.Labelframe(mainframe, text=_("One click solution"))
        frame.grid(column=0, row=0, sticky="news", padx=4, pady=4)
        ttk.Button(frame, text=_("One click to start Try Lean4 Windows Bundle"), command=self.unpack_and_start_vscode).pack(fill=tk.BOTH, expand=True, padx=4, pady=4)

        frame = ttk.Labelframe(mainframe, text=_("Offline mathlib help"))
        frame.grid(column=0, row=1, sticky="news", padx=4, pady=4)
        frame.rowconfigure(0, weight=1)
        frame.columnconfigure(0, weight=1)
        frame.columnconfigure(1, weight=1)
        frame.columnconfigure(2, weight=1)
        self.start_button = ttk.Button(frame, text=_("Start offline mathlib help server"), command=self.start_server)
        self.start_button.grid(column=0, row=0, sticky="news", padx=4, pady=4)
        self.stop_button = ttk.Button(frame, text=_("Stop offline mathlib help server"), command=self.stop_server, state=tk.DISABLED)
        self.stop_button.grid(column=1, row=0, sticky="news", padx=4, pady=4)
        self.browse_button = ttk.Button(frame, text=_("Open offline mathlib help"), state=tk.DISABLED, command=self.start_browser)
        self.browse_button.grid(column=2, row=0, sticky="news", padx=4, pady=4)

        mainframe = ttk.Frame(notebook)
        notebook.add(mainframe, text=_("Advanced"))
        mainframe.columnconfigure(0, weight=1)
        mainframe.rowconfigure(0, weight=1)
        mainframe.rowconfigure(1, weight=1)

        frame = ttk.Labelframe(mainframe, text=_("Unpack mathlib cache"))
        frame.grid(column=0, row=0, sticky="news", padx=4, pady=4)
        frame.rowconfigure(0, weight=1)
        frame.columnconfigure(0, weight=1)
        frame.columnconfigure(1, weight=1)
        frame.columnconfigure(2, weight=1)
        lf = ttk.Labelframe(frame, text=_("mathlib cache status"))
        lf.grid(column=0, row=0, sticky="news", padx=4, pady=4)
        lf.rowconfigure(0, weight=1)
        lf.columnconfigure(0, weight=1)
        self.cache_status = tk.StringVar()
        tk.Label(lf, textvariable=self.cache_status).grid(column=0, row=0, sticky="news")
        ttk.Button(frame, text=_("Unpack mathlib cache"), command=self.unpack_cache).grid(column=1, row=0, sticky="news", padx=4, pady=4)
        self.check_cache_status()

        frame = ttk.Labelframe(mainframe, text=_("Start Try Lean4 Windows Bundle"))
        frame.grid(column=0, row=1, sticky="news", padx=4, pady=4)
        frame.rowconfigure(0, weight=1)
        frame.columnconfigure(0, weight=1)
        frame.columnconfigure(1, weight=1)
        frame.columnconfigure(2, weight=1)
        ttk.Button(frame, text=_("Start Lean4 VSCode code editor"), command=self.start_vscode).grid(column=0, row=0, sticky="news", padx=4, pady=4)
        ttk.Button(frame, text=_("Start Lean4 bash command line"), command=self.start_bash).grid(column=1, row=0, sticky="news", padx=4, pady=4)

        root.protocol("WM_DELETE_WINDOW", self.on_close)

    def start_server(self):
        if self.server_thread is None or not self.server_thread.is_alive():
            try:
                with zipfile.ZipFile(http_serve.ZIP_FILE_PATH, 'r') as tmp:
                    pass
            except:
                messagebox.showerror(title=_("Error"), message=_("Failed to load file '%s'. Please check the installation is correct.") % http_serve.ZIP_FILE_PATH)
                return

            self.server_thread = ServerThread(('127.0.0.1', 13480), InMemoryZipHTTPRequestHandler)
            self.server_thread.start()

            self.start_button.config(state=tk.DISABLED)
            self.stop_button.config(state=tk.NORMAL)
            self.browse_button.config(state=tk.NORMAL)

            print("Server is starting...")

            sleep(0.1)

            self.start_browser()

    def stop_server(self):
        if self.server_thread is not None:
            self.server_thread.stop()
            self.start_button.config(state=tk.NORMAL)
            self.stop_button.config(state=tk.DISABLED)
            self.browse_button.config(state=tk.DISABLED)

            print("Server is stopping...")

    def start_browser(self):
        os.startfile("http://127.0.0.1:13480/doc/index.html")

    def unpack_cache(self):
        if not self.check_file_exists(["scripts/setup_env_variables.cmd", "scripts/unpack_cache.cmd"]):
            return
        if self.has_cache:
            if messagebox.askquestion(title=_("Mathlib cache already exists"), message=_("Mathlib cache already exists. Do you want to reinstall?\n\nThe installation process will take 5 minutes.")) != messagebox.YES:
                return
        else:
            if messagebox.askquestion(title=_("Unpack mathlib cache"), message=_("Do you want to install mathlib cache?\n\nThe installation process will take 5 minutes.")) != messagebox.YES:
                return
        self.do_unpack_cache()

    def do_unpack_cache(self):
        os.system("start /wait cmd /c \"cd scripts && unpack_cache.cmd\"")
        sleep(0.1)
        self.check_cache_status()

    def unpack_and_start_vscode(self):
        if not self.check_file_exists(["scripts/setup_env_variables.cmd", "scripts/unpack_cache.cmd", "scripts/start_Lean_VSCode.cmd"]):
            return
        if not self.has_cache:
            if messagebox.askquestion(title=_("Unpack mathlib cache"), message=_("Seems that it's the first time you using Try Lean4 Windows Bundle.\nThe mathlib cache is not installed yet. Do you want to install mathlib cache?\n\n- Choose 'yes' to install mathlib cache (recommended). The installation process will take 5 minutes.\n- Choose 'no' to run VSCode directly, note that 'import Mathlib' will be not not available.")) == messagebox.YES:
                self.do_unpack_cache()
        self.start_vscode()

    def start_vscode(self):
        if not self.check_file_exists(["scripts/setup_env_variables.cmd", "scripts/start_Lean_VSCode.cmd"]):
            return
        os.system("cmd /c \"cd scripts && start_Lean_VSCode.cmd\"")

    def start_bash(self):
        if not self.check_file_exists(["scripts/setup_env_variables.cmd", "scripts/start_Lean_bash.cmd"]):
            return
        os.system("cmd /c \"cd scripts && start_Lean_bash.cmd\"")

    def check_file_exists(self, files):
        for file in files:
            found = False
            try:
                if os.path.isfile(file):
                    found = True
            except:
                pass
            if not found:
                messagebox.showerror(title=_("Error"), message=_("Failed to load file '%s'. Please check the installation is correct.") % file)
                return False
        return True

    def on_close(self):
        if self.server_thread is not None:
            self.server_thread.stop()
        self.root.destroy()

    def check_cache_status(self):
        self.has_cache = False
        self.cache_status.set(_("Not installed"))
        try:
            if os.path.isfile("projects/LeanPlayground/.lake/packages/mathlib/.lake/build/lib/Mathlib/Init.olean"):
                self.has_cache = True
                self.cache_status.set(_("Installed"))
        except:
            pass
        try:
            if os.path.isfile("projects/LeanPlayground/.lake/packages/mathlib/.lake/build/lib/lean/Mathlib/Init.olean"):
                self.has_cache = True
                self.cache_status.set(_("Installed"))
        except:
            pass

if __name__ == '__main__':
    root = tk.Tk()
    MainWindow(root)
    root.mainloop()
