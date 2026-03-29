Component({
  properties: {
    label: { type: String, value: '' },
    value: { type: Number, value: 0 },
    min: { type: Number, value: 0 },
    max: { type: Number, value: 999 },
    placeholder: { type: String, value: '请输入分数' },
    required: { type: Boolean, value: false },
    disabled: { type: Boolean, value: false },
    tip: { type: String, value: '' }
  },

  methods: {
    onInput(e) {
      const val = e.detail.value
      this.triggerEvent('change', { value: Number(val) || 0 })
    }
  }
})
