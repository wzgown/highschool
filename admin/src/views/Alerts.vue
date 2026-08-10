<template>
  <div>
    <div style="display:flex;align-items:center;gap:12px;margin-bottom:12px">
      <el-select v-model="statusFilter" placeholder="状态" style="width:160px" @change="onFilterChange">
        <el-option label="全部" value="" />
        <el-option label="未确认" value="open" />
        <el-option label="已确认" value="acked" />
      </el-select>
      <el-button type="primary" :loading="loading" @click="load">刷新</el-button>
    </div>

    <el-alert v-if="err" :title="err" type="error" show-icon :closable="false" style="margin-bottom:12px" />

    <el-table :data="rows" v-loading="loading" border>
      <el-table-column type="expand">
        <template #default="{ row }">
          <pre style="margin:8px;padding:8px;background:#f5f7fa;border-radius:4px;white-space:pre-wrap;word-break:break-word;font-size:12px;max-height:400px;overflow:auto">{{ prettyDetail(row.detailJson) }}</pre>
        </template>
      </el-table-column>
      <el-table-column label="告警ID" width="120">
        <template #default="{ row }">{{ String(row.id) }}</template>
      </el-table-column>
      <el-table-column prop="createdAt" label="时间" width="180" />
      <el-table-column prop="kind" label="类型" width="140" />
      <el-table-column label="级别" width="100">
        <template #default="{ row }">
          <el-tag :type="severityTagType(row.severity)" size="small">{{ row.severity || "-" }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="title" label="标题" min-width="200" show-overflow-tooltip />
      <el-table-column label="状态" width="100">
        <template #default="{ row }">
          <el-tag :type="statusTagType(row.status)" size="small">{{ row.status }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="100" fixed="right">
        <template #default="{ row }">
          <el-button
            v-if="row.status === 'open'"
            type="primary"
            size="small"
            :loading="ackingId === String(row.id)"
            @click="onAck(row as AdminAlert)"
          >确认</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination
      style="margin-top:12px"
      :current-page="page"
      :page-size="pageSize"
      :total="total"
      :page-sizes="[20, 50, 100]"
      layout="total, sizes, prev, pager, next"
      @current-change="onPage"
      @size-change="onSize"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { adminClient } from "../api/client";
import type { AdminAlert } from "../gen/highschool/v1/admin_service_pb";
import {
  ElTable, ElTableColumn, ElPagination, ElAlert, ElButton,
  ElSelect, ElOption, ElTag, ElMessage,
} from "element-plus";

type TagType = "primary" | "success" | "info" | "warning" | "danger";

const rows = ref<AdminAlert[]>([]);
const total = ref(0);
const page = ref(1);
const pageSize = ref(20);
const statusFilter = ref("");
const loading = ref(false);
const err = ref("");
const ackingId = ref("");

async function load() {
  loading.value = true;
  err.value = "";
  try {
    const res = await adminClient.listAlerts({
      status: statusFilter.value,
      page: page.value,
      pageSize: pageSize.value,
    });
    rows.value = res.items;
    total.value = res.total;
  } catch (e) {
    err.value = "加载失败：" + (e instanceof Error ? e.message : String(e));
  } finally {
    loading.value = false;
  }
}

function onPage(p: number) { page.value = p; load(); }
function onSize(s: number) { pageSize.value = s; page.value = 1; load(); }
function onFilterChange() { page.value = 1; load(); }

async function onAck(row: AdminAlert) {
  ackingId.value = String(row.id);
  try {
    await adminClient.acknowledgeAlert({ id: row.id });
    ElMessage.success("已确认");
    await load();
  } catch (e) {
    ElMessage.error("确认失败：" + (e instanceof Error ? e.message : String(e)));
  } finally {
    ackingId.value = "";
  }
}

function severityTagType(sev: string): TagType {
  if (sev === "critical") return "danger";
  if (sev === "warn") return "warning";
  return "info";
}

function statusTagType(status: string): TagType {
  return status === "open" ? "danger" : "info";
}

function prettyDetail(raw: string): string {
  if (!raw) return "(无 detail)";
  try {
    return JSON.stringify(JSON.parse(raw), null, 2);
  } catch {
    return raw;
  }
}

onMounted(load);
</script>
