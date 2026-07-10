import { PlusOutlined } from '@ant-design/icons'
import { Button, Form, Input, Modal, Popconfirm, Space, Table, Typography, message } from 'antd'
import { useEffect, useState } from 'react'
import { api } from '../../services/api'

const MATCH_GROUP = 'match'

export default function MatchConfig() {
  const [rows, setRows] = useState<any[]>([])
  const [loading, setLoading] = useState(false)
  const [modalOpen, setModalOpen] = useState(false)
  const [editing, setEditing] = useState<any>(null)
  const [saving, setSaving] = useState(false)
  const [form] = Form.useForm()

  const load = () => {
    setLoading(true)
    api.configs({ page: { page: 1, size: 200 }, configGroup: MATCH_GROUP })
      .then((d: any) => setRows(d.records || []))
      .catch((e: any) => message.error(e.message))
      .finally(() => setLoading(false))
  }

  useEffect(() => { load() }, [])

  const openEdit = (r: any) => {
    setEditing(r)
    form.setFieldsValue({
      id: r.id,
      configKey: r.configKey,
      configValue: r.configValue,
      description: r.description,
    })
    setModalOpen(true)
  }

  const handleOk = async () => {
    try {
      const v = await form.validateFields()
      setSaving(true)
      await api.saveConfig({ ...v, configGroup: MATCH_GROUP })
      setModalOpen(false)
      form.resetFields()
      load()
    } catch (e: any) {
      if (e?.errorFields) return
      message.error(e.message)
    } finally {
      setSaving(false)
    }
  }

  return (
    <>
      <div className="page-header">
        <h2 className="page-title">匹配配置</h2>
      </div>
      <Typography.Paragraph type="secondary" style={{ marginBottom: 16 }}>
        §7.3 权重与 §7.4 60/30/10 分发比例；修改后推荐与邮局匹配即时生效。
      </Typography.Paragraph>
      <Table
        rowKey="id"
        loading={loading}
        dataSource={rows}
        size="middle"
        columns={[
          { title: 'ID', dataIndex: 'id', width: 72 },
          { title: 'Key', dataIndex: 'configKey', width: 220 },
          { title: 'Value', dataIndex: 'configValue', width: 120 },
          { title: '说明', dataIndex: 'description', ellipsis: true },
          {
            title: '操作',
            width: 100,
            render: (_, r) => (
              <Button size="small" onClick={() => openEdit(r)}>编辑</Button>
            ),
          },
        ]}
      />
      <Modal
        title="编辑匹配配置"
        open={modalOpen}
        onOk={handleOk}
        onCancel={() => { setModalOpen(false); form.resetFields() }}
        confirmLoading={saving}
        destroyOnClose
        width={480}
      >
        <Form form={form} layout="vertical" style={{ marginTop: 16 }}>
          <Form.Item name="id" hidden><Input /></Form.Item>
          <Form.Item name="configKey" label="配置键">
            <Input disabled />
          </Form.Item>
          <Form.Item name="configValue" label="配置值" rules={[{ required: true, message: '请输入配置值' }]}>
            <Input />
          </Form.Item>
          <Form.Item name="description" label="说明">
            <Input />
          </Form.Item>
        </Form>
      </Modal>
    </>
  )
}
