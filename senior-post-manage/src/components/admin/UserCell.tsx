import { Avatar, Space, Typography } from 'antd'
import { UserOutlined } from '@ant-design/icons'
import { useNavigate } from 'react-router-dom'
import { useEffect, useMemo, useState } from 'react'
import { api } from '../../services/api'
import { signObjectKeysBatch } from '../../services/ossUpload'

const { Text, Link } = Typography

export type UserBrief = {
  id: number
  nickname?: string
  avatarUrl?: string
}

type UserCellProps = {
  userId?: number | null
  /** 若列表已带昵称/头像可直接传入，减少 briefs 请求 */
  brief?: Partial<UserBrief> | null
  /** 外部已签名的头像 URL */
  signedUrl?: string | null
}

/**
 * 管理端统一用户展示：头像+昵称；点击跳转 /user?edit={id} 打开用户编辑弹窗。
 */
export default function UserCell({ userId, brief, signedUrl }: UserCellProps) {
  const navigate = useNavigate()
  if (userId == null || Number(userId) <= 0) {
    return <Text type="secondary">—</Text>
  }
  const id = Number(userId)
  const nickname = brief?.nickname?.trim() || `用户 #${id}`
  const src = signedUrl || undefined

  return (
    <Link
      onClick={(e) => {
        e.preventDefault()
        navigate(`/user?edit=${id}`)
      }}
      style={{ display: 'inline-flex', alignItems: 'center', gap: 8, maxWidth: 180 }}
    >
      <Avatar size={28} src={src} icon={<UserOutlined />} style={{ flexShrink: 0, background: '#8b9a7a' }} />
      <Space direction="vertical" size={0} style={{ minWidth: 0 }}>
        <Text ellipsis style={{ maxWidth: 120, margin: 0 }}>
          {nickname}
        </Text>
        <Text type="secondary" style={{ fontSize: 11, margin: 0 }}>
          ID {id}
        </Text>
      </Space>
    </Link>
  )
}

/**
 * 按页批量拉取用户摘要并签名头像；供列表列渲染。
 */
export function useUserBriefs(userIds: Array<number | null | undefined>) {
  const [briefs, setBriefs] = useState<Record<number, UserBrief>>({})
  const [signed, setSigned] = useState<Record<number, string>>({})

  const idsKey = useMemo(() => {
    const set = new Set<number>()
    for (const raw of userIds) {
      const id = Number(raw)
      if (Number.isFinite(id) && id > 0) set.add(id)
    }
    return [...set].sort((a, b) => a - b).join(',')
  }, [userIds])

  useEffect(() => {
    let cancelled = false
    const ids = idsKey
      ? idsKey.split(',').map((s) => Number(s)).filter((n) => n > 0)
      : []
    if (!ids.length) {
      setBriefs({})
      setSigned({})
      return
    }
    ;(async () => {
      try {
        const list: UserBrief[] = ((await api.userBriefs(ids)) as unknown as UserBrief[]) || []
        if (cancelled) return
        const map: Record<number, UserBrief> = {}
        for (const b of list) {
          if (b?.id != null) map[Number(b.id)] = b
        }
        setBriefs(map)
        const keys = list.map((b) => b.avatarUrl?.trim()).filter(Boolean) as string[]
        if (!keys.length) {
          setSigned({})
          return
        }
        const signedMap = await signAvatarKeysForUsers(list)
        if (!cancelled) setSigned(signedMap)
      } catch (e: any) {
        console.warn('userBriefs failed', e?.message)
      }
    })()
    return () => {
      cancelled = true
    }
  }, [idsKey])

  return { briefs, signed }
}

async function signAvatarKeysForUsers(rows: UserBrief[]): Promise<Record<number, string>> {
  const withKey = rows.filter((r) => r.avatarUrl?.trim())
  if (!withKey.length) return {}
  const keys = withKey.map((r) => r.avatarUrl!.trim())
  try {
        const items = await signObjectKeysBatch(keys)
    const byKey = new Map<string, string>()
    for (const it of items) {
      if (it.objectKey && it.signedUrl) byKey.set(it.objectKey, it.signedUrl)
    }
    const out: Record<number, string> = {}
    for (const r of withKey) {
      const url = byKey.get(r.avatarUrl!.trim())
      if (url) out[r.id] = url
    }
    return out
  } catch (e: any) {
    console.warn('sign avatars failed', e?.message)
    return {}
  }
}
