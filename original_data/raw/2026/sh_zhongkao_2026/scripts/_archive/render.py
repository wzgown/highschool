import pdfplumber
with pdfplumber.open("pdfs/songjiang.pdf") as pdf:
    for i,p in enumerate(pdf.pages):
        im = p.to_image(resolution=170)
        im.save(f"pdfs/songjiang_p{i}.png")
        print("saved", i, p.width, p.height)
