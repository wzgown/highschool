#!/usr/bin/env node
/**
 * 区级教育局网站监控脚本
 * 支持多级fallback：web_fetch -> playwright -> agent-reach
 * 
 * 用法: node scrape_districts.mjs [区名或all]
 */

import { chromium } from 'playwright';
import { execSync } from 'child_process';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, '..');
const DATA_DIR = path.join(PROJECT_ROOT, 'original_data', 'raw', '2026', '区级');

// 代理配置
const PROXY_URL = 'http://127.0.0.1:7890';

// 抓取方法
const Method = {
  WEB_FETCH: 'web_fetch',
  PLAYWRIGHT: 'playwright',
  AGENT_REACH: 'agent-reach'
};

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
  '宝山区': {
    url: 'https://www.shbsq.gov.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 1
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
  '奉贤区': {
    url: 'https://www.fengxian.gov.cn/jyj/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 1
  },
  '长宁区': {
    url: 'http://www.chneic.sh.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 1
  },
  '虹口区': {
    url: 'https://www.shhk.gov.cn/',
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
  '青浦区': {
    url: 'https://www.shqp.gov.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 2
  },
  '崇明区': {
    url: 'https://www.shcm.gov.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 2
  },
  '普陀区': {
    url: 'https://www.shpt.gov.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 2
  }
};

// 统一fallback顺序
const DEFAULT_FALLBACK = [Method.WEB_FETCH, Method.PLAYWRIGHT, Method.AGENT_REACH];

function getDistrictsToMonitor() {
  const month = new Date().getMonth() + 1;
  
  if (month >= 5 && month <= 7) {
    return Object.entries(DISTRICTS);
  }
  
  if (month >= 3 && month <= 4) {
    return Object.entries(DISTRICTS).filter(([_, config]) => config.priority === 1);
  }
  
  return [];
}

// 方法1: web_fetch (curl)
async function tryWebFetch(url) {
  try {
    const content = execSync(
      `curl -sL --max-time 15 -x ${PROXY_URL} "${url}" 2>/dev/null`,
      { encoding: 'utf-8', timeout: 20000 }
    );
    
    if (content && (content.includes('<!DOCTYPE') || content.includes('<html'))) {
      const text = content
        .replace(/<script[^>]*>[\s\S]*?<\/script>/gi, '')
        .replace(/<style[^>]*>[\s\S]*?<\/style>/gi, '')
        .replace(/<[^>]+>/g, ' ')
        .replace(/\s+/g, ' ')
        .trim();
      
      if (text.length > 100) {
        return { success: true, content: text.substring(0, 8000), method: Method.WEB_FETCH };
      }
    }
    return { success: false, error: '内容无效或需要JS渲染' };
  } catch (e) {
    return { success: false, error: e.message };
  }
}

// 方法2: Playwright
async function tryPlaywright(browser, url) {
  const result = { success: false, content: '', title: '', error: null, method: Method.PLAYWRIGHT };
  
  try {
    const page = await browser.newPage({
      userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
    });

    try {
      await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 45000 });
      await page.waitForTimeout(2000);
    } catch (navError) {
      // 继续尝试
    }

    result.title = await page.title().catch(() => '');
    const bodyText = await page.evaluate(() => document.body?.innerText || '').catch(() => '');
    result.content = bodyText.substring(0, 8000);
    
    if (result.content.length > 50) {
      result.success = true;
    } else {
      result.error = '内容不足';
    }
    
    await page.close();
  } catch (e) {
    result.error = e.message;
  }

  return result;
}

// 方法3: agent-reach skill (最终fallback)
// 返回标记，由调用方使用openclaw skill系统处理
async function markForAgentReach(url) {
  return { 
    success: false, 
    needsAgentReach: true,
    error: '需要使用agent-reach skill',
    method: Method.AGENT_REACH 
  };
}

// 抓取单个区（带fallback）
async function scrapeDistrict(browser, name, config) {
  const result = {
    district: name,
    url: config.url,
    timestamp: new Date().toISOString(),
    success: false,
    method: null,
    title: '',
    content: '',
    keywords: [],
    attempts: [],
    needsAgentReach: false,
    error: null
  };

  for (const method of DEFAULT_FALLBACK) {
    console.log(`    尝试 ${method}...`);
    
    let fetchResult;
    
    if (method === Method.WEB_FETCH) {
      fetchResult = await tryWebFetch(config.url);
    } else if (method === Method.PLAYWRIGHT) {
      fetchResult = await tryPlaywright(browser, config.url);
    } else if (method === Method.AGENT_REACH) {
      fetchResult = await markForAgentReach(config.url);
      result.needsAgentReach = true;
    }
    
    result.attempts.push({ method, success: fetchResult.success, error: fetchResult.error });
    
    if (fetchResult.success) {
      result.success = true;
      result.method = method;
      result.content = fetchResult.content;
      if (fetchResult.title) result.title = fetchResult.title;
      
      // 检查关键词
      for (const keyword of config.keywords) {
        if (result.content.includes(keyword) || result.title.includes(keyword)) {
          result.keywords.push(keyword);
        }
      }
      break;
    } else {
      console.log(`    ${method} 失败: ${fetchResult.error}`);
    }
  }

  if (!result.success) {
    result.error = '所有方法都失败';
  }

  return result;
}

async function main() {
  const args = process.argv.slice(2);
  const targetDistrict = args[0] || 'all';

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
    console.log('当前时间段不需要监控区级网站');
    return;
  }

  console.log(`开始监控 ${districtsToProcess.length} 个区级网站...`);
  console.log('Fallback策略: web_fetch -> playwright -> agent-reach');
  console.log(`代理: ${PROXY_URL}`);

  if (!fs.existsSync(DATA_DIR)) {
    fs.mkdirSync(DATA_DIR, { recursive: true });
  }

  // 只在需要Playwright时启动浏览器
  const browser = await chromium.launch({ 
    headless: true,
    proxy: { server: PROXY_URL }
  });

  const results = [];
  const today = new Date().toISOString().split('T')[0];

  for (const [name, config] of districtsToProcess) {
    console.log(`\n抓取: ${name}`);
    console.log(`  URL: ${config.url}`);
    
    const result = await scrapeDistrict(browser, name, config);
    results.push(result);

    const status = result.success ? '✅' : (result.needsAgentReach ? '⚠️' : '❌');
    const method = result.method ? ` [${result.method}]` : '';
    const keywords = result.keywords.length > 0 ? ` 关键词: ${result.keywords.join(', ')}` : '';
    console.log(`  ${status} ${result.title.substring(0, 40) || config.url}${method}${keywords}`);
  }

  await browser.close();

  // 保存报告
  const reportFile = path.join(DATA_DIR, `${today}-report.json`);
  const report = {
    date: today,
    timestamp: new Date().toISOString(),
    proxy: PROXY_URL,
    fallbackChain: DEFAULT_FALLBACK,
    total: results.length,
    success: results.filter(r => r.success).length,
    failed: results.filter(r => !r.success).length,
    needsAgentReach: results.filter(r => r.needsAgentReach).map(r => r.district),
    methodStats: {
      web_fetch: results.filter(r => r.method === Method.WEB_FETCH).length,
      playwright: results.filter(r => r.method === Method.PLAYWRIGHT).length,
      agent_reach: results.filter(r => r.needsAgentReach).length
    },
    results: results
  };

  fs.writeFileSync(reportFile, JSON.stringify(report, null, 2));
  console.log(`\n报告已保存: ${reportFile}`);

  // 摘要
  console.log('\n=== 监控摘要 ===');
  console.log(`总计: ${report.total} | 成功: ${report.success} | 失败: ${report.failed}`);
  console.log(`方法统计: web_fetch=${report.methodStats.web_fetch}, playwright=${report.methodStats.playwright}, agent-reach=${report.methodStats.agent_reach}`);

  if (report.needsAgentReach.length > 0) {
    console.log(`\n⚠️ 需要agent-reach处理: ${report.needsAgentReach.join(', ')}`);
  }

  const withKeywords = results.filter(r => r.keywords.length > 0);
  if (withKeywords.length > 0) {
    console.log('\n发现相关内容:');
    for (const r of withKeywords) {
      console.log(`  - ${r.district}: ${r.keywords.join(', ')}`);
    }
  }

  return report;
}

main().catch(console.error);
