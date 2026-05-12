import { PlusOutlined } from '@ant-design/icons'
import { Button, Form, Input, Modal, Popconfirm, Space, Table, Typography, message } from 'antd'
import { useEffect, useState } from 'react'
import { api } from '../../services/api'

const VIP_GROUP = 'vip'

export default function VipConfig() {
  const [rows, setRows] = useState<any[]>([])
  const [loading, setLoading] = useState(false)
  const [modalOpen, setModalOpen] = useState(false)
  const [editing, setEditing] = useState<any>(null)
  const [saving, setSaving] = useState(false)
  const [form] = Form.useForm()

  const load = () => {
    setLoading(true)
    api.configs({ page: { page: 1, size: 200 }, configGroup: VIP_GROUP })
      .then((d: any) => setRows(d.records || []))
      .catch((e: any) => message.error(e.message))
      .finally(() => setLoading(false))
  }

  useEffect(() => { load() }, [])

  const openAdd = () => {
    setEditing(null)
    form.resetFields()
    setModalOpen(true)
  }

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
      await api.saveConfig({ ...v, configGroup: VIP_GROUP })
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
        <h2 className="page-title">VIP 配置</h2>
        <Button type="primary" icon={<PlusOutlined />} onClick={openAdd}>新增</Button>
      </div>
      <Typography.Paragraph type="secondary" style={{ marginBottom: 16 }}>
        以下为 <Typography.Text code>sys_config</Typography.Text> 中分组 <Typography.Text code>{VIP_GROUP}</Typography.Text> 的键值，应用端 VIP 权益展示依赖这些配置。
      </Typography.Paragraph>
      <Table
        rowKey="id"
        loading={loading}
        dataSource={rows}
        size="middle"
        columns={[
          { title: 'ID', dataIndex: 'id', width: 72 },
          { title: 'Key', dataIndex: 'configKey' },
          { title: 'Value', dataIndex: 'configValue', ellipsis: true },
          { title: '说明', dataIndex: 'description', ellipsis: true },
          {
            title: '操作',
            width: 160,
            render: (_, r) => (
              <Space>
                <Button size="small" onClick={() => openEdit(r)}>编辑</Button>
                <Popconfirm title="确认删除？" onConfirm={async () => { await api.deleteConfig(r.id); load() }}>
                  <Button danger size="small">删除</Button>
                </Popconfirm>
              </Space>
            ),
          },
        ]}
      />
      <Modal
        title={editing ? '编辑 VIP 配置' : '新增 VIP 配置'}
        open={modalOpen}
        onOk={handleOk}
        onCancel={() => { setModalOpen(false); form.resetFields() }}
        confirmLoading={saving}
        destroyOnClose
        width={480}
      >
        <Form form={form} layout="vertical" style={{ marginTop: 16 }}>
          <Form.Item name="id" hidden><Input /></Form.Item>
          <Form.Item name="configKey" label="配置键" rules={[{ required: true, message: '请输入配置键' }]}>
            <Input placeholder="如 vip_price_monthly" />
          </Form.Item>
          <Form.Item name="configValue" label="配置值" rules={[{ required: true, message: '请输入配置值' }]}>
            <Input.TextArea placeholder="配置值，支持 JSON 或长文本" rows={4} />
          </Form.Item>
          <Form.Item name="description" label="说明">
            <Input placeholder="可选，描述该配置的用途" />
          </Form.Item>
        </Form>
      </Modal>
    </>
  )
}
