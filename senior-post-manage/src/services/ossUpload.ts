import axios from 'axios'

import request from './request'

export type OssPutSignResult = {
  putUrl: string
  objectKey: string
  contentType: string
  expireAtEpochMillis?: number
  readUrl?: string
}

const ALLOWED_EXT = new Set(['jpg', 'jpeg', 'png', 'webp', 'gif'])

function normalizeExt(file: File): string {
  const fromName = file.name.split('.').pop()?.toLowerCase().replace(/^\./, '') ?? ''
  if (ALLOWED_EXT.has(fromName)) return fromName === 'jpeg' ? 'jpg' : fromName
  const t = file.type.toLowerCase()
  if (t.includes('png')) return 'png'
  if (t.includes('webp')) return 'webp'
  if (t.includes('gif')) return 'gif'
  return 'jpg'
}

/** 管理端：为指定用户获取 PUT 预签名（/webapi/oss/put-sign）。 */
export async function fetchAdminPutSign(
  userId: number,
  scene: 'avatar' | 'postcard' | 'letter',
  file: File,
): Promise<OssPutSignResult> {
  const ext = normalizeExt(file)
  const contentType = file.type || 'image/jpeg'
  return request.get('/webapi/oss/put-sign', {
    params: { userId, scene, ext, contentType },
  }) as Promise<OssPutSignResult>
}

/** 直传二进制至 OSS（不经业务后端）。 */
export async function putFileToOss(sign: OssPutSignResult, file: File): Promise<void> {
  const resp = await axios.put(sign.putUrl, file, {
    headers: { 'Content-Type': sign.contentType },
    timeout: 60_000,
    validateStatus: (s) => s != null && s < 500,
  })
  if (resp.status < 200 || resp.status >= 300) {
    throw new Error(`OSS 上传失败: HTTP ${resp.status}`)
  }
}

/** 管理端上传用户头像，返回 objectKey。 */
export async function uploadAdminUserAvatar(userId: number, file: File): Promise<string> {
  const sign = await fetchAdminPutSign(userId, 'avatar', file)
  await putFileToOss(sign, file)
  if (!sign.objectKey?.trim()) {
    throw new Error('上传成功但未返回 objectKey')
  }
  return sign.objectKey.trim()
}

/** 批量 GET 预签名用于预览。 */
export async function signObjectKeysForPreview(objectKeys: string[]): Promise<string | null> {
  const keys = objectKeys.map((k) => k.trim()).filter(Boolean)
  if (!keys.length) return null
  const res: any = await request.post('/webapi/oss/get-sign', { objectKeys: keys })
  return res?.items?.[0]?.signedUrl ?? null
}
