import { Alert, Button, Form, Space, Switch, Typography, message } from 'antd'
import { useEffect, useState } from 'react'
import { api } from '../../services/api'

type ModerationConfigData = {
  postcardImageEnabled: boolean
  postcardTextEnabled: boolean
  baiduCredentialsReady: boolean
  deepseekCredentialsReady: boolean
}

export default function ModerationConfig() {
  const [loading, setLoading] = useState(false)
  const [saving, setSaving] = useState(false)
  const [cfg, setCfg] = useState<ModerationConfigData | null>(null)
  const [form] = Form.useForm()

  const load = () => {
    setLoading(true)
    api
      .getModerationConfig()
      .then((d: any) => {
        setCfg(d)
        form.setFieldsValue({
          postcardImageEnabled: d.postcardImageEnabled,
          postcardTextEnabled: d.postcardTextEnabled,
        })
      })
      .catch((e: Error) => message.error(e.message))
      .finally(() => setLoading(false))
  }

  useEffect(() => {
    load()
  }, [])

  const handleSave = async () => {
    try {
      const v = await form.validateFields()
      setSaving(true)
      await api.saveModerationConfig(v)
      message.success('已保存')
      load()
    } catch (e: unknown) {
      if (e && typeof e === 'object' && 'errorFields' in e) return
      message.error(e instanceof Error ? e.message : '保存失败')
    } finally {
      setSaving(false)
    }
  }

  return (
    <>
      <div className="page-header">
        <h2 className="page-title">内容安全</h2>
        <Button type="primary" loading={saving} onClick={handleSave}>
          保存
        </Button>
      </div>
      <Typography.Paragraph type="secondary" style={{ marginBottom: 16 }}>
        明信片机审开关保存在 <Typography.Text code>sys_config</Typography.Text>（分组{' '}
        <Typography.Text code>moderation</Typography.Text>）。关闭任一开关时，对应通道不参与自动通过，明信片保持待人工审核。
        API 密钥请在服务器环境变量中配置，此处仅显示是否已就绪。
      </Typography.Paragraph>
      {cfg && !cfg.baiduCredentialsReady && (
        <Alert
          type="warning"
          showIcon
          style={{ marginBottom: 12 }}
          message="百度配图鉴黄凭证未配置"
          description="请设置 MODERATION_BAIDU_APP_ID、MODERATION_BAIDU_API_KEY、MODERATION_BAIDU_API_SECRET 后，方可开启配图机审。"
        />
      )}
      {cfg && !cfg.deepseekCredentialsReady && (
        <Alert
          type="warning"
          showIcon
          style={{ marginBottom: 12 }}
          message="DeepSeek 文案审核凭证未配置"
          description="请设置 MODERATION_DEEPSEEK_API_KEY 后，方可开启正文机审。"
        />
      )}
      <Form form={form} layout="vertical" disabled={loading}>
        <Form.Item
          name="postcardImageEnabled"
          label="明信片配图鉴黄（百度）"
          valuePropName="checked"
          extra={
            cfg?.baiduCredentialsReady
              ? '凭证已就绪'
              : '凭证未就绪，开启时将保存失败'
          }
        >
          <Switch />
        </Form.Item>
        <Form.Item
          name="postcardTextEnabled"
          label="明信片正文审核（DeepSeek）"
          valuePropName="checked"
          extra={
            cfg?.deepseekCredentialsReady
              ? '凭证已就绪'
              : '凭证未就绪，开启时将保存失败'
          }
        >
          <Switch />
        </Form.Item>
      </Form>
      <Space style={{ marginTop: 8 }}>
        <Typography.Text type="secondary">
          双关关闭时：新发布明信片一律待人工审核；已移除发布时的敏感词校验，由 DeepSeek 机审覆盖。
        </Typography.Text>
      </Space>
    </>
  )
}
