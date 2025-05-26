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

        root.title(_("Offline mathlib help"))

        mainframe = ttk.Frame(root)
        mainframe.pack(fill=tk.BOTH, expand=True)

        notebook = ttk.Notebook(mainframe)
        notebook.pack(fill=tk.BOTH, expand=True, padx=4, pady=4)

        mainframe = ttk.Frame(notebook)
        notebook.add(mainframe, text=_("Offline mathlib help"))

        frame = mainframe
        frame.rowconfigure(0, weight=1)
        frame.columnconfigure(0, weight=1)
        frame.columnconfigure(1, weight=1)
        frame.columnconfigure(2, weight=1)
        self.start_button = ttk.Button(frame, text=_("Start offline mathlib help server"), command=self.start_server)
        self.start_button.grid(column=0, row=0, sticky="news", padx=4, pady=4)
        self.stop_button = ttk.Button(frame, text=_("Stop offline mathlib help server"), state=tk.DISABLED, command=self.stop_server)
        self.stop_button.grid(column=1, row=0, sticky="news", padx=4, pady=4)
        self.browse_button = ttk.Button(frame, text=_("Open offline mathlib help"), state=tk.DISABLED, command=self.start_browser)
        self.browse_button.grid(column=2, row=0, sticky="news", padx=4, pady=4)

        mainframe = ttk.Frame(notebook)
        notebook.add(mainframe, text=_("Check update"))

        frame = mainframe
        frame.rowconfigure(0, weight=1)
        frame.columnconfigure(0, weight=1)
        frame.columnconfigure(1, weight=1)

        btn = ttk.Button(frame, text=_("Check installed version"))
        btn.grid(column=0, row=0, sticky="news", padx=4, pady=4)
        btn = ttk.Button(frame, text=_("Check update"))
        btn.grid(column=1, row=0, sticky="news", padx=4, pady=4)

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

    def on_close(self):
        if self.server_thread is not None:
            self.server_thread.stop()
        self.root.destroy()

if __name__ == '__main__':
    root = tk.Tk()
    root.minsize(640, 200)
    MainWindow(root)
    root.mainloop()
