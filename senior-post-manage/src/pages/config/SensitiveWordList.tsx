import { useState, useEffect } from 'react'
import { Card, Table, Button, Space, Modal, Form, Input, Select, Popconfirm, message } from 'antd'
import { PlusOutlined, EditOutlined, DeleteOutlined } from '@ant-design/icons'
import type { ColumnsType } from 'antd/es/table'
import { sensitiveWordApi } from '../../services/api'
import type { SensitiveWord, PageQuery } from '../../types/models'

const LANG_OPTIONS = [
  { value: 'en', label: 'English' },
  { value: 'zh', label: '中文' },
  { value: 'ja', label: '日本語' },
  { value: 'ko', label: '한국어' },
]

const TYPE_OPTIONS = [
  { value: 'porn', label: '色情' },
  { value: 'politics', label: '政治' },
  { value: 'ad', label: '广告' },
  { value: 'other', label: '其他' },
]

const SensitiveWordList = () => {
  const [loading, setLoading] = useState(false)
  const [data, setData] = useState<SensitiveWord[]>([])
  const [total, setTotal] = useState(0)
  const [query, setQuery] = useState<PageQuery & { langCode?: string }>({ page: 1, pageSize: 50 })
  const [langCode, setLangCode] = useState('en')
  const [modalVisible, setModalVisible] = useState(false)
  const [editing, setEditing] = useState<SensitiveWord | null>(null)
  const [form] = Form.useForm()

  const fetchData = async () => {
    setLoading(true)
    try {
      const res = await sensitiveWordApi.list({ ...query, langCode })
      setData(res.data.list)
      setTotal(res.data.total)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchData()
  }, [query, langCode])

  const handleAdd = () => {
    setEditing(null)
    form.resetFields()
    setModalVisible(true)
  }

  const handleEdit = (record: SensitiveWord) => {
    setEditing(record)
    form.setFieldsValue(record)
    setModalVisible(true)
  }

  const handleDelete = async (id: number) => {
    await sensitiveWordApi.delete(id)
    message.success('已删除')
    fetchData()
  }

  const handleSubmit = async () => {
    const values = await form.validateFields()
    if (editing) {
      await sensitiveWordApi.update({ ...editing, ...values })
    } else {
      await sensitiveWordApi.create(values)
    }
    message.success(editing ? '已更新' : '已添加')
    setModalVisible(false)
    fetchData()
  }

  const columns: ColumnsType<SensitiveWord> = [
    { title: 'ID', dataIndex: 'id', width: 80 },
    { title: '敏感词', dataIndex: 'word', width: 150 },
    {
      title: '分类',
      dataIndex: 'type',
      width: 100,
      render: (t) => TYPE_OPTIONS.find((o) => o.value === t)?.label || t,
    },
    { title: '分类描述', dataIndex: 'typeText', width: 120 },
    {
      title: '语言',
      dataIndex: 'langCode',
      width: 100,
      render: (l) => LANG_OPTIONS.find((o) => o.value === l)?.label || l,
    },
    { title: '添加时间', dataIndex: 'createdAt', width: 180 },
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
      title="敏感词管理"
      extra={
        <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>
          添加敏感词
        </Button>
      }
    >
      <Space style={{ marginBottom: 16 }}>
        <Select value={langCode} onChange={(v) => { setLangCode(v); setQuery({ ...query, page: 1 }); }} options={LANG_OPTIONS} style={{ width: 120 }} />
      </Space>

      <Table columns={columns} dataSource={data} rowKey="id" loading={loading} pagination={false} />

      <Modal title={editing ? '编辑敏感词' : '添加敏感词'} open={modalVisible} onOk={handleSubmit} onCancel={() => setModalVisible(false)}>
        <Form form={form} layout="vertical">
          <Form.Item name="word" label="敏感词" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="type" label="分类" rules={[{ required: true }]}>
            <Select options={TYPE_OPTIONS} />
          </Form.Item>
          <Form.Item name="typeText" label="分类描述">
            <Input />
          </Form.Item>
          <Form.Item name="langCode" label="语言" rules={[{ required: true }]}>
            <Select options={LANG_OPTIONS} />
          </Form.Item>
        </Form>
      </Modal>
    </Card>
  )
}

export default SensitiveWordList