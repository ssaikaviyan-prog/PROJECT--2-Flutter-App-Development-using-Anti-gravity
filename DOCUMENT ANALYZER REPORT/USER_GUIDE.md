# User Guide & Setup Manual — AI Document Analyzer

## Overview
This manual provides step-by-step instructions for running, configuring, and testing the **AI Document Analyzer** component within the **Vision-Language Autonomous Navigation System**.

---

## 1. Prerequisites

- **Python 3.10+** (Python 3.14 detected on system)
- **Flutter SDK 3.24+** (Flutter 3.44 installed)
- **Google Gemini API Key** (from [Google AI Studio](https://aistudio.google.com/))

---

## 2. Environment Setup

### Step 1: Set up Gemini API Key
Create or edit the `.env` file in the project root:
```env
GEMINI_API_KEY=your_actual_gemini_api_key_here
```

*Note: If no API key is provided, the application runs seamlessly in **Demo Mode** with realistic technical responses.*

### Step 2: Install Python Backend Dependencies
Navigate to the `document_analyzer/` directory and install dependencies:
```bash
pip install -r document_analyzer/requirements.txt
```

---

## 3. Running the Python RAG Backend Server

Start the REST API server:
```bash
python document_analyzer/main.py
```
*The server starts at `http://localhost:8000`. You can test API endpoints at `http://localhost:8000/docs`.*

---

## 4. Running the Flutter App

Run the Flutter application on your mobile device or emulator:
```bash
flutter run
```

---

## 5. Using the Document Analyzer Interface

1. **Navigate to the Document Analyzer Screen**:
   - Tap the **Doc RAG** item in the bottom navigation bar or side drawer.
2. **Upload a Technical Document**:
   - Tap **Upload Document** and select a `.pdf`, `.docx`, `.txt`, or `.md` file (e.g. `robot_navigation.pdf`).
3. **View Summary & Metadata**:
   - Expand the **Document Summary** panel to see page count, word count, key topics, and tap **"Explain Simply"** for an accessible overview.
4. **Ask Questions**:
   - Type questions like:
     - *"What sensors are used for navigation?"*
     - *"Compare LiDAR and RGB-D camera perception."*
     - *"Summarize section 2."*
5. **Inspect Source Citations**:
   - Check the **Sources** chip below the answer (e.g. `robot_navigation.pdf — Page 5`).
