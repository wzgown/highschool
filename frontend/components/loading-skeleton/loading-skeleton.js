Component({
  options: {
    addGlobalClass: true
  },

  properties: {
    rows: { type: Number, value: 3 },
    loading: { type: Boolean, value: true },
    title: { type: String, value: '' },
    hint: { type: String, value: '' }
  },

  data: {
    rowItems: [0, 1, 2]
  },

  observers: {
    rows: function (rows) {
      var count = Math.max(1, Number(rows) || 3)
      var items = []
      for (var i = 0; i < count; i++) {
        items.push(i)
      }
      this.setData({ rowItems: items })
    }
  }
})
