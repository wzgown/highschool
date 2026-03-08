<template>
  <view class="app-input-wrapper">
    <view
      class="app-input"
      :class="[
        `app-input--${size}`,
        { 'app-input--disabled': disabled },
        { 'app-input--error': error },
        { 'app-input--focused': focused }
      ]"
    >
      <view v-if="$slots.prefix || prefixIcon" class="app-input__prefix">
        <slot name="prefix">
          <uni-icons :type="prefixIcon" :size="iconSize" />
        </slot>
      </view>

      <input
        class="app-input__inner"
        :type="type"
        :value="modelValue"
        :placeholder="placeholder"
        :placeholder-style="placeholderStyle"
        :disabled="disabled"
        :maxlength="maxlength"
        :focus="focus"
        :confirm-type="confirmType"
        @input="handleInput as any"
        @focus="handleFocus"
        @blur="handleBlur"
        @confirm="handleConfirm as any"
      />

      <view v-if="$slots.suffix || suffixIcon || clearable" class="app-input__suffix">
        <slot name="suffix">
          <view
            v-if="clearable && modelValue"
            class="clear-btn"
            @click.stop="handleClear"
          >
            <uni-icons type="clear" :size="iconSize" color="#c0c4cc" />
          </view>
          <uni-icons v-else-if="suffixIcon" :type="suffixIcon" :size="iconSize" />
        </slot>
      </view>
    </view>

    <view v-if="error || hint" class="app-input__message">
      <text :class="['message-text', { 'message-text--error': error }]">
        {{ error || hint }}
      </text>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

type InputType = 'text' | 'number' | 'idcard' | 'digit' | 'password'
type InputSize = 'large' | 'medium' | 'small'
type ConfirmType = 'send' | 'search' | 'next' | 'go' | 'done'

interface Props {
  modelValue: string | number
  type?: InputType
  size?: InputSize
  placeholder?: string
  placeholderStyle?: string
  disabled?: boolean
  maxlength?: number
  clearable?: boolean
  prefixIcon?: string
  suffixIcon?: string
  focus?: boolean
  error?: string
  hint?: string
  confirmType?: ConfirmType
}

const props = withDefaults(defineProps<Props>(), {
  type: 'text',
  size: 'medium',
  placeholder: '请输入',
  placeholderStyle: 'color: #c0c4cc',
  disabled: false,
  maxlength: 140,
  clearable: false,
  prefixIcon: '',
  suffixIcon: '',
  focus: false,
  error: '',
  hint: '',
  confirmType: 'done'
})

const emit = defineEmits<{
  (e: 'update:modelValue', value: string): void
  (e: 'input', value: string): void
  (e: 'focus', event: FocusEvent): void
  (e: 'blur', event: FocusEvent): void
  (e: 'confirm', value: string): void
  (e: 'clear'): void
}>()

const focused = ref(false)

const iconSize = computed(() => {
  const sizes: Record<InputSize, number> = {
    large: 18,
    medium: 16,
    small: 14
  }
  return sizes[props.size]
})

function handleInput(event: { detail: { value: string } }) {
  const value = event.detail.value
  emit('update:modelValue', value)
  emit('input', value)
}

function handleFocus(event: FocusEvent) {
  focused.value = true
  emit('focus', event)
}

function handleBlur(event: FocusEvent) {
  focused.value = false
  emit('blur', event)
}

function handleConfirm(event: { detail: { value: string } }) {
  emit('confirm', event.detail.value)
}

function handleClear() {
  emit('update:modelValue', '')
  emit('clear')
}
</script>

<style lang="scss" scoped>
.app-input-wrapper {
  width: 100%;
}

.app-input {
  display: flex;
  align-items: center;
  background-color: #fff;
  border: 1px solid #dcdfe6;
  border-radius: 8rpx;
  transition: all 0.2s ease;
  box-sizing: border-box;

  &--large {
    height: 88rpx;
    padding: 0 24rpx;
    font-size: 32rpx;
  }

  &--medium {
    height: 72rpx;
    padding: 0 20rpx;
    font-size: 28rpx;
  }

  &--small {
    height: 60rpx;
    padding: 0 16rpx;
    font-size: 26rpx;
  }

  &--focused {
    border-color: #409eff;
    box-shadow: 0 0 0 2px rgba(64, 158, 255, 0.2);
  }

  &--disabled {
    background-color: #f5f7fa;
    cursor: not-allowed;

    .app-input__inner {
      color: #c0c4cc;
    }
  }

  &--error {
    border-color: #f56c6c;
  }
}

.app-input__prefix,
.app-input__suffix {
  display: flex;
  align-items: center;
  flex-shrink: 0;
}

.app-input__prefix {
  margin-right: 12rpx;
}

.app-input__suffix {
  margin-left: 12rpx;
}

.app-input__inner {
  flex: 1;
  height: 100%;
  color: #606266;
  background: transparent;
  border: none;
  outline: none;
}

.clear-btn {
  cursor: pointer;
  padding: 4rpx;

  &:active {
    opacity: 0.7;
  }
}

.app-input__message {
  margin-top: 8rpx;
  padding-left: 4rpx;
}

.message-text {
  font-size: 24rpx;
  color: #909399;

  &--error {
    color: #f56c6c;
  }
}
</style>
