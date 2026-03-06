#!/usr/bin/env node
/**
 * 区级教育局网站监控脚本
 * 支持多级fallback：web_fetch -> Jina Reader -> Playwright
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
  JINA_READER: 'jina_reader',  
  PLAYWRIGHT: 'playwright'
};

// 区级网站配置
const DISTRICTS = {
  '闵行区': {
    url: 'https://zwgk.shmh.gov.cn/mh-xxgk-cms/website/mh_xxgk/xxgk_jyj_ywxx_8/List/list_0.htm',
    keywords: ['中考', '招生', '名额分配', '录取'],
    priority: 1,
    fallbackChain: [Method.PLAYWRIGHT]  // 需要JS渲染
  },
  '黄浦区': {
    url: 'https://www.hpe.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 1,
    fallbackChain: [Method.PLAYWRIGHT]  // 有云防护
  },
  '宝山区': {
    url: 'https://www.shbsq.gov.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 1,
    fallbackChain: [Method.JINA_READER, Method.PLAYWRIGHT]
  },
  '松江区': {
    url: 'http://www.sjedu.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 1,
    fallbackChain: [Method.WEB_FETCH, Method.PLAYWRIGHT]
  },
  '金山区': {
    url: 'http://www.jsedu.sh.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 1,
    fallbackChain: [Method.WEB_FETCH, Method.PLAYWRIGHT]
  },
  '奉贤区': {
    url: 'https://www.fengxian.gov.cn/jyj/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 1,
    fallbackChain: [Method.JINA_READER, Method.PLAYWRIGHT]
  },
  '长宁区': {
    url: 'http://www.chneic.sh.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 1,
    fallbackChain: [Method.JINA_READER, Method.PLAYWRIGHT]
  },
  '虹口区': {
    url: 'https://www.shhk.gov.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 1,
    fallbackChain: [Method.JINA_READER, Method.PLAYWRIGHT]
  },
  '徐汇区': {
    url: 'https://www.xuhui.gov.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 2,
    fallbackChain: [Method.WEB_FETCH, Method.PLAYWRIGHT]
  },
  '静安区': {
    url: 'https://www.jingan.gov.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 2,
    fallbackChain: [Method.WEB_FETCH, Method.PLAYWRIGHT]
  },
  '杨浦区': {
    url: 'https://www.shyp.gov.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 2,
    fallbackChain: [Method.WEB_FETCH, Method.PLAYWRIGHT]
  },
  '嘉定区': {
    url: 'https://www.jiading.gov.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 2,
    fallbackChain: [Method.WEB_FETCH, Method.PLAYWRIGHT]
  },
  '浦东新区': {
    url: 'https://www.pudong.gov.cn/shpd/educoll/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 2,
    fallbackChain: [Method.PLAYWRIGHT]
  },
  '青浦区': {
    url: 'https://www.shqp.gov.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 2,
    fallbackChain: [Method.WEB_FETCH, Method.PLAYWRIGHT]
  },
  '奉贤区': {
    url: 'https://www.fengxian.gov.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 2,
    fallbackChain: [Method.JINA_READER, Method.PLAYWRIGHT]
  },
  '崇明区': {
    url: 'https://www.shcm.gov.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 2,
    fallbackChain: [Method.WEB_FETCH, Method.PLAYWRIGHT]
  },
  '普陀区': {
    url: 'https://www.shpt.gov.cn/',
    keywords: ['中考', '招生', '教育', '录取'],
    priority: 2,
    fallbackChain: [Method.WEB_FETCH, Method.PLAYWRIGHT]
  }
};

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
    
    // 检查是否是有效HTML
    if (content && (content.includes('<!DOCTYPE') || content.includes('<html'))) {
      // 简单提取文本
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
    return { success: false, error: '内容无效或为空' };
  } catch (e) {
    return { success: false, error: e.message };
  }
}

// 方法2: Jina Reader
async function tryJinaReader(url) {
  try {
    const jinaUrl = `https://r.jina.ai/${url}`;
    const content = execSync(
      `curl -sL --max-time 20 "${jinaUrl}" 2>/dev/null`,
      { encoding: 'utf-8', timeout: 25000 }
    );
    
    // 检查是否被拦截
    if (content.includes('403') || content.includes('Forbidden') || content.includes('拒绝执行')) {
      return { success: false, error: '被云防护拦截' };
    }
    
    if (content && content.length > 100) {
      return { success: true, content: content.substring(0, 8000), method: Method.JINA_READER };
    }
    return { success: false, error: '内容不足' };
  } catch (e) {
    return { success: false, error: e.message };
  }
}

// 方法3: Playwright
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
    error: null
  };

  for (const method of config.fallbackChain) {
    console.log(`    尝试 ${method}...`);
    
    let fetchResult;
    
    if (method === Method.WEB_FETCH) {
      fetchResult = await tryWebFetch(config.url);
    } else if (method === Method.JINA_READER) {
      fetchResult = await tryJinaReader(config.url);
    } else if (method === Method.PLAYWRIGHT) {
      fetchResult = await tryPlaywright(browser, config.url);
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
  console.log('Fallback策略: web_fetch -> jina_reader -> playwright');
  console.log(`代理: ${PROXY_URL}`);

  if (!fs.existsSync(DATA_DIR)) {
    fs.mkdirSync(DATA_DIR, { recursive: true });
  }

  // 只在需要Playwright时启动浏览器
  const needsPlaywright = districtsToProcess.some(([_, config]) => 
    config.fallbackChain.includes(Method.PLAYWRIGHT)
  );
  
  const browser = needsPlaywright ? await chromium.launch({ 
    headless: true,
    proxy: { server: PROXY_URL }
  }) : null;

  const results = [];
  const today = new Date().toISOString().split('T')[0];

  for (const [name, config] of districtsToProcess) {
    console.log(`\n抓取: ${name}`);
    console.log(`  URL: ${config.url}`);
    
    const result = await scrapeDistrict(browser, name, config);
    results.push(result);

    const status = result.success ? '✅' : '❌';
    const method = result.method ? ` [${result.method}]` : '';
    const keywords = result.keywords.length > 0 ? ` 关键词: ${result.keywords.join(', ')}` : '';
    console.log(`  ${status} ${result.title.substring(0, 40) || config.url}${method}${keywords}`);
  }

  if (browser) await browser.close();

  // 保存报告
  const reportFile = path.join(DATA_DIR, `${today}-report.json`);
  const report = {
    date: today,
    timestamp: new Date().toISOString(),
    proxy: PROXY_URL,
    total: results.length,
    success: results.filter(r => r.success).length,
    failed: results.filter(r => !r.success).length,
    methodStats: {
      web_fetch: results.filter(r => r.method === Method.WEB_FETCH).length,
      jina_reader: results.filter(r => r.method === Method.JINA_READER).length,
      playwright: results.filter(r => r.method === Method.PLAYWRIGHT).length
    },
    results: results
  };

  fs.writeFileSync(reportFile, JSON.stringify(report, null, 2));
  console.log(`\n报告已保存: ${reportFile}`);

  // 摘要
  console.log('\n=== 监控摘要 ===');
  console.log(`总计: ${report.total} | 成功: ${report.success} | 失败: ${report.failed}`);
  console.log(`方法统计: web_fetch=${report.methodStats.web_fetch}, jina_reader=${report.methodStats.jina_reader}, playwright=${report.methodStats.playwright}`);

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
