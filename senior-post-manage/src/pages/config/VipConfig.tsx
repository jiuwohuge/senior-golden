import { useState, useEffect } from 'react'
import { Card, Table, Switch, message, Tag, Space, Button, Modal, Form, InputNumber, Popconfirm } from 'antd'
import { PlusOutlined, EditOutlined } from '@ant-design/icons'
import type { ColumnsType } from 'antd/es/table'
import { configApi } from '../../services/api'
import type { SysConfig } from '../../types/models'

interface VipConfig extends SysConfig {
  isSwitch?: boolean
}

const VipConfigPage = () => {
  const [loading, setLoading] = useState(false)
  const [data, setData] = useState<VipConfig[]>([])
  const [modalVisible, setModalVisible] = useState(false)
  const [editing, setEditing] = useState<SysConfig | null>(null)
  const [form] = Form.useForm()

  const fetchData = async () => {
    setLoading(true)
    try {
      const res = await configApi.list({ page: 1, pageSize: 100, configGroup: 'vip' })
      const list = res.data.list.map((item: SysConfig) => ({
        ...item,
        isSwitch: item.configValue === 'true' || item.configValue === 'false',
      }))
      setData(list)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchData()
  }, [])

  const handleToggle = async (record: VipConfig, checked: boolean) => {
    await configApi.update({ ...record, configValue: String(checked) })
    message.success('已更新')
    fetchData()
  }

  const handleSave = async () => {
    const values = await form.validateFields()
    const targetValue = values.configValue
    await configApi.update({ ...editing!, configValue: String(targetValue) })
    message.success('已保存')
    setModalVisible(false)
    fetchData()
  }

  const columns: ColumnsType<VipConfig> = [
    { title: '配置键', dataIndex: 'configKey', width: 200 },
    { title: '配置值', dataIndex: 'configValue', width: 150 },
    { title: '描述', dataIndex: 'description' },
    {
      title: '操作',
      width: 150,
      render: (_, record) => (
        <Space>
          {record.isSwitch ? (
            <Switch checked={record.configValue === 'true'} onChange={(checked) => handleToggle(record, checked)} />
          ) : (
            <Button size="small" icon={<EditOutlined />} onClick={() => { setEditing(record); form.setFieldsValue(record); setModalVisible(true); }} />
          )}
        </Space>
      ),
    },
  ]

  return (
    <Card
      title="VIP权益配置"
      extra={
        <Button type="primary" icon={<PlusOutlined />} onClick={() => { setEditing(null); form.resetFields(); setModalVisible(true); }}>
          新增配置
        </Button>
      }
    >
      <Table columns={columns} dataSource={data} rowKey="id" loading={loading} pagination={false} />

      <Modal title="编辑VIP配置" open={modalVisible} onOk={handleSave} onCancel={() => setModalVisible(false)}>
        <Form form={form} layout="vertical">
          <Form.Item name="configKey" label="配置键" rules={[{ required: true }]}>
            <InputNumber style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item name="configValue" label="配置值" rules={[{ required: true }]}>
            <InputNumber style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item name="description" label="描述">
            <Input />
          </Form.Item>
        </Form>
      </Modal>
    </Card>
  )
}

export default VipConfigPage