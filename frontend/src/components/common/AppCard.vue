<template>
  <view
    class="app-card"
    :class="[
      `app-card--${shadow}`,
      { 'app-card--hoverable': hoverable }
    ]"
    @click="handleClick"
  >
    <view v-if="$slots.header || title" class="app-card__header">
      <slot name="header">
        <view class="app-card__header-content">
          <text class="app-card__title">{{ title }}</text>
          <text v-if="subtitle" class="app-card__subtitle">{{ subtitle }}</text>
        </view>
        <view v-if="$slots.extra" class="app-card__extra">
          <slot name="extra" />
        </view>
      </slot>
    </view>

    <view class="app-card__body" :style="bodyStyle">
      <slot />
    </view>

    <view v-if="$slots.footer" class="app-card__footer">
      <slot name="footer" />
    </view>
  </view>
</template>

<script setup lang="ts">
import { computed } from 'vue'

type ShadowType = 'always' | 'hover' | 'never'

interface Props {
  title?: string
  subtitle?: string
  shadow?: ShadowType
  hoverable?: boolean
  padding?: string
}

const props = withDefaults(defineProps<Props>(), {
  title: '',
  subtitle: '',
  shadow: 'always',
  hoverable: false,
  padding: '24rpx'
})

const emit = defineEmits<{
  (e: 'click', event: MouseEvent): void
}>()

const bodyStyle = computed(() => ({
  padding: props.padding
}))

function handleClick(event: MouseEvent) {
  emit('click', event)
}
</script>

<style lang="scss" scoped>
.app-card {
  background-color: #fff;
  border-radius: 16rpx;
  overflow: hidden;
  transition: all 0.3s ease;

  &--always {
    box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.08);
  }

  &--hover {
    box-shadow: none;
  }

  &--never {
    box-shadow: none;
  }

  &--hoverable {
    cursor: pointer;

    &:active {
      transform: scale(0.98);
      box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.12);
    }
  }
}

.app-card__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 24rpx 24rpx 16rpx;
  border-bottom: 1px solid #ebeef5;
}

.app-card__header-content {
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}

.app-card__title {
  font-size: 32rpx;
  font-weight: 600;
  color: #303133;
  line-height: 1.4;
}

.app-card__subtitle {
  font-size: 24rpx;
  color: #909399;
  line-height: 1.4;
}

.app-card__extra {
  flex-shrink: 0;
}

.app-card__body {
  font-size: 28rpx;
  color: #606266;
  line-height: 1.6;
}

.app-card__footer {
  padding: 16rpx 24rpx 24rpx;
  border-top: 1px solid #ebeef5;
}
</style>
