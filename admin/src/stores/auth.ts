import { defineStore } from "pinia";
import { ref } from "vue";
import { login as doLogin } from "../api/client";

export const useAuthStore = defineStore("auth", () => {
  const loggedIn = ref(false);
  async function login(password: string) {
    await doLogin(password);
    loggedIn.value = true;
  }
  function logout() { loggedIn.value = false; }
  return { loggedIn, login, logout };
});
