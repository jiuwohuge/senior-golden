import axios, { AxiosError } from 'axios'
import { message } from 'antd'
import type { ApiResponse } from '../types/api'

const request = axios.create({
  baseURL: '/webapi',
  timeout: 30000,
})

request.interceptors.request.use((config) => {
  const token = localStorage.getItem('admin_token')
  if (token) {
    config.headers['token'] = token
  }
  return config
})

request.interceptors.response.use(
  (response) => response.data,
  (error: AxiosError<ApiResponse>) => {
    const res = error.response?.data
    if (res?.code === 8501) {
      message.error('登录已过期，请重新登录')
      localStorage.removeItem('admin_token')
      window.location.href = '/login'
    } else {
      message.error(res?.message || '请求失败')
    }
    return Promise.reject(error)
  }
)

export default request