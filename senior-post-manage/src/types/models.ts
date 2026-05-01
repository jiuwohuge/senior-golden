export interface User {
  id: number
  email: string
  nickname: string
  birthYear: number
  countryCode: string
  bio: string
  avatarUrl: string
  stampsBalance: number
  isVip: boolean
  vipExpireAt: string
  status: number
  registerIp: string
  lastLoginAt: string
  createdAt: string
}

export interface UserQuery extends PageQuery {
  status?: number
  countryCode?: string
}

export interface Postcard {
  id: number
  userId: number
  content: string
  images: string[]
  status: number
  reviewStatus: number
  publishedAt: string
  createdAt: string
  user?: User
}

export interface PostcardComment {
  id: number
  postcardId: number
  userId: number
  content: string
  status: number
  reviewStatus: number
  createdAt: string
}

export interface Letter {
  id: number
  fromUserId: number
  toUserId: number
  letterType: number
  status: number
  content: string
  isAccelerated: boolean
  createdAt: string
}

export interface Report {
  id: number
  reporterUserId: number
  targetType: string
  targetId: number
  reason: string
  status: number
  handlerUserId: number
  handleNote: string
  createdAt: string
}

export interface SysConfig {
  id: number
  configKey: string
  configValue: string
  configGroup: string
  description: string
  createdAt: string
}

export interface SensitiveWord {
  id: number
  word: string
  type: string
  typeText: string
  langCode: string
  createdAt: string
}

export interface Announcement {
  id: number
  title: string
  titleJson: Record<string, string>
  content: string
  contentJson: Record<string, string>
  startAt: string
  endAt: string
  isActive: boolean
  createdAt: string
}

export interface AppVersion {
  id: number
  appPlatform: string
  versionCode: string
  minSupportedVersion: string
  forceUpdate: boolean
  updateUrl: string
  releaseNote: string
  createdAt: string
}

export interface LoginLog {
  id: number
  userId: number
  loginIp: string
  deviceUuid: string
  loginResult: number
  failReason: string
  createdAt: string
}

export interface ActionLog {
  id: number
  userId: number
  actionType: string
  targetType: string
  targetId: number
  details: Record<string, any>
  createdAt: string
}

export interface AdminUser {
  id: number
  username: string
  nickname: string
  role: number
  status: number
  lastLoginAt: string
  createdAt: string
}

export interface DashboardStats {
  totalUsers: number
  dailyActiveUsers: number
  totalPostcards: number
  totalLetters: number
  vipCount: number
  todayNewUsers: number
}