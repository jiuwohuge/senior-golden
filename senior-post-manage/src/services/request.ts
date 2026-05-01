import axios from 'axios'

const request = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:20011/api',
  timeout: 15000,
})

request.interceptors.request.use((config) => {
  const token = localStorage.getItem('admin_token')
  if (token) {
    config.headers.Token = token
  }
  return config
})

request.interceptors.response.use((resp) => {
  const data = resp.data
  if (data && typeof data === 'object' && 'success' in data) {
    if (!data.success) {
      if (data.code >= 8500 && data.code <= 8599) {
        localStorage.removeItem('admin_token')
        if (location.pathname !== '/login') location.href = '/login'
      }
      return Promise.reject(new Error(data.message || '请求失败'))
    }
    return data.data
  }
  return data
})

export default request
