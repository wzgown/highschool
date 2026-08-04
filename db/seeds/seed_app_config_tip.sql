-- 打赏码开关迁入 app_config（与 AI 顾问同一套 DB 远程开关机制）
-- 修改方式: UPDATE app_config SET value='...' WHERE key='tip.xxx';
INSERT INTO app_config (key, value, description) VALUES
    ('tip.enabled', 'true', '打赏码总开关（true/false）'),
    ('tip.qr_url', 'https://zg.mkfriend.top/static/tip-qr.jpg', '打赏二维码图片URL'),
    ('tip.review_versions', '', '审核中的小程序版本号（逗号分隔），这些版本隐藏打赏码')
ON CONFLICT (key) DO NOTHING;
