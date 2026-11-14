
import streamlit as st
import pymupdf
from google import genai
import os

# -------------------------------
# GEMINI API CONFIGURATION
# -------------------------------

client = genai.Client(
    api_key=os.environ.get("GEMINI_API_KEY")
)


# -------------------------------
# AI RESPONSE FUNCTION
# -------------------------------

def ask_ai(prompt):
    try:
        response = client.models.generate_content(
            model="gemini-3.5-flash-lite",
            contents=prompt
        )

        result = response.text

        if result:
            return result
        else:
            return "Sorry, the AI could not generate a response. Please try again."

    except Exception as e:
        return f"AI Error: {e}"


# -------------------------------
# MCQ GENERATION FUNCTION
# -------------------------------

def generate_mcqs(text):
    prompt = (
        "Generate exactly 5 exam-oriented multiple-choice questions "
        "based strictly on the following study material.\n\n"

        "Requirements:\n"
        "1. Each question must have exactly 4 options: A, B, C and D.\n"
        "2. Only one option must be correct.\n"
        "3. Make all incorrect options clearly different from the correct answer.\n"
        "4. Do not create duplicate, overlapping or equivalent options.\n"
        "5. Avoid options where 'Both A and B' or 'All of the above' "
        "is the correct answer.\n"
        "6. Include the correct answer after every question.\n"
        "7. Include a brief explanation for the correct answer.\n"
        "8. Cover different important concepts from the material.\n"
        "9. Use simple language suitable for college students.\n"
        "10. Do not introduce facts outside the provided material.\n\n"

        "Study Material:\n" + text[:10000]
    )

    return ask_ai(prompt)


# -------------------------------
# PAGE CONFIGURATION
# -------------------------------

st.set_page_config(
    page_title="NoteWise",
    page_icon="📚",
    layout="centered"
)


# -------------------------------
# CUSTOM CSS
# -------------------------------

st.markdown("""
<style>

.stApp {
    background-color: #F5F7FC;
}

/* Main heading */
h1 {
    color: #243B64 !important;
    font-weight: 750;
}

/* General headings */
h2, h3, h4 {
    color: #243B64;
}

/* Normal text */
.stMarkdown p,
.stMarkdown li {
    color: #243B64;
}

/* Buttons */
.stButton > button {
    background-color: #4263A5;
    color: white;
    border-radius: 10px;
    border: none;
    padding: 10px 20px;
    font-weight: 600;
}

.stButton > button:hover {
    background-color: #304D85;
    color: white;
}

/* PDF uploader */
[data-testid="stFileUploader"] {
    background-color: white;
    padding: 18px;
    border-radius: 12px;
    border: 1px solid #DCE3F0;
}

/* Feature cards */
.feature-card {
    background: linear-gradient(145deg, #243B64, #365B91);
    padding: 24px;
    border-radius: 15px;
    min-height: 155px;
    margin-bottom: 15px;
    box-shadow: 0 4px 12px rgba(30, 50, 90, 0.15);
}

.feature-card h3 {
    color: white !important;
    margin-bottom: 12px;
}

.feature-card p {
    color: #E8EFFA !important;
    font-size: 15px;
    line-height: 1.6;
}

/* Extracted PDF text */
.stTextArea textarea {
    color: #243B64 !important;
    background-color: white !important;
    -webkit-text-fill-color: #243B64 !important;
}

/* Generated AI content */
[data-testid="stMarkdownContainer"] {
    color: #243B64;
}

</style>
""", unsafe_allow_html=True)


# -------------------------------
# NOTEWISE HEADER
# -------------------------------

st.markdown("""
<div style="
    background: linear-gradient(135deg, #243B64, #5276B9);
    padding: 35px;
    border-radius: 18px;
    color: white;
    margin-bottom: 25px;
">
    <h1 style="color:white !important;">📚 NoteWise</h1>
    <h3 style="color:white !important;">Your Smart Study Assistant</h3>
    <p style="color:#E5EAF5 !important;">
        Transform your PDF study material into concise notes
        and intelligent practice questions.
    </p>
</div>
""", unsafe_allow_html=True)


# -------------------------------
# FEATURES SECTION
# -------------------------------

st.markdown("""
<h2 style="
    color: #243B64 !important;
    font-size: 30px;
    font-weight: 800;
    margin-top: 15px;
    margin-bottom: 8px;
">
    ✨ What can NoteWise do?
</h2>
""", unsafe_allow_html=True)

st.markdown("""
<p style="color: #526783 !important; font-size: 16px;">
Three simple tools to make your study preparation easier.
</p>
""", unsafe_allow_html=True)


col1, col2, col3 = st.columns(3)

with col1:
    st.markdown("""
    <div class="feature-card">
        <h3>📄 PDF Upload</h3>
        <p>Upload your PDF study material and extract its text in seconds.</p>
    </div>
    """, unsafe_allow_html=True)

with col2:
    st.markdown("""
    <div class="feature-card">
        <h3>📝 AI Summary</h3>
        <p>Convert lengthy study material into concise, exam-oriented notes.</p>
    </div>
    """, unsafe_allow_html=True)

with col3:
    st.markdown("""
    <div class="feature-card">
        <h3>❓ AI MCQs</h3>
        <p>Generate practice questions with four options, answers and explanations.</p>
    </div>
    """, unsafe_allow_html=True)


st.divider()


# -------------------------------
# PDF UPLOAD
# -------------------------------

uploaded_file = st.file_uploader(
    "Upload your PDF notes",
    type=["pdf"]
)


if uploaded_file is not None:

    try:
        document = pymupdf.open(
            stream=uploaded_file.getvalue(),
            filetype="pdf"
        )

        text = ""

        for page in document:
            text += page.get_text()

        document.close()

        if text.strip():

            st.success("PDF uploaded successfully!")

            st.write("### Total characters extracted:", len(text))

            st.markdown("### Extracted Notes")

            st.text_area(
                "Your PDF content",
                text,
                height=300
            )


            # -------------------------------
            # AI SUMMARY GENERATION
            # -------------------------------

            if st.button("Generate AI Summary"):

                with st.spinner("Generating summary..."):

                    summary = ask_ai(
                        "Summarize the following study material into concise, "
                        "well-organized exam-oriented notes.\n\n"

                        "Follow these rules strictly:\n"
                        "1. Do not copy the entire source text word for word.\n"
                        "2. Reduce the content to approximately 40-50% of its original length.\n"
                        "3. Keep all important definitions and concepts.\n"
                        "4. Remove repeated sentences and unnecessary explanations.\n"
                        "5. Use clear headings, subheadings and bullet points.\n"
                        "6. Explain difficult concepts in simple student-friendly language.\n"
                        "7. Keep useful examples from the original material.\n"
                        "8. Do not introduce facts that are not in the PDF.\n"
                        "9. Preserve important technical terms and classifications.\n"
                        "10. Make the notes useful for college examination revision.\n\n"

                        "Study Material:\n" + text[:10000]
                    )

                st.markdown("### AI-Generated Summary")

                st.markdown(summary)

                st.write("Original characters:", len(text))
                st.write("Summary characters:", len(summary))


            # -------------------------------
            # AI MCQ GENERATION
            # -------------------------------

            if st.button("Generate AI MCQs"):

                with st.spinner("Generating MCQs..."):

                    mcqs = generate_mcqs(text)

                st.markdown("### AI-Generated MCQs")

                st.markdown(mcqs)

        else:
            st.warning("No readable text found in this PDF.")

    except Exception as e:
        st.error(f"Unable to process this PDF: {e}")








        
