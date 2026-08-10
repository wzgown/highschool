<template>
  <div v-loading="loading">
    <el-page-header @back="$router.back()" :content="`会话 #${id}`" style="margin-bottom:12px" />
    <el-tabs v-model="tab">
      <el-tab-pane label="时间线" name="timeline">
        <el-timeline>
          <el-timeline-item v-for="e in timeline" :key="e.id" :timestamp="e.ts" :type="e.t" placement="top">
            <strong>[{{ e.kind }}]</strong> <span v-if="e.title">{{ e.title }}</span>
            <pre v-if="e.body" style="white-space:pre-wrap;background:#f6f8fa;padding:8px;margin-top:4px">{{ e.body }}</pre>
          </el-timeline-item>
        </el-timeline>
      </el-tab-pane>
      <el-tab-pane label="消息" name="messages">
        <div v-for="(m,i) in bundle.messages" :key="i" style="margin-bottom:10px">
          <el-tag size="small">{{ m.role }}</el-tag>
          <span style="color:#999;margin-left:8px">{{ m.createdAt }}</span>
          <div style="white-space:pre-wrap">{{ m.content }}</div>
        </div>
      </el-tab-pane>
      <el-tab-pane label="Trace" name="traces">
        <el-collapse>
          <el-collapse-item v-for="(t,i) in bundle.traces" :key="i" :name="i" :title="`[${t.kind}] ${t.name} · ${t.latencyMs}ms · ${t.promptTokens+t.completionTokens}tok`">
            <div><b>in:</b><pre style="white-space:pre-wrap">{{ fmt(t.inputJson) }}</pre></div>
            <div><b>out:</b><pre style="white-space:pre-wrap">{{ fmt(t.outputJson) }}</pre></div>
          </el-collapse-item>
        </el-collapse>
      </el-tab-pane>
      <el-tab-pane label="Checkpoint" name="checkpoints">
        <el-collapse>
          <el-collapse-item v-for="(c,i) in bundle.checkpoints" :key="i" :name="i" :title="`#${c.stepSeq} ${c.node}`">
            <pre style="white-space:pre-wrap">{{ fmt(c.stateJson) }}</pre>
          </el-collapse-item>
        </el-collapse>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>
<script setup lang="ts">
import { ref, computed, onMounted } from "vue";
import { useRoute } from "vue-router";
import { adminClient } from "../api/client";
import { ElTabs, ElTabPane, ElTimeline, ElTimelineItem, ElTag, ElCollapse, ElCollapseItem, ElPageHeader } from "element-plus";

const route = useRoute();
const id = route.params.id as string;
const loading = ref(false);
const bundle = ref<any>({ messages: [], traces: [], checkpoints: [] });

// 合并时间线：消息 + trace 按时间
const timeline = computed(() => {
  const items: any[] = [];
  (bundle.value.messages || []).forEach((m: any) => items.push({ id: "m" + m.createdAt, ts: m.createdAt, kind: "msg:" + m.role, title: m.content?.slice(0, 60), t: "primary" }));
  (bundle.value.traces || []).forEach((t: any) => items.push({ id: "t" + t.createdAt, ts: t.createdAt, kind: t.kind, title: `${t.name} · ${t.latencyMs}ms`, body: t.outputJson?.slice(0, 300), t: t.outputJson?.includes("error") ? "danger" : "success" }));
  return items.sort((a, b) => (a.ts > b.ts ? 1 : -1));
});
const tab = ref("timeline");

function fmt(s: string) { try { return JSON.stringify(JSON.parse(s), null, 2); } catch { return s; } }

async function load() {
  loading.value = true;
  try { bundle.value = await adminClient.getSessionReplay({ sessionId: BigInt(id) }); }
  finally { loading.value = false; }
}
onMounted(load);
</script>
