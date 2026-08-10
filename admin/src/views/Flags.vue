<template>
  <div>
    <div style="display:flex;align-items:center;gap:12px;margin-bottom:8px">
      <el-button type="primary" :loading="loading" @click="load">刷新</el-button>
      <span style="color:#909399;font-size:12px">
        修改后立即生效（后端缓存已刷新）；如改 feature.review_versions，按审核需要设置。
      </span>
    </div>

    <el-alert v-if="err" :title="err" type="error" show-icon :closable="false" style="margin-bottom:12px" />

    <el-table :data="rows" v-loading="loading" border>
      <el-table-column prop="key" label="key" min-width="220" show-overflow-tooltip />
      <el-table-column label="当前值" min-width="220">
        <template #default="{ row }">
          <span style="word-break:break-all">{{ row.value || "(空)" }}</span>
        </template>
      </el-table-column>
      <el-table-column prop="description" label="说明" min-width="240" show-overflow-tooltip />
      <el-table-column label="操作" width="120" fixed="right">
        <template #default="{ row }">
          <el-button type="primary" size="small" @click="onEdit(row as AppConfigFlag)">编辑</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="dialogVisible" :title="`编辑 ${editing?.key ?? ''}`" width="520px">
      <el-input v-model="draftValue" :rows="3" type="textarea" autofocus />
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="onSave">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { adminClient } from "../api/client";
import type { AppConfigFlag } from "../gen/highschool/v1/admin_service_pb";
import {
  ElTable, ElTableColumn, ElAlert, ElButton, ElDialog, ElInput, ElMessage,
} from "element-plus";

const rows = ref<AppConfigFlag[]>([]);
const loading = ref(false);
const err = ref("");

const dialogVisible = ref(false);
const editing = ref<AppConfigFlag | null>(null);
const draftValue = ref("");
const saving = ref(false);

async function load() {
  loading.value = true;
  err.value = "";
  try {
    const res = await adminClient.getAppConfig({});
    rows.value = res.items;
  } catch (e) {
    err.value = "加载失败：" + (e instanceof Error ? e.message : String(e));
  } finally {
    loading.value = false;
  }
}

function onEdit(row: AppConfigFlag) {
  editing.value = row;
  draftValue.value = row.value;
  dialogVisible.value = true;
}

async function onSave() {
  if (!editing.value) return;
  saving.value = true;
  try {
    await adminClient.setAppConfig({ key: editing.value.key, value: draftValue.value });
    ElMessage.success("已保存，已热刷生效");
    dialogVisible.value = false;
    await load();
  } catch (e) {
    ElMessage.error("保存失败：" + (e instanceof Error ? e.message : String(e)));
  } finally {
    saving.value = false;
  }
}

onMounted(load);
</script>
