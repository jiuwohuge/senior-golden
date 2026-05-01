import { useState, useEffect } from 'react'
import { Card, Table, Button, Space, Modal, Form, Input, Select, Switch, Popconfirm, message } from 'antd'
import { PlusOutlined, EditOutlined, DeleteOutlined } from '@ant-design/icons'
import type { ColumnsType } from 'antd/es/table'
import { versionApi } from '../../services/api'
import type { AppVersion, PageQuery } from '../../types/models'

const PLATFORM_OPTIONS = [
  { value: 'ios', label: 'iOS' },
  { value: 'android', label: 'Android' },
]

const VersionList = () => {
  const [loading, setLoading] = useState(false)
  const [data, setData] = useState<AppVersion[]>([])
  const [total, setTotal] = useState(0)
  const [query, setQuery] = useState<PageQuery & { appPlatform?: string }>({ page: 1, pageSize: 20 })
  const [platform, setPlatform] = useState<string | undefined>()
  const [modalVisible, setModalVisible] = useState(false)
  const [editing, setEditing] = useState<AppVersion | null>(null)
  const [form] = Form.useForm()

  const fetchData = async () => {
    setLoading(true)
    try {
      const res = await versionApi.list({ ...query, appPlatform: platform })
      setData(res.data.list)
      setTotal(res.data.total)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchData()
  }, [query, platform])

  const handleAdd = () => {
    setEditing(null)
    form.resetFields()
    setModalVisible(true)
  }

  const handleEdit = (record: AppVersion) => {
    setEditing(record)
    form.setFieldsValue(record)
    setModalVisible(true)
  }

  const handleDelete = async (id: number) => {
    await versionApi.delete(id)
    message.success('已删除')
    fetchData()
  }

  const handleSubmit = async () => {
    const values = await form.validateFields()
    if (editing) {
      await versionApi.update({ ...editing, ...values })
    } else {
      await versionApi.create(values)
    }
    message.success(editing ? '已更新' : '已创建')
    setModalVisible(false)
    fetchData()
  }

  const columns: ColumnsType<AppVersion> = [
    { title: 'ID', dataIndex: 'id', width: 80 },
    {
      title: '平台',
      dataIndex: 'appPlatform',
      width: 100,
      render: (p) => (p === 'ios' ? 'iOS' : 'Android'),
    },
    { title: '版本号', dataIndex: 'versionCode', width: 120 },
    { title: '最低支持版本', dataIndex: 'minSupportedVersion', width: 120 },
    {
      title: '强制更新',
      dataIndex: 'forceUpdate',
      width: 100,
      render: (f) => (f ? <Switch checked disabled /> : <Switch disabled />),
    },
    { title: '更新地址', dataIndex: 'updateUrl', ellipsis: true },
    { title: '更新日志', dataIndex: 'releaseNote', ellipsis: true },
    { title: '创建时间', dataIndex: 'createdAt', width: 180 },
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
      title="App版本管理"
      extra={
        <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>
          添加版本
        </Button>
      }
    >
      <Space style={{ marginBottom: 16 }}>
        <Select
          placeholder="选择平台"
          value={platform}
          onChange={(v) => { setPlatform(v); setQuery({ ...query, page: 1 }); }}
          allowClear
          style={{ width: 150 }}
        >
          {PLATFORM_OPTIONS.map((o) => (
            <Select.Option key={o.value} value={o.value}>{o.label}</Select.Option>
          ))}
        </Select>
      </Space>

      <Table columns={columns} dataSource={data} rowKey="id" loading={loading} pagination={{
        total,
        current: query.page,
        pageSize: query.pageSize,
        showSizeChanger: true,
        showTotal: (t) => `共 ${t} 条`,
        onChange: (page, pageSize) => setQuery({ ...query, page, pageSize }),
      }} />

      <Modal
        title={editing ? '编辑版本' : '添加版本'}
        open={modalVisible}
        onOk={handleSubmit}
        onCancel={() => setModalVisible(false)}
        width={600}
      >
        <Form form={form} layout="vertical">
          <Form.Item name="appPlatform" label="平台" rules={[{ required: true }]}>
            <Select options={PLATFORM_OPTIONS} />
          </Form.Item>
          <Form.Item name="versionCode" label="版本号" rules={[{ required: true }]}>
            <Input placeholder="如: 1.0.0" />
          </Form.Item>
          <Form.Item name="minSupportedVersion" label="最低支持版本">
            <Input placeholder="如: 1.0.0" />
          </Form.Item>
          <Form.Item name="forceUpdate" label="强制更新" valuePropName="checked" initialValue={false}>
            <Switch />
          </Form.Item>
          <Form.Item name="updateUrl" label="更新地址" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="releaseNote" label="更新日志">
            <Input.TextArea rows={4} />
          </Form.Item>
        </Form>
      </Modal>
    </Card>
  )
}

export default VersionList