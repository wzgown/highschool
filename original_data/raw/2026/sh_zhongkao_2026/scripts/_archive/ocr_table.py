# -*- coding: utf-8 -*-
"""对徐汇到校计划 PDF 做预处理+OCR，尝试还原表格。"""
import sys
from PIL import Image
import pytesseract, numpy as np

BASE = "/Users/wangzhigang/WorkBuddy/2026-07-23-16-07-03/sh_zhongkao_2026/data/"

def ocr_image(img, upscale, psm):
    img = img.convert("L")
    w, h = img.size
    img = img.resize((w*upscale, h*upscale), Image.LANCZOS)
    arr = np.array(img).astype("float32")
    # Otsu 全局阈值
    hist, _ = np.histogram(arr.astype("uint8"), 256, [0, 256])
    total = arr.size
    sumv = np.dot(np.arange(256), hist)
    sumB = wB = mx = thr = 0
    for i in range(256):
        wB += hist[i]
        if wB == 0:
            continue
        wF = total - wB
        if wF == 0:
            break
        sumB += i * hist[i]
        mB = sumB / wB
        mF = (sumv - sumB) / wF
        between = wB * wF * (mB - mF) ** 2
        if between > mx:
            mx = between
            thr = i
    binar = (arr > thr) * 255
    out = Image.fromarray(binar.astype("uint8"))
    # 反相：若背景偏亮则黑字白底，tesseract 偏好暗字亮底；若多数像素亮则反相
    return pytesseract.image_to_string(out, lang="chi_sim+eng", config=f"--psm {psm}")

for p in [1, 2]:
    path = f"{BASE}xuhui_page-{p}.png"
    im = Image.open(path)
    print(f"\n########## PAGE {p}  size={im.size} ##########")
    for up in [2, 3]:
        for psm in [6, 11]:
            txt = ocr_image(im, up, psm)
            print(f"----- up={up} psm={psm} 非空字符数={len(txt.strip())} -----")
            print(txt[:2500])
