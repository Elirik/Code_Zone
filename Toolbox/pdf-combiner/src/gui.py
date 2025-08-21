import tkinter as tk
from tkinter import ttk, filedialog, messagebox
import pdf_utils

class PDFCombinerApp:
    def __init__(self, master):
        self.master = master
        master.title("PDF Combiner")

        screen_width = master.winfo_screenwidth()
        screen_height = master.winfo_screenheight()
        width = int(screen_width * 0.4)
        height = int(screen_height * 0.5)
        master.geometry(f"{width}x{height}")
        master.minsize(500, 350)
        master.configure(bg="#f5f5f5")

        style = ttk.Style()
        style.theme_use('clam')
        style.configure("TButton", font=("Segoe UI", 11), padding=6)
        style.configure("Add.TButton", background="#2196F3", foreground="white")
        style.map("Add.TButton", background=[("active", "#1976D2"), ("disabled", "#B0BEC5")])
        style.configure("Remove.TButton", background="#F44336", foreground="white")
        style.map("Remove.TButton", background=[("active", "#B71C1C"), ("disabled", "#B0BEC5")])
        style.configure("Combine.TButton", background="#4CAF50", foreground="white")
        style.map("Combine.TButton", background=[("active", "#388E3C"), ("disabled", "#B0BEC5")])
        style.configure("Clear.TButton", background="#9E9E9E", foreground="white")
        style.map("Clear.TButton", background=[("active", "#616161"), ("disabled", "#B0BEC5")])

        self.files = []

        self.label = ttk.Label(master, text="Selected PDF files:", font=("Segoe UI", 12, "bold"), background="#f5f5f5")
        self.label.pack(pady=(20, 10))

        frame = ttk.Frame(master)
        frame.pack(fill="both", expand=True, padx=20, pady=5)

        self.listbox = tk.Listbox(frame, selectmode=tk.SINGLE, font=("Segoe UI", 10), bg="#ffffff", fg="#333333", borderwidth=2, relief="groove")
        self.listbox.pack(side="left", fill="both", expand=True)
        self.listbox.bind("<<ListboxSelect>>", lambda e: self.update_button_states())

        self.scrollbar = ttk.Scrollbar(frame, orient="vertical", command=self.listbox.yview)
        self.scrollbar.pack(side="right", fill="y")
        self.listbox.config(yscrollcommand=self.scrollbar.set)

        btn_frame = ttk.Frame(master)
        btn_frame.pack(fill="x", padx=20, pady=(10, 20))

        self.add_btn = ttk.Button(btn_frame, text="Add PDF Files", style="Add.TButton", command=self.add_files)
        self.add_btn.pack(side="left", padx=5, ipadx=10)

        self.remove_btn = ttk.Button(btn_frame, text="Remove Selected", style="Remove.TButton", command=self.remove_selected)
        self.remove_btn.pack(side="left", padx=5, ipadx=10)

        self.clear_btn = ttk.Button(btn_frame, text="Clear Selection", style="Clear.TButton", command=self.clear_selection)
        self.clear_btn.pack(side="left", padx=5, ipadx=10)

        self.combine_btn = ttk.Button(btn_frame, text="Combine PDFs", style="Combine.TButton", command=self.combine_pdfs)
        self.combine_btn.pack(side="right", padx=5, ipadx=10)

        self.update_button_states()

    def add_files(self):
        files = filedialog.askopenfilenames(filetypes=[("PDF files", "*.pdf")])
        for f in files:
            if f not in self.files:
                self.files.append(f)
                self.listbox.insert(tk.END, f)
        self.update_button_states()

    def remove_selected(self):
        selected = self.listbox.curselection()
        if not selected:
            return
        idx = selected[0]
        self.listbox.delete(idx)
        del self.files[idx]
        self.update_button_states()

    def clear_selection(self):
        self.files.clear()
        self.listbox.delete(0, tk.END)
        self.update_button_states()

    def combine_pdfs(self):
        if not self.files:
            return
        output_file = filedialog.asksaveasfilename(defaultextension=".pdf", filetypes=[("PDF files", "*.pdf")])
        if output_file:
            try:
                pdf_utils.combine_pdfs(self.files, output_file)
                messagebox.showinfo("Success", "PDFs combined successfully!")
            except Exception as e:
                messagebox.showerror("Error", f"An error occurred: {e}")

    def update_button_states(self):
        has_files = bool(self.files)
        has_selection = bool(self.listbox.curselection())

        # Remove only enabled if a file is selected
        if has_selection:
            self.remove_btn.state(["!disabled"])
        else:
            self.remove_btn.state(["disabled"])

        # Clear only enabled if there are files
        if has_files:
            self.clear_btn.state(["!disabled"])
            self.combine_btn.state(["!disabled"])
        else:
            self.clear_btn.state(["disabled"])
            self.combine_btn.state(["disabled"])

def run_gui():
    root = tk.Tk()
    app = PDFCombinerApp(root)
    root.mainloop()