import { PlusOutlined } from '@ant-design/icons'
import { Button, Form, Input, Modal, Popconfirm, Space, Table, message } from 'antd'
import { useEffect, useState } from 'react'
import { api } from '../../services/api'

export default function CountryList() {
  const [rows, setRows] = useState<any[]>([])
  const [loading, setLoading] = useState(false)
  const [keyword, setKeyword] = useState('')
  const [modalOpen, setModalOpen] = useState(false)
  const [editing, setEditing] = useState<any>(null)
  const [saving, setSaving] = useState(false)
  const [form] = Form.useForm()

  const fetchList = (kw: string) => {
    setLoading(true)
    api.countries({ page: { page: 1, size: 500 }, keyword: kw.trim() || undefined })
      .then((d: any) => setRows(d.records || []))
      .catch((e: any) => message.error(e.message))
      .finally(() => setLoading(false))
  }

  useEffect(() => { fetchList('') }, [])

  const openAdd = () => {
    setEditing(null)
    form.resetFields()
    setModalOpen(true)
  }

  const openEdit = (r: any) => {
    setEditing(r)
    form.setFieldsValue({
      id: r.id,
      countryCode: r.countryCode,
      countryNameEn: r.countryNameEn,
      countryNameZh: r.countryNameZh,
      sortOrder: r.sortOrder,
    })
    setModalOpen(true)
  }

  const handleOk = async () => {
    try {
      const v = await form.validateFields()
      const sortOrder = v.sortOrder === '' || v.sortOrder === undefined ? 0 : Number(v.sortOrder)
      setSaving(true)
      await api.saveCountry({ ...v, sortOrder })
      setModalOpen(false)
      form.resetFields()
      fetchList(keyword)
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
        <h2 className="page-title">国家/地区</h2>
        <Button type="primary" icon={<PlusOutlined />} onClick={openAdd}>新增</Button>
      </div>
      <div className="filter-bar">
        <Input
          placeholder="代码/中英文名称"
          allowClear
          value={keyword}
          onChange={(e) => setKeyword(e.target.value)}
          onPressEnter={() => fetchList(keyword)}
          style={{ width: 220 }}
        />
        <Button type="primary" ghost onClick={() => fetchList(keyword)}>查询</Button>
      </div>
      <Table
        rowKey="id"
        loading={loading}
        dataSource={rows}
        size="middle"
        columns={[
          { title: 'ID', dataIndex: 'id', width: 72 },
          { title: '代码', dataIndex: 'countryCode', width: 88 },
          { title: '英文', dataIndex: 'countryNameEn' },
          { title: '中文', dataIndex: 'countryNameZh' },
          { title: '排序', dataIndex: 'sortOrder', width: 72 },
          {
            title: '操作',
            width: 160,
            render: (_, r) => (
              <Space>
                <Button size="small" onClick={() => openEdit(r)}>编辑</Button>
                <Popconfirm title="确认删除？" onConfirm={async () => { await api.deleteCountry(r.id); fetchList(keyword) }}>
                  <Button danger size="small">删除</Button>
                </Popconfirm>
              </Space>
            ),
          },
        ]}
      />
      <Modal
        title={editing ? '编辑国家/地区' : '新增国家/地区'}
        open={modalOpen}
        onOk={handleOk}
        onCancel={() => { setModalOpen(false); form.resetFields() }}
        confirmLoading={saving}
        destroyOnClose
        width={480}
      >
        <Form form={form} layout="vertical" style={{ marginTop: 16 }}>
          <Form.Item name="id" hidden><Input /></Form.Item>
          <Form.Item name="countryCode" label="ISO 代码" rules={[{ required: true, message: '请输入 ISO 代码' }]}>
            <Input placeholder="如 CN、US、JP" />
          </Form.Item>
          <Form.Item name="countryNameEn" label="英文名" rules={[{ required: true, message: '请输入英文名' }]}>
            <Input placeholder="English name" />
          </Form.Item>
          <Form.Item name="countryNameZh" label="中文名" rules={[{ required: true, message: '请输入中文名' }]}>
            <Input placeholder="中文名称" />
          </Form.Item>
          <Form.Item name="sortOrder" label="排序">
            <Input type="number" placeholder="数字越小越靠前，默认 0" />
          </Form.Item>
        </Form>
      </Modal>
    </>
  )
}
