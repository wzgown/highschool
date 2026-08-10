<template>
  <div style="max-width:320px;margin:80px auto">
    <h3>管理后台登录</h3>
    <el-input v-model="password" type="password" placeholder="密码" @keyup.enter="submit" />
    <el-button type="primary" style="margin-top:12px;width:100%" :loading="loading" @click="submit">登录</el-button>
    <p v-if="err" style="color:red;margin-top:8px">{{ err }}</p>
  </div>
</template>
<script setup lang="ts">
import { ref } from "vue";
import { useRouter } from "vue-router";
import { useAuthStore } from "../stores/auth";
import { ElInput, ElButton } from "element-plus";

const password = ref("");
const loading = ref(false);
const err = ref("");
const router = useRouter();
const auth = useAuthStore();

async function submit() {
  loading.value = true; err.value = "";
  try { await auth.login(password.value); router.push("/sessions"); }
  catch (e: any) { err.value = e.message ?? "登录失败"; }
  finally { loading.value = false; }
}
</script>
