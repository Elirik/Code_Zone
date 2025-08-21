from tkinter import Tk, Listbox, Button, END, filedialog, messagebox
import pdf_utils
from gui import run_gui

class PDFCombinerApp:
    def __init__(self, master):
        self.master = master
        master.title("PDF Combiner")

        self.pdf_files = []

        self.listbox = Listbox(master, selectmode='multiple')
        self.listbox.pack(fill='both', expand=True)

        self.add_button = Button(master, text="Add PDFs", command=self.add_pdfs)
        self.add_button.pack(side='left')

        self.combine_button = Button(master, text="Combine PDFs", command=self.combine_pdfs)
        self.combine_button.pack(side='right')

    def add_pdfs(self):
        files = filedialog.askopenfilenames(filetypes=[("PDF files", "*.pdf")])
        for file in files:
            if file not in self.pdf_files:
                self.pdf_files.append(file)
                self.listbox.insert(END, file)

    def combine_pdfs(self):
        selected_indices = self.listbox.curselection()
        selected_files = [self.pdf_files[i] for i in selected_indices]

        if not selected_files:
            messagebox.showwarning("No Selection", "Please select at least one PDF to combine.")
            return

        output_file = filedialog.asksaveasfilename(defaultextension=".pdf", filetypes=[("PDF files", "*.pdf")])
        if output_file:
            try:
                pdf_utils.combine_pdfs(selected_files, output_file)
                messagebox.showinfo("Success", "PDFs combined successfully!")
            except Exception as e:
                messagebox.showerror("Error", f"An error occurred: {e}")

if __name__ == "__main__":
    run_gui()
    
    