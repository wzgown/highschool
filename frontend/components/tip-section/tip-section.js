Component({
  data: {
    expanded: true
  },

  methods: {
    onToggle() {
      this.setData({ expanded: !this.data.expanded })
    }
  }
})
