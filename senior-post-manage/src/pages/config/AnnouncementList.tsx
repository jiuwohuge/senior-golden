import { useState, useEffect } from 'react'
import { Card, Table, Button, Space, Modal, Form, Input, DatePicker, Switch, Popconfirm, message } from 'antd'
import { PlusOutlined, EditOutlined, DeleteOutlined } from '@ant-design/icons'
import type { ColumnsType } from 'antd/es/table'
import dayjs from 'dayjs'
import { announcementApi } from '../../services/api'
import type { Announcement, PageQuery } from '../../types/models'

const { RangePicker } = DatePicker

const AnnouncementList = () => {
  const [loading, setLoading] = useState(false)
  const [data, setData] = useState<Announcement[]>([])
  const [total, setTotal] = useState(0)
  const [query, setQuery] = useState<PageQuery>({ page: 1, pageSize: 20 })
  const [modalVisible, setModalVisible] = useState(false)
  const [editing, setEditing] = useState<Announcement | null>(null)
  const [form] = Form.useForm()

  const fetchData = async () => {
    setLoading(true)
    try {
      const res = await announcementApi.list(query)
      setData(res.data.list)
      setTotal(res.data.total)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchData()
  }, [query])

  const handleAdd = () => {
    setEditing(null)
    form.resetFields()
    setModalVisible(true)
  }

  const handleEdit = (record: Announcement) => {
    setEditing(record)
    form.setFieldsValue({
      ...record,
      timeRange: [dayjs(record.startAt), dayjs(record.endAt)],
    })
    setModalVisible(true)
  }

  const handleDelete = async (id: number) => {
    await announcementApi.delete(id)
    message.success('已删除')
    fetchData()
  }

  const handleSubmit = async () => {
    const values = await form.validateFields()
    const payload = {
      ...values,
      startAt: values.timeRange[0].toISOString(),
      endAt: values.timeRange[1].toISOString(),
      titleJson: { en: values.title, zh: values.title },
      contentJson: { en: values.content, zh: values.content },
    }
    delete payload.timeRange

    if (editing) {
      await announcementApi.update({ ...editing, ...payload })
    } else {
      await announcementApi.create(payload)
    }
    message.success(editing ? '已更新' : '已创建')
    setModalVisible(false)
    fetchData()
  }

  const columns: ColumnsType<Announcement> = [
    { title: 'ID', dataIndex: 'id', width: 80 },
    { title: '标题', dataIndex: 'title', ellipsis: true },
    { title: '内容', dataIndex: 'content', ellipsis: true },
    {
      title: '生效时间',
      width: 300,
      render: (_, record) => `${record.startAt} ~ ${record.endAt}`,
    },
    {
      title: '状态',
      dataIndex: 'isActive',
      width: 100,
      render: (active) => (active ? <Switch checked disabled /> : <Switch disabled />),
    },
    { title: '创建时间', dataIndex: 'createdAt', width: 180 },
    {
      title: '操作',
      width: 150,
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
      title="公告管理"
      extra={
        <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>
          创建公告
        </Button>
      }
    >
      <Table columns={columns} dataSource={data} rowKey="id" loading={loading} pagination={{
        total,
        current: query.page,
        pageSize: query.pageSize,
        showSizeChanger: true,
        showTotal: (t) => `共 ${t} 条`,
        onChange: (page, pageSize) => setQuery({ ...query, page, pageSize }),
      }} />

      <Modal
        title={editing ? '编辑公告' : '创建公告'}
        open={modalVisible}
        onOk={handleSubmit}
        onCancel={() => setModalVisible(false)}
        width={600}
      >
        <Form form={form} layout="vertical">
          <Form.Item name="title" label="标题" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="content" label="内容" rules={[{ required: true }]}>
            <Input.TextArea rows={4} />
          </Form.Item>
          <Form.Item name="timeRange" label="生效时间" rules={[{ required: true }]}>
            <RangePicker showTime style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item name="isActive" label="是否激活" valuePropName="checked" initialValue={true}>
            <Switch />
          </Form.Item>
        </Form>
      </Modal>
    </Card>
  )
}

export default AnnouncementList