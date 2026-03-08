<script setup lang="ts">
import { onLaunch, onShow, onHide } from "@dcloudio/uni-app";

onLaunch(() => {
  console.log("App Launch");
});

onShow(() => {
  console.log("App Show");
});

onHide(() => {
  console.log("App Hide");
});
</script>

<style lang="scss">
// 引入响应式样式
@use './styles/responsive.scss';
// 引入桌面端样式
@use './styles/desktop.scss';

/* ========================================
   全局样式
   ======================================== */

// 基础重置
page {
  background-color: #f5f7fa;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  font-size: 28rpx;
  line-height: 1.5;
  color: #303133;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

// 移动端优化
view, text {
  box-sizing: border-box;
}

// 链接样式
navigator, a {
  text-decoration: none;
  color: #409eff;
}

// 图片自适应
image {
  max-width: 100%;
  height: auto;
}

// 滚动容器
scroll-view {
  -webkit-overflow-scrolling: touch;
}

/* ========================================
   移动端表单全局优化
   ======================================== */

// 输入框优化
input, textarea {
  font-size: 32rpx; // 最小 16px 防止 iOS 自动缩放
}

input::placeholder, textarea::placeholder {
  color: #c0c4cc;
}

// 按钮基础样式
button {
  font-size: 32rpx;
  border-radius: 12rpx;

  &::after {
    border: none;
  }
}

/* ========================================
   移动端触摸反馈
   ======================================== */

// 可点击元素的触摸反馈
.clickable {
  transition: transform 0.15s ease-out, opacity 0.15s ease-out;

  &:active {
    transform: scale(0.98);
    opacity: 0.9;
  }
}

// 卡片触摸反馈
.card-press {
  transition: transform 0.15s ease-out, box-shadow 0.15s ease-out;

  &:active {
    transform: scale(0.99);
    box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.04);
  }
}

/* ========================================
   H5 端全局优化
   ======================================== */

/* #ifdef H5 */

// H5 端页面容器
body, html {
  margin: 0;
  padding: 0;
  min-height: 100vh;
}

// H5 端最大宽度限制
uni-page-body {
  max-width: 750px;
  margin: 0 auto;
}

// H5 端触摸优化
* {
  -webkit-tap-highlight-color: transparent;
}

// H5 端文本选择
.allow-select {
  -webkit-user-select: auto;
  user-select: auto;
}

// H5 响应式字体
@media screen and (max-width: 375px) {
  page {
    font-size: 26rpx;
  }
}

@media screen and (min-width: 414px) and (max-width: 767px) {
  page {
    font-size: 30rpx;
  }
}

@media screen and (min-width: 768px) {
  page {
    font-size: 28rpx;
  }

  // 平板/桌面端增加内边距
  .page-content {
    padding: 32rpx 48rpx;
  }
}

// 桌面端导航栏适配
@media screen and (min-width: 1024px) {
  uni-page-body {
    max-width: 960px;
  }

  // 桌面端页面内边距
  .page-content {
    padding: 32rpx 48rpx;
  }
}

// 大桌面端 (>= 1440px)
@media screen and (min-width: 1440px) {
  uni-page-body {
    max-width: 1200px;
  }

  // 大桌面端更大的内边距
  .page-content {
    padding: 48rpx 64rpx;
  }
}

// 超大桌面端 (>= 1920px)
@media screen and (min-width: 1920px) {
  uni-page-body {
    max-width: 1320px;
  }
}

/* #endif */

/* ========================================
   小程序全局优化
   ======================================== */

/* #ifdef MP-WEIXIN */

// 小程序页面容器
page {
  min-height: 100vh;
  background-color: #f5f7fa;
}

// 小程序安全区域
.safe-area-inset-bottom {
  padding-bottom: constant(safe-area-inset-bottom);
  padding-bottom: env(safe-area-inset-bottom);
}

/* #endif */

/* ========================================
   工具类
   ======================================== */

// 文字对齐
.text-center { text-align: center; }
.text-left { text-align: left; }
.text-right { text-align: right; }

// Flex 布局
.flex { display: flex; }
.flex-col { flex-direction: column; }
.flex-wrap { flex-wrap: wrap; }
.items-center { align-items: center; }
.justify-center { justify-content: center; }
.justify-between { justify-content: space-between; }
.flex-1 { flex: 1; }

// 间距
.gap-xs { gap: 8rpx; }
.gap-sm { gap: 16rpx; }
.gap-md { gap: 24rpx; }
.gap-lg { gap: 32rpx; }

// 内边距
.p-xs { padding: 16rpx; }
.p-sm { padding: 24rpx; }
.p-md { padding: 32rpx; }
.p-lg { padding: 48rpx; }

// 外边距
.m-xs { margin: 16rpx; }
.m-sm { margin: 24rpx; }
.m-md { margin: 32rpx; }
.m-lg { margin: 48rpx; }
.mb-sm { margin-bottom: 24rpx; }
.mb-md { margin-bottom: 32rpx; }

// 宽度
.w-full { width: 100%; }

// 圆角
.rounded-sm { border-radius: 8rpx; }
.rounded-md { border-radius: 12rpx; }
.rounded-lg { border-radius: 16rpx; }
.rounded-full { border-radius: 9999rpx; }

// 阴影
.shadow-sm { box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.06); }
.shadow-md { box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.08); }
.shadow-lg { box-shadow: 0 8rpx 24rpx rgba(0, 0, 0, 0.1); }
</style>
