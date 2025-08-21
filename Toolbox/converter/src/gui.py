import tkinter as tk
from tkinter import ttk, filedialog, messagebox

class ConverterApp:
    def __init__(self, master):
        self.master = master
        master.title("File Converter")
        master.geometry("750x450")
        master.resizable(True, True)

        style = ttk.Style()
        style.theme_use('clam')
        style.configure("TButton", font=("Segoe UI", 11), padding=6)

        self.file_path = None

        ttk.Label(master, text="Select a file to convert:", font=("Segoe UI", 12, "bold")).pack(pady=15)

        self.file_entry = ttk.Entry(master, width=50)
        self.file_entry.pack(pady=5)

        ttk.Button(master, text="Browse", command=self.browse_file).pack(pady=5)

        ttk.Label(master, text="Convert to:", font=("Segoe UI", 11)).pack(pady=10)

        self.convert_type = tk.StringVar(value="PDF")
        self.convert_menu = ttk.Combobox(master, textvariable=self.convert_type, state="readonly")
        self.convert_menu["values"] = ["PDF", "TODO: Word", "TODO: PNG", "TODO: JPG"]
        self.convert_menu.pack(pady=5)

        self.convert_btn = ttk.Button(master, text="Convert", command=self.convert_file)
        self.convert_btn.pack(pady=15)

    def browse_file(self):
        filetypes = [
            ("All files", "*.*"),
            ("PDF files", "*.pdf"),
            ("Word files", "*.docx"),
            ("Image files", "*.png;*.jpg;*.jpeg"),
        ]
        path = filedialog.askopenfilename(filetypes=filetypes)
        if path:
            self.file_path = path
            self.file_entry.delete(0, tk.END)
            self.file_entry.insert(0, path)

    def convert_file(self):
        if not self.file_path:
            messagebox.showwarning("No file", "Please select a file to convert.")
            return

        target_type = self.convert_type.get()
        output_path = filedialog.asksaveasfilename(defaultextension=".pdf", filetypes=[("PDF files", "*.pdf")])
        if not output_path:
            return

        if target_type == "PDF":
            from converters.pdf_converter import convert_to_pdf
            try:
                convert_to_pdf(self.file_path, output_path)
                messagebox.showinfo("Success", "File converted to PDF!")
            except Exception as e:
                messagebox.showerror("Error", str(e))
        else:
            messagebox.showinfo("TODO", f"Conversion to {target_type} not implemented yet.")

def run_gui():
    root = tk.Tk()
    app = ConverterApp(root)
    root.mainloop()