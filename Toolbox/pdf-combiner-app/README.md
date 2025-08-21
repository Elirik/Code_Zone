# PDF Combiner Application

This project is a simple PDF combiner application that allows users to combine multiple PDF files into a single document. The application features a user-friendly graphical interface that enables users to easily add, exclude, and combine PDF files.

## Features

- Add multiple PDF files to the application.
- View a list of added PDF files.
- Exclude specific PDF files from the final combined document.
- Combine the selected PDF files into a single PDF document.

## Project Structure

```
pdf-combiner-app
├── src
│   ├── main.py          # Entry point of the application
│   ├── gui.py           # GUI definition and logic
│   └── pdf_utils.py     # PDF handling utilities
├── requirements.txt     # Project dependencies
└── README.md            # Project documentation
```

## Requirements

To run this application, you need to install the following dependencies:

- Python 3.x
- PyPDF2 (or any other PDF handling library)
- Tkinter (or any other GUI framework)

You can install the required packages using pip:

```
pip install -r requirements.txt
```

## Usage

1. Clone the repository or download the source code.
2. Navigate to the project directory.
3. Install the required dependencies.
4. Run the application using the following command:

```
python src/main.py
```

5. Use the GUI to add PDF files, exclude any unwanted files, and combine the selected PDFs.

## License

This project is open-source and available under the MIT License. Feel free to modify and distribute it as per your needs.