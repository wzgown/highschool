<template>
  <div>
    <el-alert v-if="err" :title="err" type="error" show-icon :closable="false" style="margin-bottom:12px" />
    <el-table :data="rows" v-loading="loading" @row-click="go" style="cursor:pointer">
      <el-table-column prop="sessionId" label="会话" width="80" />
      <el-table-column prop="deviceId" label="设备" width="120" />
      <el-table-column prop="intent" label="意图" width="140" />
      <el-table-column prop="status" label="状态" width="110" />
      <el-table-column prop="messageCount" label="消息数" width="90" />
      <el-table-column prop="totalTokens" label="Token" width="110" />
      <el-table-column prop="createdAt" label="创建时间" />
    </el-table>
    <el-pagination style="margin-top:12px" :current-page="page" :page-size="20" :total="total" layout="prev, pager, next" @current-change="onPage" />
  </div>
</template>
<script setup lang="ts">
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import { adminClient } from "../api/client";
import { ElTable, ElTableColumn, ElPagination, ElAlert } from "element-plus";

const rows = ref<any[]>([]);
const total = ref(0);
const page = ref(1);
const loading = ref(false);
const err = ref("");
const router = useRouter();

async function load() {
  loading.value = true;
  err.value = "";
  try {
    const res = await adminClient.listAgentSessions({ page: page.value, pageSize: 20 });
    rows.value = res.items as any[];
    total.value = res.total;
  } catch (e) {
    err.value = "加载失败：" + (e instanceof Error ? e.message : String(e));
  } finally { loading.value = false; }
}
function onPage(p: number) { page.value = p; load(); }
function go(row: any) { router.push("/replay/" + row.sessionId); }
onMounted(load);
</script>
