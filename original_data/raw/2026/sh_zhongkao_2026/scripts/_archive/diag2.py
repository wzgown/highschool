import pdfplumber

with pdfplumber.open("pdfs/baoshan.pdf") as pdf:
    page = pdf.pages[0]
    chars = page.chars
    # sample some chars: check rotation, color, fontname
    from collections import Counter
    rots = Counter(round(c.get("upright") if c.get("upright") is not None else 1) for c in chars[:50])
    print("sample uprights:", rots)
    # find a cell with watermark char '经' and a digit nearby
    for c in chars[:200]:
        if c["text"] in ("经","未","许","可","转","载","得","不"):
            print("WM char:", c["text"], "x0=%.1f y0=%.1f size=%.1f font=%s color=%s" % (
                c["x0"], c["top"], c["size"], c.get("fontname"), c.get("non_stroking_color")))
            break
    # show a digit char props
    for c in chars[:400]:
        if c["text"].isdigit():
            print("DIGIT:", c["text"], "x0=%.1f y0=%.1f size=%.1f font=%s color=%s" % (
                c["x0"], c["top"], c["size"], c.get("fontname"), c.get("non_stroking_color")))
            break
    # count watermark chars vs digits on page
    wm = set("未经许可不得转载，。")
    print("wm chars:", sum(1 for c in chars if c["text"] in wm))
    print("digit chars:", sum(1 for c in chars if c["text"].isdigit()))
