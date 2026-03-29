Component({
  properties: {
    batch: { type: String, value: '' },
    batchName: { type: String, value: '' },
    batchType: { type: String, value: 'primary' },
    schoolName: { type: String, value: '' },
    schoolCode: { type: String, value: '' },
    probability: { type: Number, value: 0 },
    riskLevel: { type: String, value: '' },
    riskText: { type: String, value: '' },
    riskType: { type: String, value: 'info' },
    scoreDiff: { type: Number, optional: true }
  },

  methods: {
    getBatchClass() {
      return 'tag-' + this.data.batchType
    }
  }
})
