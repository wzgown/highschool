var DISTRICT_ALIASES = {
  '黄浦区': 'huangpu hp',
  '徐汇区': 'xuhui xh',
  '长宁区': 'changning cn',
  '静安区': 'jingan ja',
  '普陀区': 'putuo pt',
  '虹口区': 'hongkou hk',
  '杨浦区': 'yangpu yp',
  '闵行区': 'minhang mh',
  '宝山区': 'baoshan bs',
  '嘉定区': 'jiading jd',
  '浦东新区': 'pudong pd pdxq',
  '金山区': 'jinshan js',
  '松江区': 'songjiang sj',
  '青浦区': 'qingpu qp',
  '奉贤区': 'fengxian fx',
  '崇明区': 'chongming cm'
}

function normalize(value) {
  return String(value || '').toLowerCase().replace(/\s+/g, '')
}

function isCityLevel(district) {
  if (!district) return false
  var name = String(district.name || '').replace(/\s+/g, '')
  var code = normalize(district.code)
  return name === '上海市' || name === '上海' || code === 'shanghai' || code === '310000'
}

function toDistrict(district) {
  var name = district.name || ''
  var code = district.code || ''
  var alias = DISTRICT_ALIASES[name] || ''
  return {
    id: district.id,
    name: name,
    code: code,
    searchText: normalize(name + ' ' + code + ' ' + alias)
  }
}

function filterDistricts(districts) {
  return (districts || []).filter(function (district) {
    return !isCityLevel(district)
  }).map(toDistrict)
}

function searchDistricts(districts, query) {
  var q = normalize(query)
  if (!q) return (districts || []).slice()

  return (districts || []).filter(function (district) {
    return normalize(district.name).indexOf(q) !== -1 ||
      normalize(district.code).indexOf(q) !== -1 ||
      normalize(district.searchText).indexOf(q) !== -1
  })
}

function findDistrictById(districts, id) {
  var target = String(id)
  for (var i = 0; i < (districts || []).length; i++) {
    if (String(districts[i].id) === target) {
      return districts[i]
    }
  }
  return null
}

module.exports = {
  filterDistricts: filterDistricts,
  searchDistricts: searchDistricts,
  findDistrictById: findDistrictById,
  isCityLevel: isCityLevel
}
