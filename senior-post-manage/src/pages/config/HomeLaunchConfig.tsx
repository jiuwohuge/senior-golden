import { Button, Radio, Space, Typography, message } from 'antd'
import { useCallback, useEffect, useState } from 'react'
import { api } from '../../services/api'

/**
 * 冷启动首页主推：展示池子数字，由运营手动切换时光信 / 有缘人。
 * GET /webapi/post-office/pool-status ；保存走 POST /webapi/config/save
 */
export default function HomeLaunchConfig() {
  const [loading, setLoading] = useState(false)
  const [saving, setSaving] = useState(false)
  const [waitingMatchCount, setWaitingMatchCount] = useState<number>(0)
  const [activeUserCount, setActiveUserCount] = useState<number>(0)
  const [canMatchNow, setCanMatchNow] = useState(false)
  const [action, setAction] = useState<'TIME_LETTER' | 'POST_OFFICE'>('TIME_LETTER')
  const [configId, setConfigId] = useState<number | undefined>()

  const load = useCallback(async () => {
    setLoading(true)
    try {
      const d: any = await api.postOfficePoolStatus()
      setWaitingMatchCount(Number(d.waitingMatchCount ?? 0))
      setActiveUserCount(Number(d.activeUserCount ?? 0))
      setCanMatchNow(Boolean(d.canMatchNow))
      const next = d.recommendedAction === 'POST_OFFICE' ? 'POST_OFFICE' : 'TIME_LETTER'
      setAction(next)
      setConfigId(d.recommendedActionConfigId)
    } catch (e: any) {
      message.error(e.message || '加载失败')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    void load()
  }, [load])

  const handleSave = async () => {
    setSaving(true)
    try {
      await api.saveConfig({
        id: configId,
        configKey: 'home.recommended_action',
        configValue: action,
        configGroup: 'home',
        description: '首页主 CTA：TIME_LETTER 或 POST_OFFICE',
      })
      message.success('已保存，App 下次刷新首页即生效')
      await load()
    } catch (e: any) {
      if (e?.errorFields) return
      message.error(e.message || '保存失败')
    } finally {
      setSaving(false)
    }
  }

  return (
    <>
      <div className="page-header">
        <h2 className="page-title">首页主推</h2>
      </div>
      <Typography.Paragraph type="secondary" style={{ marginBottom: 16 }}>
        池子数字只辅助判断，不会自动改 App 主按钮。冷启动默认「写给未来的自己」；你觉得可以接信时再切到「寄给有缘人」。
      </Typography.Paragraph>
      <Space direction="vertical" size={16} style={{ width: '100%', maxWidth: 560 }}>
        <Typography.Text>
          等待匹配：<Typography.Text strong>{loading ? '…' : waitingMatchCount}</Typography.Text>
          {'　'}活跃用户：<Typography.Text strong>{loading ? '…' : activeUserCount}</Typography.Text>
          {'　'}当前可匹配：<Typography.Text strong>{loading ? '…' : canMatchNow ? '是' : '否'}</Typography.Text>
        </Typography.Text>
        <Radio.Group
          value={action}
          onChange={(e) => setAction(e.target.value)}
          optionType="button"
          buttonStyle="solid"
        >
          <Radio.Button value="TIME_LETTER">时光信（写给未来的自己）</Radio.Button>
          <Radio.Button value="POST_OFFICE">寄给有缘人</Radio.Button>
        </Radio.Group>
        <Space>
          <Button type="primary" loading={saving} onClick={() => void handleSave()}>
            保存主路径
          </Button>
          <Button onClick={() => void load()} loading={loading}>
            刷新池子
          </Button>
        </Space>
      </Space>
    </>
  )
}
