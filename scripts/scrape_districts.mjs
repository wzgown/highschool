#!/usr/bin/env node
/**
 * 区级教育局网站监控脚本
 * 使用 Playwright + 代理抓取动态内容
 * 
 * 用法: node scrape_districts.mjs [区名或all]
 */

import { chromium } from 'playwright';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, '..');
const DATA_DIR = path.join(PROJECT_ROOT, 'original_data', 'raw', '2026', '区级');

// 代理配置
const PROXY = { server: 'http://127.0.0.1:7890' };

// 区级网站配置
const DISTRICTS = {
  '闵行区': {
    url: 'https://zwgk.shmh.gov.cn/mh-xxgk-cms/website/mh_xxgk/xxgk_jyj_ywxx_8/List/list_0.htm',
    keywords: ['中考', '招生', '名额分配', '录取'],
    priority: 1
  },
  '黄浦区': {
    url: 'https://www.hpe.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 1
  },
  '徐汇区': {
    url: 'https://www.xuhui.gov.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 2
  },
  '静安区': {
    url: 'https://www.jingan.gov.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 2
  },
  '杨浦区': {
    url: 'https://www.shyp.gov.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 2
  },
  '宝山区': {
    url: 'https://www.shbsq.gov.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 1
  },
  '嘉定区': {
    url: 'https://www.jiading.gov.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 2
  },
  '浦东新区': {
    url: 'https://www.pudong.gov.cn/shpd/educoll/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 2
  },
  '松江区': {
    url: 'http://www.sjedu.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 1
  },
  '金山区': {
    url: 'http://www.jsedu.sh.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 1
  },
  '青浦区': {
    url: 'https://www.shqp.gov.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 2
  },
  '奉贤区': {
    url: 'https://www.fengxian.gov.cn/jyj/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 1
  },
  '崇明区': {
    url: 'https://www.shcm.gov.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 2
  },
  '长宁区': {
    url: 'http://www.chneic.sh.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 1
  },
  '普陀区': {
    url: 'https://www.shpt.gov.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 2
  },
  '虹口区': {
    url: 'https://www.shhk.gov.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 1
  }
};

// 获取当前月份，决定监控范围
function getDistrictsToMonitor() {
  const month = new Date().getMonth() + 1; // 1-12
  
  // 5-7月：全面监控
  if (month >= 5 && month <= 7) {
    return Object.entries(DISTRICTS);
  }
  
  // 3-4月：重点监控（priority 1）
  if (month >= 3 && month <= 4) {
    return Object.entries(DISTRICTS).filter(([_, config]) => config.priority === 1);
  }
  
  // 其他月份：不监控区级（由市级监控覆盖）
  return [];
}

// 抓取单个区
async function scrapeDistrict(browser, name, config) {
  const result = {
    district: name,
    url: config.url,
    timestamp: new Date().toISOString(),
    success: false,
    title: '',
    content: '',
    keywords: [],
    error: null
  };

  try {
    const page = await browser.newPage({
      userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
    });

    try {
      await page.goto(config.url, { 
        waitUntil: 'domcontentloaded', 
        timeout: 45000 
      });
      await page.waitForTimeout(2000);
    } catch (navError) {
      // 继续尝试获取内容
      console.log(`  导航警告: ${navError.message}`);
    }

    result.title = await page.title().catch(() => '');
    const bodyText = await page.evaluate(() => document.body?.innerText || '').catch(() => '');
    result.content = bodyText.substring(0, 10000);

    // 检查关键词
    for (const keyword of config.keywords) {
      if (result.content.includes(keyword) || result.title.includes(keyword)) {
        result.keywords.push(keyword);
      }
    }

    result.success = true;
    await page.close();

  } catch (error) {
    result.error = error.message;
  }

  return result;
}

// 主函数
async function main() {
  const args = process.argv.slice(2);
  const targetDistrict = args[0] || 'all';

  // 确定要监控的区
  let districtsToProcess;
  if (targetDistrict === 'all') {
    districtsToProcess = getDistrictsToMonitor();
  } else {
    const config = DISTRICTS[targetDistrict];
    if (!config) {
      console.error(`未知区: ${targetDistrict}`);
      console.log('可用区:', Object.keys(DISTRICTS).join(', '));
      process.exit(1);
    }
    districtsToProcess = [[targetDistrict, config]];
  }

  if (districtsToProcess.length === 0) {
    console.log('当前时间段不需要监控区级网站（仅监控市级）');
    return;
  }

  console.log(`开始监控 ${districtsToProcess.length} 个区级网站...`);
  console.log('使用代理:', PROXY.server);

  // 确保数据目录存在
  if (!fs.existsSync(DATA_DIR)) {
    fs.mkdirSync(DATA_DIR, { recursive: true });
  }

  const browser = await chromium.launch({ 
    headless: true,
    proxy: PROXY
  });

  const results = [];
  const today = new Date().toISOString().split('T')[0];
  const reportFile = path.join(DATA_DIR, `${today}-report.json`);

  for (const [name, config] of districtsToProcess) {
    console.log(`\n抓取: ${name}`);
    console.log(`  URL: ${config.url}`);
    
    const result = await scrapeDistrict(browser, name, config);
    results.push(result);

    const status = result.success ? '✅' : '❌';
    const keywords = result.keywords.length > 0 ? ` [关键词: ${result.keywords.join(', ')}]` : '';
    console.log(`  ${status} ${result.title.substring(0, 50)}${keywords}`);
    
    if (result.error) {
      console.log(`  错误: ${result.error}`);
    }
  }

  await browser.close();

  // 保存报告
  const report = {
    date: today,
    timestamp: new Date().toISOString(),
    proxy: PROXY.server,
    total: results.length,
    success: results.filter(r => r.success).length,
    failed: results.filter(r => !r.success).length,
    results: results
  };

  fs.writeFileSync(reportFile, JSON.stringify(report, null, 2));
  console.log(`\n报告已保存: ${reportFile}`);

  // 输出摘要
  console.log('\n=== 监控摘要 ===');
  console.log(`总计: ${report.total} 个网站`);
  console.log(`成功: ${report.success}`);
  console.log(`失败: ${report.failed}`);

  // 检查有关键词匹配的内容
  const withKeywords = results.filter(r => r.keywords.length > 0);
  if (withKeywords.length > 0) {
    console.log('\n⚠️ 发现相关内容:');
    for (const r of withKeywords) {
      console.log(`  - ${r.district}: ${r.keywords.join(', ')}`);
    }
  }

  return report;
}

main().catch(console.error);
