import request from './request'
import type { ApiResponse, PageData, PageQuery } from '../types/api'
import type { User, UserQuery, Postcard, PostcardComment, Report, SysConfig, SensitiveWord, Announcement, AppVersion, LoginLog, ActionLog, DashboardStats, AdminUser } from '../types/models'

export const loginApi = {
  login: (data: { username: string; password: string }) =>
    request.post<ApiResponse<{ token: string; admin: AdminUser }>>('/admin/login', data),
}

export const userApi = {
  list: (params: UserQuery) =>
    request.get<ApiResponse<PageData<User>>>('/admin/user/list', { params }),
  detail: (id: number) =>
    request.get<ApiResponse<User>>(`/admin/user/${id}`),
  ban: (id: number) =>
    request.post<ApiResponse<void>>(`/admin/user/${id}/ban`),
  unban: (id: number) =>
    request.post<ApiResponse<void>>(`/admin/user/${id}/unban`),
  blockDevice: (deviceUuid: string) =>
    request.post<ApiResponse<void>>('/admin/device/block', { deviceUuid }),
}

export const postcardApi = {
  list: (params: PageQuery & { reviewStatus?: number }) =>
    request.get<ApiResponse<PageData<Postcard>>>('/admin/postcard/list', { params }),
  approve: (id: number) =>
    request.post<ApiResponse<void>>(`/admin/postcard/${id}/approve`),
  reject: (id: number, reason: string) =>
    request.post<ApiResponse<void>>(`/admin/postcard/${id}/reject`, { reason }),
  delete: (id: number) =>
    request.delete<ApiResponse<void>>(`/admin/postcard/${id}`),
}

export const commentApi = {
  list: (params: PageQuery & { reviewStatus?: number }) =>
    request.get<ApiResponse<PageData<PostcardComment>>>('/admin/comment/list', { params }),
  approve: (id: number) =>
    request.post<ApiResponse<void>>(`/admin/comment/${id}/approve`),
  reject: (id: number) =>
    request.post<ApiResponse<void>>(`/admin/comment/${id}/reject`),
  delete: (id: number) =>
    request.delete<ApiResponse<void>>(`/admin/comment/${id}`),
}

export const reportApi = {
  list: (params: PageQuery & { status?: number }) =>
    request.get<ApiResponse<PageData<Report>>>('/admin/report/list', { params }),
  handle: (id: number, handleNote: string) =>
    request.post<ApiResponse<void>>(`/admin/report/${id}/handle`, { handleNote }),
  reject: (id: number, handleNote: string) =>
    request.post<ApiResponse<void>>(`/admin/report/${id}/reject`, { handleNote }),
}

export const configApi = {
  list: (params: PageQuery & { configGroup?: string }) =>
    request.get<ApiResponse<PageData<SysConfig>>>('/admin/config/list', { params }),
  update: (data: SysConfig) =>
    request.put<ApiResponse<void>>('/admin/config', data),
  create: (data: Omit<SysConfig, 'id'>) =>
    request.post<ApiResponse<void>>('/admin/config', data),
  delete: (id: number) =>
    request.delete<ApiResponse<void>>(`/admin/config/${id}`),
}

export const sensitiveWordApi = {
  list: (params: PageQuery & { langCode?: string }) =>
    request.get<ApiResponse<PageData<SensitiveWord>>>('/admin/sensitive-word/list', { params }),
  create: (data: Omit<SensitiveWord, 'id'>) =>
    request.post<ApiResponse<void>>('/admin/sensitive-word', data),
  update: (data: SensitiveWord) =>
    request.put<ApiResponse<void>>('/admin/sensitive-word', data),
  delete: (id: number) =>
    request.delete<ApiResponse<void>>(`/admin/sensitive-word/${id}`),
}

export const announcementApi = {
  list: (params: PageQuery) =>
    request.get<ApiResponse<PageData<Announcement>>>('/admin/announcement/list', { params }),
  create: (data: Announcement) =>
    request.post<ApiResponse<void>>('/admin/announcement', data),
  update: (data: Announcement) =>
    request.put<ApiResponse<void>>('/admin/announcement', data),
  delete: (id: number) =>
    request.delete<ApiResponse<void>>(`/admin/announcement/${id}`),
}

export const versionApi = {
  list: (params: PageQuery & { appPlatform?: string }) =>
    request.get<ApiResponse<PageData<AppVersion>>>('/admin/version/list', { params }),
  create: (data: AppVersion) =>
    request.post<ApiResponse<void>>('/admin/version', data),
  update: (data: AppVersion) =>
    request.put<ApiResponse<void>>('/admin/version', data),
  delete: (id: number) =>
    request.delete<ApiResponse<void>>(`/admin/version/${id}`),
}

export const logApi = {
  loginList: (params: PageQuery) =>
    request.get<ApiResponse<PageData<LoginLog>>>('/admin/log/login', { params }),
  actionList: (params: PageQuery) =>
    request.get<ApiResponse<PageData<ActionLog>>>('/admin/log/action', { params }),
}

export const dashboardApi = {
  stats: () =>
    request.get<ApiResponse<DashboardStats>>('/admin/dashboard/stats'),
}