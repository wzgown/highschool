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
  border-radius: 8rpx;
  font-weight: 500;
  transition: all 0.2s ease;
  border: 1px solid transparent;
  cursor: pointer;
  box-sizing: border-box;

  &--large {
    height: 88rpx;
    padding: 0 48rpx;
    font-size: 32rpx;
  }

  &--medium {
    height: 72rpx;
    padding: 0 32rpx;
    font-size: 28rpx;
  }

  &--small {
    height: 60rpx;
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
    }
  }

  &--success {
    background-color: #67c23a;
    color: #fff;

    &:active:not(.app-button--disabled) {
      background-color: #529b2e;
    }
  }

  &--warning {
    background-color: #e6a23c;
    color: #fff;

    &:active:not(.app-button--disabled) {
      background-color: #b88230;
    }
  }

  &--danger {
    background-color: #f56c6c;
    color: #fff;

    &:active:not(.app-button--disabled) {
      background-color: #c45656;
    }
  }

  &--info {
    background-color: #909399;
    color: #fff;

    &:active:not(.app-button--disabled) {
      background-color: #73767a;
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
