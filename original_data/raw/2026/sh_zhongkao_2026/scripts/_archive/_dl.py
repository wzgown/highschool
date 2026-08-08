import urllib.request, ssl
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE
urls = {
 "jingan_plan.pdf": "https://www.jingan.gov.cn/main/3a47a940-c455-443b-b149-749e20feab8f/13946ee2-5737-45cd-b2d3-7cf61d148eaf/2026%E5%B9%B4%E4%B8%8A%E6%B5%B7%E5%B8%82%E9%AB%98%E4%B8%AD%E5%90%8D%E9%A2%9D%E5%88%86%E9%85%8D%E5%88%B0%E6%A0%A1%E6%8B%9B%E7%94%9F%E8%AE%A1%E5%88%92%EF%BC%88%E9%9D%99%E5%AE%89%E5%8C%BA%EF%BC%89.pdf",
 "yangpu_plan.pdf": "https://www.shyp.gov.cn:446/shypq/yqyw-wb-jyjzl-ypzs-gzjdzs/20260531/506517/ae6db96eab0a47d283f5b030e8046e62.pdf",
 "xuhui_plan.pdf": "https://www.xuhui.gov.cn/egov/uploads/info/4/b/4b4d7f49f935240.pdf",
 "putuo_plan.pdf": "https://kszx.pte.sh.cn/upload/2026/05/2a90a520293c4d06a86312887167de56.pdf",
}
for name, u in urls.items():
    try:
        req = urllib.request.Request(u, headers={"User-Agent":"Mozilla/5.0"})
        data = urllib.request.urlopen(req, timeout=60, context=ctx).read()
        open(name,"wb").write(data)
        print(name, "OK", len(data))
    except Exception as e:
        print(name, "FAIL", repr(e))
