import request from './request'

export const api = {
  login: (username: string, password: string) => request.post('/webapi/auth/login', { username, password }),
  currentAdmin: () => request.get('/webapi/auth/current'),
  dashboard: () => request.get('/webapi/dashboard/summary'),

  users: (params: any) => request.post('/webapi/user/paging', params),
  userStatus: (id: number, status: number) => request.post(`/webapi/user/${id}/status?status=${status}`),
  blockDevice: (deviceUuid: string, reason?: string) => request.post('/webapi/user/device/block', { deviceUuid, reason }),

  postcards: (params: any) => request.post('/webapi/content/postcard/paging', params),
  comments: (params: any) => request.post('/webapi/content/comment/paging', params),
  approvePostcard: (id: number) => request.post(`/webapi/content/postcard/${id}/approve`),
  rejectPostcard: (id: number, reason: string) => request.post(`/webapi/content/postcard/${id}/reject`, { reason }),
  approveComment: (id: number) => request.post(`/webapi/content/comment/${id}/approve`),
  rejectComment: (id: number, reason: string) => request.post(`/webapi/content/comment/${id}/reject`, { reason }),

  reports: (params: any) => request.post('/webapi/report/paging', params),
  handleReport: (id: number, handleNote?: string) => request.post(`/webapi/report/${id}/handle`, { handleNote, result: 1 }),
  rejectReport: (id: number, handleNote?: string) => request.post(`/webapi/report/${id}/reject`, { handleNote, result: 2 }),

  configs: (body?: any) => request.post('/webapi/config/paging', body ?? { page: { page: 1, size: 200 } }),
  saveConfig: (body: any) => request.post('/webapi/config/save', body),
  deleteConfig: (id: number) => request.post(`/webapi/config/${id}/delete`),

  countries: (params: any) => request.post('/webapi/country/paging', params),
  saveCountry: (body: any) => request.post('/webapi/country/save', body),
  deleteCountry: (id: number) => request.post(`/webapi/country/${id}/delete`),

  sensitiveWords: (params: any) => request.post('/webapi/sensitive-word/paging', params),
  saveSensitiveWord: (body: any) => request.post('/webapi/sensitive-word/save', body),
  deleteSensitiveWord: (id: number) => request.post(`/webapi/sensitive-word/${id}/delete`),

  versions: () => request.post('/webapi/version/paging', {}),
  saveVersion: (body: any) => request.post('/webapi/version/save', body),
  deleteVersion: (id: number) => request.post(`/webapi/version/${id}/delete`),

  announcements: (params: any) => request.post('/webapi/announcement/paging', params),
  saveAnnouncement: (body: any) => request.post('/webapi/announcement/save', body),
  deleteAnnouncement: (id: number) => request.post(`/webapi/announcement/${id}/delete`),

  actionLogs: (params: any) => request.post('/webapi/log/action/paging', params),
  loginLogs: (params: any) => request.post('/webapi/log/login/paging', params),
}
