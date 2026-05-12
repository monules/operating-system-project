import os
from pypdf import PdfReader
import re

pdf_dir = '/Users/saidumaregamberdiev/github/operating-system-project/lecture-files/'
output_file = '/Users/saidumaregamberdiev/github/operating-system-project/lecture-files/pdf_summary.txt'

pdf_files = [f for f in os.listdir(pdf_dir) if f.endswith('.pdf')]
pdf_files.sort()

with open(output_file, 'w', encoding='utf-8') as out:
    for pdf_file in pdf_files:
        filepath = os.path.join(pdf_dir, pdf_file)
        try:
            reader = PdfReader(filepath)
            text = ""
            for page in reader.pages:
                page_text = page.extract_text()
                if page_text:
                    text += page_text + "\n"
            
            # Clean up text a bit
            text = re.sub(r'\n+', '\n', text)
            
            # Write header
            out.write(f"=== File: {pdf_file} ===\n")
            
            # Extract keywords or specific areas
            out.write("Content Snippet (first 1000 chars):\n")
            out.write(text[:1000] + "\n...\n")
            
            # Search for specific tools/automation keywords
            keywords = ["automation", "cron", "tar", "syslog", "grep", "awk", "shell script", "bash", "schedule", "backup", "log"]
            found = set()
            for kw in keywords:
                if kw.lower() in text.lower():
                    found.add(kw)
            
            if found:
                out.write(f"Keywords found: {', '.join(found)}\n")
            
            out.write("\n\n")
            
        except Exception as e:
            out.write(f"=== File: {pdf_file} ===\nError reading: {e}\n\n")

print(f"Summary written to {output_file}")
