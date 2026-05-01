import { Button, Form, Input, Space, Table, Typography, message } from 'antd'
import { useEffect, useState } from 'react'
import { api } from '../../services/api'

const VIP_GROUP = 'vip'

export default function VipConfig() {
  const [rows, setRows] = useState<any[]>([])
  const [loading, setLoading] = useState(false)
  const [form] = Form.useForm()

  const load = () => {
    setLoading(true)
    api.configs({ page: { page: 1, size: 200 }, configGroup: VIP_GROUP })
      .then((d: any) => setRows(d.records || []))
      .catch((e: any) => message.error(e.message))
      .finally(() => setLoading(false))
  }

  useEffect(() => { load() }, [])

  const onFinish = async (v: any) => {
    await api.saveConfig({ ...v, configGroup: VIP_GROUP })
    form.resetFields()
    load()
  }

  return (
    <>
      <Typography.Paragraph type="secondary" style={{ marginBottom: 16 }}>
        以下为 <Typography.Text code>sys_config</Typography.Text> 中分组 <Typography.Text code>{VIP_GROUP}</Typography.Text> 的键值，应用端 VIP 权益展示依赖这些配置。
      </Typography.Paragraph>
      <Form form={form} layout="inline" onFinish={onFinish} style={{ marginBottom: 16 }}>
        <Form.Item name="id" hidden><Input /></Form.Item>
        <Form.Item name="configKey" rules={[{ required: true }]}><Input placeholder="配置键" style={{ width: 160 }} /></Form.Item>
        <Form.Item name="configValue" rules={[{ required: true }]}><Input placeholder="配置值" style={{ width: 220 }} /></Form.Item>
        <Form.Item name="description"><Input placeholder="说明" style={{ width: 180 }} /></Form.Item>
        <Button type="primary" htmlType="submit">保存</Button>
        <Button onClick={() => form.resetFields()}>清空</Button>
      </Form>
      <Table
        rowKey="id"
        loading={loading}
        dataSource={rows}
        columns={[
          { title: 'ID', dataIndex: 'id', width: 72 },
          { title: 'Key', dataIndex: 'configKey' },
          { title: 'Value', dataIndex: 'configValue' },
          { title: '说明', dataIndex: 'description' },
          {
            title: '操作',
            width: 180,
            render: (_, r) => (
              <Space>
                <Button
                  size="small"
                  onClick={() => {
                    form.setFieldsValue({
                      id: r.id,
                      configKey: r.configKey,
                      configValue: r.configValue,
                      description: r.description,
                    })
                  }}
                >
                  编辑
                </Button>
                <Button danger size="small" onClick={async () => { await api.deleteConfig(r.id); load() }}>删除</Button>
              </Space>
            ),
          },
        ]}
      />
    </>
  )
}
