import requests, os, sys

# 路径对齐：本文件位于 scripts/parse/，上两级即项目根（含 data/ raw/ output/）
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
RAW_PLAN = os.path.join(ROOT, "raw", "plan")   # 原始 PDF 落盘目录

PDFS = {
    "minxing": "https://zwgk.shmh.gov.cn/mh-xxgk-cms/UploadPath/uploadfile/2026-05-31/a8a78a17-03c9-4684-a4e5-b2066b2e1d10.pdf",
    "jiading": "https://www.jiading.gov.cn/upload/jiaoyu/infopublicity/publicinformation/file/1836aed21b824b95904cfa1493bcfc84.pdf",
    "baoshan": "http://www.bsedu.org.cn/u/cms/www/202605/31115702nwcy.pdf",
    "songjiang": "https://www.songjiang.gov.cn/shsj_main/3d775daf-f695-420b-9ab4-5836eba897c6/b0b78f89-6cdf-47ac-bab6-cae6979842ba/2026%E5%B9%B4%E4%B8%8A%E6%B5%B7%E5%B8%82%E9%AB%98%E4%B8%AD%E5%90%8D%E9%A2%9D%E5%88%86%E9%85%8D%E5%88%B0%E6%A0%A1%E6%8B%9B%E7%94%9F%E8%AE%A1%E5%88%92%EF%BC%88%E6%9D%BE%E6%B1%9F%E5%8C%BA%EF%BC%89.pdf",
}

os.makedirs(RAW_PLAN, exist_ok=True)
for name, url in PDFS.items():
    try:
        r = requests.get(url, timeout=90, headers={"User-Agent":"Mozilla/5.0"})
        print(name, r.status_code, len(r.content), r.headers.get("content-type"))
        if r.status_code == 200 and len(r.content) > 1000:
            open(os.path.join(RAW_PLAN, f"{name}.pdf"), "wb").write(r.content)
        else:
            print("  !! suspicious size/status")
    except Exception as e:
        print(name, "ERR", repr(e))
