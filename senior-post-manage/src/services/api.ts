import request from './request'

export const api = {
  login: (username: string, password: string) => request.post('/webapi/auth/login', { username, password }),
  currentAdmin: () => request.get('/webapi/auth/current'),
  dashboard: () => request.get('/webapi/dashboard/summary'),

  users: (params: any) => request.post('/webapi/user/paging', params),
  saveUser: (body: {
    id: number
    nickname?: string
    birthYear?: number
    countryCode?: string
    bio?: string
    status?: number
    avatarUrl?: string
  }) => request.post('/webapi/user/save', body),
  deleteUser: (id: number) => request.post(`/webapi/user/${id}/delete`),
  approveUserAvatar: (id: number) => request.post(`/webapi/user/${id}/avatar/approve`),
  rejectUserAvatar: (id: number) => request.post(`/webapi/user/${id}/avatar/reject`),
  userStatus: (id: number, status: number) => request.post(`/webapi/user/${id}/status?status=${status}`),
  userBatchStatus: (ids: number[], status: number) =>
    request.post('/webapi/user/batch-status', { ids, status }),
  userVipDebug: (id: number, body: { isVip: boolean; vipExpireAt?: string | null; clearVipExpireAt?: boolean }) =>
    request.post(`/webapi/user/${id}/vip-debug`, body),
  userDevices: (userId: number) => request.get(`/webapi/user/${userId}/devices`),
  blockDevice: (body: { deviceUuid: string; reason?: string }) => request.post('/webapi/user/device/block', body),

  letterAuditPaging: (params: any) => request.post('/webapi/letter-audit/paging', params),
  letterAuditApprove: (id: number) => request.post(`/webapi/letter-audit/${id}/approve`),
  letterAuditReject: (id: number) => request.post(`/webapi/letter-audit/${id}/reject`),
  letterAuditBatchApprove: (ids: number[]) =>
    request.post('/webapi/letter-audit/batch-approve', { ids }),
  letterAuditBatchReject: (ids: number[]) =>
    request.post('/webapi/letter-audit/batch-reject', { ids }),

  mailOutboxPaging: (params: any) => request.post('/webapi/mail-outbox/paging', params),
  mailOutboxDetail: (id: number) => request.get(`/webapi/mail-outbox/${id}`),
  mailOutboxRetry: (id: number) => request.post(`/webapi/mail-outbox/${id}/retry`),

  penpalPaging: (params: any) => request.post('/webapi/relation/penpal/paging', params),
  penpalDissolve: (id: number) => request.post(`/webapi/relation/penpal/${id}/dissolve`),

  adminOperationLogs: (params: any) => request.post('/webapi/log/admin-operation/paging', params),

  commerceBatchStatus: (ids: number[], status: number) =>
    request.post('/webapi/commerce/products/batch-status', { ids, status }),

  /** 私有桶看图：列表/详情已服务端换签；此接口供扩展场景批量换签 */
  ossGetSign: (body: { objectKeys: string[] }) => request.post('/webapi/oss/get-sign', body),
  ossPutSign: (params: {
    userId: number
    scene: string
    ext?: string
    contentType?: string
  }) => request.get('/webapi/oss/put-sign', { params }),

  timeLetters: (params: any) => request.post('/webapi/content/time-letter/paging', params),
  timeLetterDetail: (id: number) => request.get(`/webapi/content/time-letter/${id}`),
  takedownTimeLetter: (id: number, reason: string) =>
    request.post(`/webapi/content/time-letter/${id}/takedown`, { reason }),

  reports: (params: any) => request.post('/webapi/report/paging', params),
  handleReport: (id: number, handleNote?: string) => request.post(`/webapi/report/${id}/handle`, { handleNote, result: 1 }),
  rejectReport: (id: number, handleNote?: string) => request.post(`/webapi/report/${id}/reject`, { handleNote, result: 2 }),

  configs: (body?: any) => request.post('/webapi/config/paging', body ?? { page: { page: 1, size: 200 } }),
  saveConfig: (body: any) => request.post('/webapi/config/save', body),
  deleteConfig: (id: number) => request.post(`/webapi/config/${id}/delete`),

  getModerationConfig: () => request.get('/webapi/config/moderation'),
  saveModerationConfig: () => request.post('/webapi/config/moderation/save', {}),

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
  feedbackPaging: (params: any) => request.post('/webapi/feedback/paging', params),

  commerceProducts: (body?: any) =>
    request.post('/webapi/commerce/products/paging', body ?? { page: { page: 1, size: 200 } }),
  saveCommerceProduct: (body: any) => request.post('/webapi/commerce/products/save', body),
  grantCommerce: (body: { userId: number; productId: number }) => request.post('/webapi/commerce/grant', body),
}
