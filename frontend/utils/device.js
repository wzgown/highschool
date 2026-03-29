/**
 * 设备 ID 管理
 * 替代 FingerprintJS，使用 UUID 存储到本地
 */

function generateUUID() {
  var chars = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  return chars.replace(/[xy]/g, function (c) {
    var r = (Math.random() * 16) | 0
    var v = c === 'x' ? r : (r & 0x3) | 0x8
    return v.toString(16)
  })
}

function getDeviceId() {
  var deviceId = wx.getStorageSync('device_id')
  if (!deviceId) {
    deviceId = generateUUID()
    wx.setStorageSync('device_id', deviceId)
  }
  return deviceId
}

function resetDeviceId() {
  wx.removeStorageSync('device_id')
}

module.exports = { getDeviceId: getDeviceId, resetDeviceId: resetDeviceId }
