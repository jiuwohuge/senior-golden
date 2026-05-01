import { useState, useEffect } from 'react'
import { Card, Table, Button, Space, Tag, Modal, Form, Input, InputNumber, message, Select, Popconfirm } from 'antd'
import { PlusOutlined, EditOutlined, DeleteOutlined } from '@ant-design/icons'
import type { ColumnsType } from 'antd/es/table'
import { configApi } from '../../services/api'
import type { SysConfig, PageQuery } from '../../types/models'

const GROUPS = [
  { value: 'stamps', label: '邮票配置' },
  { value: 'register', label: '注册配置' },
  { value: 'vip', label: 'VIP配置' },
  { value: 'system', label: '系统配置' },
]

const ConfigList = () => {
  const [loading, setLoading] = useState(false)
  const [data, setData] = useState<SysConfig[]>([])
  const [total, setTotal] = useState(0)
  const [query, setQuery] = useState<PageQuery & { configGroup?: string }>({ page: 1, pageSize: 50 })
  const [group, setGroup] = useState('stamps')
  const [modalVisible, setModalVisible] = useState(false)
  const [editing, setEditing] = useState<SysConfig | null>(null)
  const [form] = Form.useForm()

  const fetchData = async () => {
    setLoading(true)
    try {
      const res = await configApi.list({ ...query, configGroup: group })
      setData(res.data.list)
      setTotal(res.data.total)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchData()
  }, [query, group])

  const handleAdd = () => {
    setEditing(null)
    form.resetFields()
    setModalVisible(true)
  }

  const handleEdit = (record: SysConfig) => {
    setEditing(record)
    form.setFieldsValue(record)
    setModalVisible(true)
  }

  const handleDelete = async (id: number) => {
    await configApi.delete(id)
    message.success('已删除')
    fetchData()
  }

  const handleSubmit = async () => {
    const values = await form.validateFields()
    if (editing) {
      await configApi.update({ ...editing, ...values })
    } else {
      await configApi.create(values)
    }
    message.success(editing ? '已更新' : '已创建')
    setModalVisible(false)
    fetchData()
  }

  const columns: ColumnsType<SysConfig> = [
    { title: '配置键', dataIndex: 'configKey', width: 200 },
    { title: '配置值', dataIndex: 'configValue', ellipsis: true },
    { title: '描述', dataIndex: 'description', ellipsis: true },
    { title: '更新时间', dataIndex: 'updated_at', width: 180 },
    {
      title: '操作',
      width: 120,
      render: (_, record) => (
        <Space>
          <Button size="small" icon={<EditOutlined />} onClick={() => handleEdit(record)} />
          <Popconfirm title="确认删除？" onConfirm={() => handleDelete(record.id)}>
            <Button size="small" danger icon={<DeleteOutlined />} />
          </Popconfirm>
        </Space>
      ),
    },
  ]

  return (
    <Card
      title="邮票与系统配置"
      extra={
        <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>
          新增配置
        </Button>
      }
    >
      <Space style={{ marginBottom: 16 }}>
        <Select value={group} onChange={setGroup} options={GROUPS} style={{ width: 150 }} />
      </Space>

      <Table columns={columns} dataSource={data} rowKey="id" loading={loading} pagination={false} />

      <Modal
        title={editing ? '编辑配置' : '新增配置'}
        open={modalVisible}
        onOk={handleSubmit}
        onCancel={() => setModalVisible(false)}
      >
        <Form form={form} layout="vertical">
          <Form.Item name="configKey" label="配置键" rules={[{ required: true }]}>
            <Input disabled={!!editing} />
          </Form.Item>
          <Form.Item name="configValue" label="配置值" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="configGroup" label="分组" rules={[{ required: true }]}>
            <Select options={GROUPS} />
          </Form.Item>
          <Form.Item name="description" label="描述">
            <Input />
          </Form.Item>
        </Form>
      </Modal>
    </Card>
  )
}

export default ConfigList