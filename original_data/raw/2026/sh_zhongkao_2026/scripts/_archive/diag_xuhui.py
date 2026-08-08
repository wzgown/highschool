# -*- coding: utf-8 -*-
"""诊断：用列坐标聚类把徐汇数字矩阵归列，验证可行性。"""
from PIL import Image
import pytesseract, numpy as np, re

BASE = "/Users/wangzhigang/WorkBuddy/2026-07-23-16-07-03/sh_zhongkao_2026/data/"

def binarize(img):
    img = img.convert("L")
    arr = np.array(img).astype("float32")
    hist, _ = np.histogram(arr.astype("uint8"), 256, [0, 256])
    total = arr.size; sumv = np.dot(np.arange(256), hist)
    sumB = wB = mx = thr = 0
    for i in range(256):
        wB += hist[i]
        if wB == 0: continue
        wF = total - wB
        if wF == 0: break
        sumB += i*hist[i]; mB = sumB/wB; mF = (sumv-sumB)/wF
        between = wB*wF*(mB-mF)**2
        if between > mx: mx = between; thr = i
    return Image.fromarray(((arr > thr)*255).astype("uint8"))

def prep(path, crop_y=None):
    im = Image.open(path)
    if crop_y: im = im.crop((0, crop_y, im.width, im.height))
    im = im.resize((im.width*4, im.height*4), Image.LANCZOS)
    return binarize(im)

# 已知 11 所高中（列顺序）
COLS = ["南洋模范","位育中学","市二中学","市二梅陇","南洋中学","复附徐汇","上海中学","交大附中","复旦附中","华二附中","上师附中"]

def process(img, label):
    data = pytesseract.image_to_data(img, lang="chi_sim+eng", output_type=pytesseract.Output.DICT)
    n = len(data["text"])
    toks = []
    for i in range(n):
        t = data["text"][i].strip()
        if not t: continue
        toks.append((data["left"][i], data["top"][i], data["width"][i], t))
    # 找表头：含多个列名前缀的行
    PREFIXES = ["南洋","位育","市二","复附","上海","交大","复旦","华二","上师"]
    def is_head(t):
        return any(p in t or t in p for p in PREFIXES)
    def col_center_from_header():
        rows = {}
        for l,tp,w,t in toks:
            rows.setdefault(tp//30, []).append((l,tp,w,t))
        best=None;bestc=0;besttop=1e9
        for b,items in rows.items():
            c=sum(1 for _,_,_,t in items if is_head(t))
            if c>bestc or (c==bestc and c>0 and items[0][1]<besttop):
                bestc=c;best=items;besttop=items[0][1]
        if not best or bestc<6: return []
        centers=[]
        for l,tp,w,t in best:
            if is_head(t):
                centers.append((l+w//2,t))
        centers.sort()
        return [c for c,_ in centers]
    centers = col_center_from_header()
    print(f"\n##### {label}: 识别到列中心数={len(centers)} #####")
    print("列中心x:", centers)
    if len(centers)<11:
        print("  ⚠ 列中心不足11，跳过归列")
        return
    # 数字 token 按行聚类并归列
    digs=[(l,tp,t) for l,tp,w,t in toks if re.fullmatch(r"\d+", t)]
    rows={}
    for l,tp,t in digs:
        rows.setdefault(tp//25, []).append((l,t))
    print(f"数字行数(桶)={len(rows)}")
    # 打印前若干行归列结果
    cnt=0
    for b in sorted(rows):
        row=[None]*len(centers)
        for l,t in rows[b]:
            ci=min(range(len(centers)), key=lambda i: abs(centers[i]-l))
            row[ci]=t
        if any(row):
            print(f"  y~{b*25}: {row}")
            cnt+=1
        if cnt>=45: break

process(prep(f"{BASE}xuhui_page-2.png"), "PAGE2")
process(prep(f"{BASE}xuhui_page-1.png", crop_y=760), "PAGE1-table")
