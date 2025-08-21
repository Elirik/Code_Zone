import os

def convert_to_pdf(input_path, output_path):
    ext = os.path.splitext(input_path)[1].lower()
    try:
        if ext == ".docx":
            from docx2pdf import convert as docx2pdf_convert
            docx2pdf_convert(input_path, output_path)
        elif ext in [".png", ".jpg", ".jpeg"]:
            from PIL import Image
            img = Image.open(input_path)
            img.save(output_path, "PDF")
        elif ext == ".pdf":
            import shutil
            shutil.copy(input_path, output_path)
        else:
            raise Exception("Unsupported file type for PDF conversion")
    except Exception as e:
        raise e