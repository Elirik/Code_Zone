def combine_pdfs(pdf_list, output_path):
    from PyPDF2 import PdfWriter, PdfReader

    pdf_writer = PdfWriter()

    for pdf in pdf_list:
        pdf_reader = PdfReader(pdf)
        for page in range(len(pdf_reader.pages)):
            pdf_writer.add_page(pdf_reader.pages[page])

    with open(output_path, 'wb') as out_file:
        pdf_writer.write(out_file)

def get_pdf_list(directory):
    import os

    pdf_files = [f for f in os.listdir(directory) if f.endswith('.pdf')]
    return pdf_files

def is_valid_pdf(file_path):
    from PyPDF2 import PdfReader

    try:
        PdfReader(file_path)
        return True
    except Exception:
        return False