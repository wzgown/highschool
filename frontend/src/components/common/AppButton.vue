<template>
  <button
    class="app-button"
    :class="[
      `app-button--${type}`,
      `app-button--${size}`,
      { 'app-button--disabled': disabled },
      { 'app-button--loading': loading },
      { 'app-button--block': block }
    ]"
    :disabled="disabled || loading"
    @click="handleClick"
  >
    <uni-icons
      v-if="loading"
      type="spinner-cycle"
      size="16"
      class="loading-icon"
    />
    <uni-icons
      v-else-if="icon"
      :type="icon"
      :size="iconSize"
      class="button-icon"
    />
    <text class="button-text" v-if="$slots.default || text">
      <slot>{{ text }}</slot>
    </text>
  </button>
</template>

<script setup lang="ts">
import { computed } from 'vue'

type ButtonType = 'primary' | 'success' | 'warning' | 'danger' | 'info' | 'default'
type ButtonSize = 'large' | 'medium' | 'small' | 'mini'

interface Props {
  type?: ButtonType
  size?: ButtonSize
  text?: string
  icon?: string
  disabled?: boolean
  loading?: boolean
  block?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  type: 'default',
  size: 'medium',
  text: '',
  icon: '',
  disabled: false,
  loading: false,
  block: false
})

const emit = defineEmits<{
  (e: 'click', event: MouseEvent): void
}>()

const iconSize = computed(() => {
  const sizes: Record<ButtonSize, number> = {
    large: 18,
    medium: 16,
    small: 14,
    mini: 12
  }
  return sizes[props.size]
})

function handleClick(event: MouseEvent) {
  if (!props.disabled && !props.loading) {
    emit('click', event)
  }
}
</script>

<style lang="scss" scoped>
.app-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8rpx;
  border-radius: 12rpx;
  font-weight: 500;
  transition: all 0.2s ease;
  border: 1px solid transparent;
  cursor: pointer;
  box-sizing: border-box;
  // 移动端触摸优化
  -webkit-tap-highlight-color: transparent;
  user-select: none;

  // 移动端最小触摸目标 (WCAG 2.1 标准)
  &--large {
    height: 96rpx;
    min-height: 88rpx; // 最小触摸目标
    padding: 0 48rpx;
    font-size: 32rpx;
    border-radius: 16rpx;
  }

  &--medium {
    height: 80rpx;
    min-height: 80rpx;
    padding: 0 32rpx;
    font-size: 28rpx;
  }

  &--small {
    height: 64rpx;
    padding: 0 24rpx;
    font-size: 26rpx;
  }

  &--mini {
    height: 48rpx;
    padding: 0 16rpx;
    font-size: 24rpx;
  }

  &--primary {
    background-color: #409eff;
    color: #fff;

    &:active:not(.app-button--disabled) {
      background-color: #337ecc;
      transform: scale(0.98);
    }
  }

  &--success {
    background-color: #67c23a;
    color: #fff;

    &:active:not(.app-button--disabled) {
      background-color: #529b2e;
      transform: scale(0.98);
    }
  }

  &--warning {
    background-color: #e6a23c;
    color: #fff;

    &:active:not(.app-button--disabled) {
      background-color: #b88230;
      transform: scale(0.98);
    }
  }

  &--danger {
    background-color: #f56c6c;
    color: #fff;

    &:active:not(.app-button--disabled) {
      background-color: #c45656;
      transform: scale(0.98);
    }
  }

  &--info {
    background-color: #909399;
    color: #fff;

    &:active:not(.app-button--disabled) {
      background-color: #73767a;
      transform: scale(0.98);
    }
  }

  &--default {
    background-color: #fff;
    color: #606266;
    border-color: #dcdfe6;

    &:active:not(.app-button--disabled) {
      color: #409eff;
      border-color: #c6e2ff;
      background-color: #ecf5ff;
      transform: scale(0.98);
    }
  }

  &--disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }

  &--loading {
    cursor: wait;
  }

  &--block {
    display: flex;
    width: 100%;
  }
}

/* #ifdef H5 */
// H5 桌面端 hover 效果
@media (hover: hover) and (pointer: fine) {
  .app-button {
    &--primary:hover:not(.app-button--disabled) {
      background-color: #66b1ff;
    }

    &--success:hover:not(.app-button--disabled) {
      background-color: #85ce61;
    }

    &--warning:hover:not(.app-button--disabled) {
      background-color: #ebb563;
    }

    &--danger:hover:not(.app-button--disabled) {
      background-color: #f78989;
    }

    &--info:hover:not(.app-button--disabled) {
      background-color: #a6a9ad;
    }

    &--default:hover:not(.app-button--disabled) {
      color: #409eff;
      border-color: #c6e2ff;
      background-color: #ecf5ff;
    }
  }
}
/* #endif */

.loading-icon {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

.button-text {
  line-height: 1;
}
</style>
