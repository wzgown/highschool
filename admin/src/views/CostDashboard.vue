<template>
  <div>
    <div style="display:flex;align-items:center;gap:12px;margin-bottom:12px">
      <el-date-picker
        v-model="dateRange"
        type="daterange"
        value-format="YYYY-MM-DD"
        range-separator="至"
        start-placeholder="开始日期"
        end-placeholder="结束日期"
        :clearable="true"
        @change="load"
      />
      <el-button type="primary" :loading="loading" @click="load">刷新</el-button>
    </div>

    <el-alert v-if="err" :title="err" type="error" show-icon :closable="false" style="margin-bottom:12px" />

    <el-row :gutter="12" style="margin-bottom:12px" v-loading="loading">
      <el-col :span="6">
        <el-card shadow="hover"><el-statistic title="总 Token" :value="stat.totalTokens" /></el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover"><el-statistic title="LLM 调用" :value="stat.totalCalls" /></el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover"><el-statistic title="错误率" :value="stat.errorRate" :precision="2" suffix="%" /></el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover"><el-statistic title="活跃会话" :value="stat.activeSessions" /></el-card>
      </el-col>
    </el-row>

    <el-card shadow="never" style="margin-bottom:12px">
      <div ref="tokenChartEl" style="width:100%;height:300px"></div>
    </el-card>
    <el-card shadow="never" style="margin-bottom:12px">
      <div ref="toolChartEl" style="width:100%;height:300px"></div>
    </el-card>
    <el-card shadow="never">
      <div ref="errorChartEl" style="width:100%;height:300px"></div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, onUnmounted, nextTick } from "vue";
import * as echarts from "echarts";
import {
  ElDatePicker, ElButton, ElAlert, ElRow, ElCol, ElCard, ElStatistic,
} from "element-plus";
import { adminClient } from "../api/client";

// 归一化后的每日数据（int64 bigint → number）
interface LlmDay { day: string; llmCalls: number; totalTokens: number; errorCount: number; }
interface ToolDay { day: string; toolName: string; calls: number; failures: number; }
interface SessDay { day: string; activeSessions: number; }

const dateRange = ref<[string, string] | []>(defaultRange());
const loading = ref(false);
const err = ref("");

const stat = reactive({ totalTokens: 0, totalCalls: 0, errorRate: 0, activeSessions: 0 });

const tokenChartEl = ref<HTMLDivElement | null>(null);
const toolChartEl = ref<HTMLDivElement | null>(null);
const errorChartEl = ref<HTMLDivElement | null>(null);
let tokenChart: echarts.ECharts | null = null;
let toolChart: echarts.ECharts | null = null;
let errorChart: echarts.ECharts | null = null;

function defaultRange(): [string, string] | [] {
  const fmt = (d: Date) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
  const to = new Date();
  const from = new Date();
  from.setDate(from.getDate() - 29);
  return [fmt(from), fmt(to)];
}

async function load() {
  loading.value = true;
  err.value = "";
  try {
    const [from, to] = dateRange.value.length ? dateRange.value : ["", ""];
    const res = await adminClient.getCostDashboard({ from, to });

    const llm: LlmDay[] = res.llmDaily.map((d) => ({
      day: d.day,
      llmCalls: Number(d.llmCalls),
      totalTokens: Number(d.totalTokens),
      errorCount: Number(d.errorCount),
    })).sort((a, b) => (a.day < b.day ? -1 : 1));

    const tool: ToolDay[] = res.toolDaily.map((d) => ({
      day: d.day,
      toolName: d.toolName,
      calls: Number(d.calls),
      failures: Number(d.failures),
    }));

    const sess: SessDay[] = res.sessionDaily.map((d) => ({
      day: d.day,
      activeSessions: Number(d.activeSessions),
    }));

    // 统计卡片
    const totalTokens = llm.reduce((s, d) => s + d.totalTokens, 0);
    const totalCalls = llm.reduce((s, d) => s + d.llmCalls, 0);
    const errorCount = llm.reduce((s, d) => s + d.errorCount, 0);
    stat.totalTokens = totalTokens;
    stat.totalCalls = totalCalls;
    stat.errorRate = totalCalls > 0 ? (errorCount / totalCalls) * 100 : 0;
    stat.activeSessions = sess.reduce((s, d) => s + d.activeSessions, 0);

    await nextTick();
    renderTokenChart(llm);
    renderToolChart(tool);
    renderErrorChart(llm);
  } catch (e) {
    err.value = "加载失败：" + (e instanceof Error ? e.message : String(e));
  } finally {
    loading.value = false;
  }
}

function renderTokenChart(llm: LlmDay[]) {
  if (!tokenChart) return;
  tokenChart.setOption({
    title: { text: "每日 Token / 调用", left: "center" },
    tooltip: { trigger: "axis" },
    legend: { data: ["Token", "调用"], top: 28 },
    grid: { left: 56, right: 56, top: 64, bottom: 32 },
    xAxis: { type: "category", data: llm.map((d) => d.day) },
    yAxis: [
      { type: "value", name: "Token" },
      { type: "value", name: "调用" },
    ],
    series: [
      { name: "Token", type: "line", smooth: true, data: llm.map((d) => d.totalTokens) },
      { name: "调用", type: "line", smooth: true, yAxisIndex: 1, data: llm.map((d) => d.llmCalls) },
    ],
  });
}

function renderToolChart(tool: ToolDay[]) {
  if (!toolChart) return;
  // 按 toolName 聚合跨天数据
  const agg = new Map<string, { calls: number; failures: number }>();
  for (const t of tool) {
    const cur = agg.get(t.toolName) ?? { calls: 0, failures: 0 };
    cur.calls += t.calls;
    cur.failures += t.failures;
    agg.set(t.toolName, cur);
  }
  const names = [...agg.keys()];
  toolChart.setOption({
    title: { text: "工具调用 / 失败", left: "center" },
    tooltip: { trigger: "axis" },
    legend: { data: ["调用", "失败"], top: 28 },
    grid: { left: 56, right: 32, top: 64, bottom: 32 },
    xAxis: { type: "category", data: names },
    yAxis: { type: "value" },
    series: [
      { name: "调用", type: "bar", data: names.map((n) => agg.get(n)!.calls) },
      { name: "失败", type: "bar", data: names.map((n) => agg.get(n)!.failures) },
    ],
  });
}

function renderErrorChart(llm: LlmDay[]) {
  if (!errorChart) return;
  errorChart.setOption({
    title: { text: "每日错误率", left: "center" },
    tooltip: { trigger: "axis", valueFormatter: (v: number | string) => `${v}%` },
    grid: { left: 56, right: 32, top: 56, bottom: 32 },
    xAxis: { type: "category", data: llm.map((d) => d.day) },
    yAxis: { type: "value", name: "%", axisLabel: { formatter: "{value}%" } },
    series: [
      {
        name: "错误率",
        type: "line",
        smooth: true,
        data: llm.map((d) => (d.llmCalls > 0 ? +((d.errorCount / d.llmCalls) * 100).toFixed(4) : 0)),
      },
    ],
  });
}

function onResize() {
  tokenChart?.resize();
  toolChart?.resize();
  errorChart?.resize();
}

onMounted(async () => {
  await nextTick();
  if (tokenChartEl.value) tokenChart = echarts.init(tokenChartEl.value);
  if (toolChartEl.value) toolChart = echarts.init(toolChartEl.value);
  if (errorChartEl.value) errorChart = echarts.init(errorChartEl.value);
  window.addEventListener("resize", onResize);
  load();
});

onUnmounted(() => {
  window.removeEventListener("resize", onResize);
  tokenChart?.dispose();
  toolChart?.dispose();
  errorChart?.dispose();
  tokenChart = toolChart = errorChart = null;
});
</script>
