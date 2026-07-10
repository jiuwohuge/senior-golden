import { Alert, Button, Space, Typography, message } from 'antd'
import { useEffect, useState } from 'react'
import { api } from '../../services/api'

type ModerationConfigData = {
  baiduCredentialsReady: boolean
  deepseekCredentialsReady: boolean
}

export default function ModerationConfig() {
  const [loading, setLoading] = useState(false)
  const [refreshing, setRefreshing] = useState(false)
  const [cfg, setCfg] = useState<ModerationConfigData | null>(null)

  const load = () => {
    setLoading(true)
    api
      .getModerationConfig()
      .then((d: any) => setCfg(d))
      .catch((e: Error) => message.error(e.message))
      .finally(() => setLoading(false))
  }

  useEffect(() => {
    load()
  }, [])

  const handleRefresh = async () => {
    setRefreshing(true)
    try {
      await api.saveModerationConfig()
      message.success('已刷新凭证检测缓存')
      load()
    } catch (e: unknown) {
      message.error(e instanceof Error ? e.message : '刷新失败')
    } finally {
      setRefreshing(false)
    }
  }

  return (
    <>
      <div className="page-header">
        <h2 className="page-title">内容安全</h2>
        <Button type="primary" loading={refreshing || loading} onClick={handleRefresh}>
          刷新检测
        </Button>
      </div>
      <Typography.Paragraph type="secondary" style={{ marginBottom: 16 }}>
        4.0 已移除明信片机审链路。此处仅展示信件/时光信等内容审核所需的外部凭证是否已在服务端配置就绪。
      </Typography.Paragraph>
      {cfg && !cfg.baiduCredentialsReady && (
        <Alert
          type="warning"
          showIcon
          style={{ marginBottom: 12 }}
          message="百度配图鉴黄凭证未配置"
          description="请设置 MODERATION_BAIDU_APP_ID、MODERATION_BAIDU_API_KEY、MODERATION_BAIDU_API_SECRET。"
        />
      )}
      {cfg && !cfg.deepseekCredentialsReady && (
        <Alert
          type="warning"
          showIcon
          style={{ marginBottom: 12 }}
          message="DeepSeek 文案审核凭证未配置"
          description="请设置 MODERATION_DEEPSEEK_API_KEY。"
        />
      )}
      {cfg && cfg.baiduCredentialsReady && cfg.deepseekCredentialsReady && (
        <Alert type="success" showIcon message="外部审核凭证均已就绪" />
      )}
      <Space style={{ marginTop: 16 }}>
        <Typography.Text type="secondary">
          敏感词库请在「系统配置 → 敏感词」维护；信件审核策略将在 M1 投递/审核链路中接入。
        </Typography.Text>
      </Space>
    </>
  )
}
