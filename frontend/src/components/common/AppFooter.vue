<template>
  <footer class="app-footer">
    <div class="footer-content">
      <p class="copyright">
        © 2025 上海中考招生模拟系统 | 仅供参考，请以官方发布为准
      </p>
      <p class="disclaimer">
        数据来源：上海招考热线
      </p>
    </div>
  </footer>
</template>

<style lang="scss" scoped>
.app-footer {
  background: #fff;
  border-top: 1px solid #e4e7ed;
  padding: 20px;
  text-align: center;
}

.footer-content {
  max-width: 1200px;
  margin: 0 auto;
}

.copyright {
  color: #606266;
  font-size: 14px;
  margin-bottom: 8px;
}

.disclaimer {
  color: #909399;
  font-size: 12px;
}

@media (max-width: 768px) {
  .app-footer {
    padding: 15px;
  }
  
  .copyright {
    font-size: 12px;
  }
  
  .disclaimer {
    font-size: 11px;
  }
}
</style>
