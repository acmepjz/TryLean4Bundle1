#!/usr/bin/env python3
import gettext, locale, os, os.path
import zipfile
import tkinter as tk
from tkinter import messagebox, ttk
from time import sleep
import http_serve
from http_serve import InMemoryZipHTTPRequestHandler, ServerThread
import urllib.request

OFFLINE_MATHLIB_HELP_URL = "http://127.0.0.1:13480/doc/index.html"

def init_locale():
    for key in ["LANGUAGE", "LC_ALL", "LC_MESSAGES", "LANG"]:
        if key in os.environ:
            return True
    try:
        def_locale = locale.getdefaultlocale()[0]
        os.environ["LANG"] = def_locale
    except:
        pass

class MainWindow:
    def __init__(self, root):
        init_locale()
        gettext.install('messages', os.path.dirname(__file__) + '/locale')

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
        mainframe.rowconfigure(0, weight=1)
        mainframe.columnconfigure(0, weight=1)

        frame = ttk.Frame(mainframe)
        frame.grid(column=0, row=0, sticky="news")
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

        ttk.Label(mainframe, text=_("Offline mathlib help can be accessed via:")).grid(column=0, row=1, sticky="news", padx=4)

        frame = ttk.Frame(mainframe)
        frame.grid(column=0, row=2, sticky="news")
        frame.rowconfigure(0, weight=1)
        frame.columnconfigure(0, weight=1)
        self.offline_mathlib_help_url = tk.StringVar()
        # self.offline_mathlib_help_url.set("test")
        ttk.Entry(frame, textvariable=self.offline_mathlib_help_url, state='readonly').grid(column=0, row=0, sticky="news", padx=4, pady=4)
        ttk.Button(frame, text=_("Copy to clipboard"), command=self.copy_to_clipboard).grid(column=1, row=0, sticky="news", padx=4, pady=4)

        mainframe = ttk.Frame(notebook)
        notebook.add(mainframe, text=_("Check update"))
        mainframe.rowconfigure(0, weight=1)
        mainframe.columnconfigure(0, weight=1)

        frame = ttk.Frame(mainframe)
        frame.grid(column=0, row=0, sticky="news")
        frame.rowconfigure(0, weight=1)
        frame.columnconfigure(0, weight=1)
        frame.columnconfigure(1, weight=1)

        self.check_version_btn = ttk.Button(frame, text=_("Check installed version"), command=self.check_version)
        self.check_version_btn.grid(column=0, row=0, sticky="news", padx=4, pady=4)
        self.check_update_btn = ttk.Button(frame, text=_("Check update"), command=self.check_update)
        self.check_update_btn.grid(column=1, row=0, sticky="news", padx=4, pady=4)

        self.download_progress = tk.StringVar()
        ttk.Label(mainframe, textvariable=self.download_progress).grid(column=0, row=1, sticky="news", padx=4)
        self.progress_bar = ttk.Progressbar(mainframe)
        self.progress_bar.grid(column=0, row=2, sticky="news", padx=4, pady=4)

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

            self.offline_mathlib_help_url.set("")

    def start_browser(self):
        self.offline_mathlib_help_url.set(OFFLINE_MATHLIB_HELP_URL)
        try:
            os.startfile(OFFLINE_MATHLIB_HELP_URL)
        except:
            messagebox.showinfo(title=_("Offline mathlib help"), message=_("Offline mathlib help can be accessed via\n\n%s\n\nin your browser.") % OFFLINE_MATHLIB_HELP_URL)

    def copy_to_clipboard(self):
        self.root.clipboard_clear()
        self.root.clipboard_append(self.offline_mathlib_help_url.get())
        self.root.update()

    def check_version(self):
        old_version = self.do_check_version()
        if old_version is None:
            message = _("Can't find offline mathlib help data.")
        else:
            message = _("The offline mathlib help data has version:\n\n%s") % old_version
        messagebox.showinfo(title=_("Check installed version"), message=message)

    def do_check_version(self):
        try:
            with zipfile.ZipFile(http_serve.ZIP_FILE_PATH, 'r') as zip_file:
                try:
                    file_data = zip_file.read("doc/doc_version.txt")
                    version = file_data.decode('utf-8')[:512]
                    version = version.replace('\r', '').rstrip('\n')
                    return version
                except:
                    return "unknown"
        except:
            return None

    def disable_update_widgets(self):
        self.check_version_btn.config(state=tk.DISABLED)
        self.check_update_btn.config(state=tk.DISABLED)
        self.root.config(cursor="watch")
        self.root.update()

    def enable_update_widgets(self):
        self.check_version_btn.config(state=tk.NORMAL)
        self.check_update_btn.config(state=tk.NORMAL)
        self.progress_bar.config(mode="determinate", maximum=100, value=0)
        self.progress_bar.stop()
        self.root.config(cursor="")
        self.root.update()

    def check_update(self):
        self.disable_update_widgets()
        try:
            with urllib.request.urlopen("https://github.com/acmepjz/TryLean4Bundle1/releases/download/nightly/doc_version.txt") as f:
                version = f.read().decode('utf-8')[:512]
                version = version.replace('\r', '').rstrip('\n')
        except:
            self.enable_update_widgets()
            messagebox.showerror(title=_("Error"), message=_("Failed to download version information. Please check the Internet connection."))
            return

        old_version = self.do_check_version()
        if old_version is None:
            message = _("Can't find offline mathlib help data.")
        else:
            message = _("The offline mathlib help data has version:\n\n%s") % old_version
        message += _("\n\nThe offline mathlib help available on the Internet has version:\n\n%s") % version
        if old_version == version:
            message += _("\n\nThe version is not changed. Do you want to download it again?")
        else:
            message += _("\n\nDo you want to download it?")

        self.enable_update_widgets()
        if messagebox.askquestion(title=_("Check update"), message=message) == messagebox.YES:
            self.do_update()

    def do_update(self):
        self.download_progress.set(_("Start download..."))
        self.progress_bar.config(mode="indeterminate", maximum=100, value=0)
        self.progress_bar.start()
        self.disable_update_widgets()
        try:
            urllib.request.urlretrieve("https://github.com/acmepjz/TryLean4Bundle1/releases/download/nightly/doc.zip", http_serve.ZIP_FILE_PATH + ".new", self.download_progress_callback)
        except:
            urllib.request.urlcleanup()
            self.enable_update_widgets()
            messagebox.showerror(title=_("Error"), message=_("Failed to download offline mathlib help. Please check the Internet connection."))
            return
        self.download_progress.set(_("Checking integrity of downloaded file..."))
        self.root.update()
        zip_file_ok = True
        try:
            with zipfile.ZipFile(http_serve.ZIP_FILE_PATH + ".new", 'r') as zip_file:
                if zip_file.testzip():
                    zip_file_ok = False
        except:
            zip_file_ok = False
        self.enable_update_widgets()
        if zip_file_ok:
            try:
                if os.path.exists(http_serve.ZIP_FILE_PATH):
                    os.remove(http_serve.ZIP_FILE_PATH)
                os.rename(http_serve.ZIP_FILE_PATH + ".new", http_serve.ZIP_FILE_PATH)
                self.download_progress.set(_("Updated successfully"))
                messagebox.showinfo(title=_("Check update"), message=_("The file is downloaded and updated successfully."))
            except:
                messagebox.showerror(title=_("Error"), message=_("Failed to overwrite file.\n\nPlease rename '%s' to '%s' manually.") % (http_serve.ZIP_FILE_PATH + ".new", http_serve.ZIP_FILE_PATH))
        else:
            if os.path.exists(http_serve.ZIP_FILE_PATH + ".new"):
                os.remove(http_serve.ZIP_FILE_PATH + ".new")
            messagebox.showerror(title=_("Error"), message=_("The downloaded file is corrupted. Please try again."))

    def download_progress_callback(self, b, bsize, tsize):
        message = _("Downloading...")
        if tsize > 0:
            self.progress_bar.stop()
            self.progress_bar.config(mode="determinate", maximum=tsize, value=(b*bsize))
            message += " %d / %d" % (b * bsize, tsize)
        else:
            message += " %d / ?" % (b * bsize)
        self.download_progress.set(message)
        self.root.update()

    def on_close(self):
        if self.server_thread is not None:
            self.server_thread.stop()
        self.root.destroy()

if __name__ == '__main__':
    root = tk.Tk()
    root.minsize(640, 200)
    MainWindow(root)
    root.mainloop()
