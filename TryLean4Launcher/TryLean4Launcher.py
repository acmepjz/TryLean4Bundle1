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

init_locale()
gettext.install('messages', 'locale')

class MainWindow:
    def __init__(self, root):
        self.root = root
        self.server_thread = None
        self.has_cache = False

        root.title(_("Try Lean4 Windows Bundle Launcher"))

        mainframe = ttk.Frame(root)
        mainframe.pack(fill=tk.BOTH, expand=True, padx=8, pady=(8, 4))
        mainframe.columnconfigure(0, weight=1)
        mainframe.rowconfigure(1, weight=1)
        mainframe.rowconfigure(3, weight=1)
        mainframe.rowconfigure(5, weight=1)

        tk.Label(mainframe, text=_("Unpack mathlib cache"), bg="gray", fg="white", anchor="w").grid(column=0, row=0, sticky="news")

        frame = ttk.Frame(mainframe)
        frame.grid(column=0, row=1, sticky="news", pady=4)
        frame.rowconfigure(0, weight=1)
        frame.columnconfigure(0, weight=1)
        frame.columnconfigure(1, weight=1)
        frame.columnconfigure(2, weight=1)
        lf = ttk.Labelframe(frame, text=_("mathlib cache status"))
        lf.grid(column=0, row=0, sticky="news")
        lf.rowconfigure(0, weight=1)
        lf.columnconfigure(0, weight=1)
        self.cache_status = tk.StringVar()
        tk.Label(lf, textvariable=self.cache_status).grid(column=0, row=0, sticky="news")
        ttk.Button(frame, text=_("Unpack mathlib cache"), command=self.unpack_cache).grid(column=1, row=0, sticky="news", padx=(4, 0))
        self.check_cache_status()

        tk.Label(mainframe, text=_("Start Try Lean4 Windows Bundle"), bg="gray", fg="white", anchor="w").grid(column=0, row=2, sticky="news")

        frame = ttk.Frame(mainframe)
        frame.grid(column=0, row=3, sticky="news", pady=4)
        frame.rowconfigure(0, weight=1)
        frame.columnconfigure(0, weight=1)
        frame.columnconfigure(1, weight=1)
        frame.columnconfigure(2, weight=1)
        ttk.Button(frame, text=_("Start Lean4 VSCode code editor"), command=self.start_vscode).grid(column=0, row=0, sticky="news")
        ttk.Button(frame, text=_("Start Lean4 bash command line"), command=self.start_bash).grid(column=1, row=0, sticky="news", padx=(4, 0))

        tk.Label(mainframe, text=_("Offline mathlib help"), bg="gray", fg="white", anchor="w").grid(column=0, row=4, sticky="news")

        frame = ttk.Frame(mainframe)
        frame.grid(column=0, row=5, sticky="news", pady=4)
        frame.rowconfigure(0, weight=1)
        frame.columnconfigure(0, weight=1)
        frame.columnconfigure(1, weight=1)
        frame.columnconfigure(2, weight=1)
        self.start_button = ttk.Button(frame, text=_("Start offline mathlib help server"), command=self.start_server)
        self.start_button.grid(column=0, row=0, sticky="news")
        self.stop_button = ttk.Button(frame, text=_("Stop offline mathlib help server"), command=self.stop_server, state=tk.DISABLED)
        self.stop_button.grid(column=1, row=0, sticky="news", padx=(4, 0))
        self.browse_button = ttk.Button(frame, text=_("Open offline mathlib help"), state=tk.DISABLED, command=self.start_browser)
        self.browse_button.grid(column=2, row=0, sticky="news", padx=(4, 0))
        
        root.protocol("WM_DELETE_WINDOW", self.on_close)

    def start_server(self):
        if self.server_thread is None or not self.server_thread.is_alive():
            try:
                tmp = zipfile.ZipFile(http_serve.ZIP_FILE_PATH, 'r')
            except:
                messagebox.showerror(title=_("Error"), message=_("Failed to load file %s") % http_serve.ZIP_FILE_PATH)
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
        if self.has_cache:
            if messagebox.askquestion(title=_("Mathlib cache already exists"), message=_("Mathlib cache already exists. Do you want to reinstall?")) != messagebox.YES:
                return
        os.system("start /wait cmd /c unpack_cache.cmd")
        sleep(0.1)
        self.check_cache_status()

    def start_vscode(self):
        os.startfile("start_Lean_VSCode.cmd")

    def start_bash(self):
        os.startfile("start_Lean_bash.cmd")

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
