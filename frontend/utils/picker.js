function normalize(value) {
  return String(value || '').toLowerCase().replace(/\s+/g, '')
}

function toOption(item) {
  var name = item.fullName || item.name || ''
  var code = item.code || ''
  return {
    id: item.id,
    name: name,
    fullName: item.fullName || name,
    code: code,
    quotaCount: item.quotaCount || 0,
    searchText: normalize(name + ' ' + code)
  }
}

function mapOptions(items) {
  return (items || []).map(toOption)
}

function searchOptions(items, query) {
  var q = normalize(query)
  if (!q) return (items || []).slice()

  return (items || []).filter(function (item) {
    return normalize(item.name).indexOf(q) !== -1 ||
      normalize(item.fullName).indexOf(q) !== -1 ||
      normalize(item.code).indexOf(q) !== -1 ||
      normalize(item.searchText).indexOf(q) !== -1
  })
}

function findById(items, id) {
  var target = String(id)
  for (var i = 0; i < (items || []).length; i++) {
    if (String(items[i].id) === target) {
      return items[i]
    }
  }
  return null
}

module.exports = {
  mapOptions: mapOptions,
  searchOptions: searchOptions,
  findById: findById
}
