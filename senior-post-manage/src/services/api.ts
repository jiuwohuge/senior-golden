import request from './request'
import type { ApiResponse, PageData } from '../types/api'
import type {
  User, Postcard, PostcardComment, Report, SysConfig, SensitiveWord,
  Announcement, AppVersion, LoginLog, ActionLog, DashboardStats, AdminUser
} from '../types/models'

export const authApi = {
  login: (params: { username: string; password: string }) =>
    request.post<ApiResponse<{ token: string; admin: AdminUser }>>('/webapi/auth/login', params),
  logout: () => request.post<ApiResponse<void>>('/webapi/auth/logout'),
  current: () => request.get<ApiResponse<AdminUser>>('/webapi/auth/current'),
}

export const dashboardApi = {
  stats: () => request.get<ApiResponse<DashboardStats>>('/webapi/dashboard/stats'),
}

export const userApi = {
  list: (params: { page?: number; size?: number; email?: string; nickname?: string; status?: number }) =>
    request.post<ApiResponse<PageData<User>>>('/webapi/user/list', params),
  ban: (id: number) => request.post<ApiResponse<void>>(`/webapi/user/${id}/ban`),
  unban: (id: number) => request.post<ApiResponse<void>>(`/webapi/user/${id}/unban`),
  blockDevice: (deviceUuid: string) => request.post<ApiResponse<void>>('/webapi/device/block', { deviceUuid }),
}

export const postcardApi = {
  list: (params: { page?: number; size?: number; reviewStatus?: number }) =>
    request.post<ApiResponse<PageData<Postcard>>>('/webapi/postcard/list', params),
  approve: (id: number) => request.post<ApiResponse<void>>(`/webapi/postcard/${id}/approve`),
  reject: (id: number, reason: string) => request.post<ApiResponse<void>>(`/webapi/postcard/${id}/reject`, { reason }),
  delete: (id: number) => request.delete<ApiResponse<void>>(`/webapi/postcard/${id}`),
}

export const commentApi = {
  list: (params: { page?: number; size?: number; reviewStatus?: number }) =>
    request.post<ApiResponse<PageData<PostcardComment>>>('/webapi/comment/list', params),
  approve: (id: number) => request.post<ApiResponse<void>>(`/webapi/comment/${id}/approve`),
  reject: (id: number, reason: string) => request.post<ApiResponse<void>>(`/webapi/comment/${id}/reject`, { reason }),
}

export const reportApi = {
  list: (params: { page?: number; size?: number; status?: number }) =>
    request.post<ApiResponse<PageData<Report>>>('/webapi/report/list', params),
  handle: (id: number, handleNote?: string) => request.post<ApiResponse<void>>(`/webapi/report/${id}/handle`, { handleNote }),
  reject: (id: number, handleNote?: string) => request.post<ApiResponse<void>>(`/webapi/report/${id}/reject`, { handleNote }),
}

export const configApi = {
  list: (group?: string) =>
    request.get<ApiResponse<SysConfig[]>>('/webapi/config/list', { params: { group } }),
  create: (data: SysConfig) => request.post<ApiResponse<void>>('/webapi/config', data),
  update: (id: number, data: SysConfig) => request.put<ApiResponse<void>>(`/webapi/config/${id}`, data),
  delete: (id: number) => request.delete<ApiResponse<void>>(`/webapi/config/${id}`),
}

export const sensitiveWordApi = {
  list: (params: { page?: number; size?: number; word?: string; langCode?: string }) =>
    request.post<ApiResponse<PageData<SensitiveWord>>>('/webapi/sensitive-word/list', params),
  create: (data: SensitiveWord) => request.post<ApiResponse<void>>('/webapi/sensitive-word', data),
  update: (id: number, data: SensitiveWord) => request.put<ApiResponse<void>>(`/webapi/sensitive-word/${id}`, data),
  delete: (id: number) => request.delete<ApiResponse<void>>(`/webapi/sensitive-word/${id}`),
}

export const announcementApi = {
  list: (params: { page?: number; size?: number }) =>
    request.post<ApiResponse<PageData<Announcement>>>('/webapi/announcement/list', params),
  create: (data: Announcement) => request.post<ApiResponse<void>>('/webapi/announcement', data),
  update: (id: number, data: Announcement) => request.put<ApiResponse<void>>(`/webapi/announcement/${id}`, data),
  delete: (id: number) => request.delete<ApiResponse<void>>(`/webapi/announcement/${id}`),
}

export const versionApi = {
  list: () => request.get<ApiResponse<AppVersion[]>>('/webapi/version/list'),
  create: (data: AppVersion) => request.post<ApiResponse<void>>('/webapi/version', data),
  update: (id: number, data: AppVersion) => request.put<ApiResponse<void>>(`/webapi/version/${id}`, data),
  delete: (id: number) => request.delete<ApiResponse<void>>(`/webapi/version/${id}`),
}

export const vipConfigApi = {
  list: () => request.get<ApiResponse<SysConfig[]>>('/webapi/vip/config/list'),
  update: (data: SysConfig) => request.put<ApiResponse<void>>('/webapi/vip/config', data),
}

export const loginLogApi = {
  list: (params: { page?: number; size?: number }) =>
    request.post<ApiResponse<PageData<LoginLog>>>('/webapi/log/login/list', params),
}

export const actionLogApi = {
  list: (params: { page?: number; size?: number; userId?: number; actionType?: string }) =>
    request.post<ApiResponse<PageData<ActionLog>>>('/webapi/log/action/list', params),
}