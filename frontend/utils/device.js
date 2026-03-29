/**
 * 设备 ID 管理
 * 替代 FingerprintJS，使用 UUID 存储到本地
 */

function generateUUID() {
  const chars = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  return chars.replace(/[xy]/g, (c) => {
    const r = (Math.random() * 16) | 0
    const v = c === 'x' ? r : (r & 0x3) | 0x8
    return v.toString(16)
  })
}

function getDeviceId() {
  let deviceId = wx.getStorageSync('device_id')
  if (!deviceId) {
    deviceId = generateUUID()
    wx.setStorageSync('device_id', deviceId)
  }
  return deviceId
}

function resetDeviceId() {
  wx.removeStorageSync('device_id')
}

module.exports = { getDeviceId, resetDeviceId }
