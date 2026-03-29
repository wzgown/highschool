Component({
  properties: {
    reach: { type: Number, value: 0 },
    target: { type: Number, value: 0 },
    safety: { type: Number, value: 0 }
  },

  data: {
    total: 0,
    reachPercent: 0,
    targetPercent: 0,
    safetyPercent: 0
  },

  observers: {
    'reach, target, safety': function (reach, target, safety) {
      const total = reach + target + safety
      this.setData({
        total,
        reachPercent: total ? Math.round((reach / total) * 100) : 0,
        targetPercent: total ? Math.round((target / total) * 100) : 0,
        safetyPercent: total ? Math.round((safety / total) * 100) : 0
      })
    }
  }
})
