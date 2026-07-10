import { PlusOutlined } from '@ant-design/icons'
import { Button, Form, Input, InputNumber, Modal, Popconfirm, Space, Table, message } from 'antd'
import { useEffect, useState } from 'react'
import { api } from '../../services/api'

export default function CommerceProductList() {
  const [rows, setRows] = useState<any[]>([])
  const [loading, setLoading] = useState(false)
  const [modalOpen, setModalOpen] = useState(false)
  const [grantOpen, setGrantOpen] = useState(false)
  const [editing, setEditing] = useState<any>(null)
  const [saving, setSaving] = useState(false)
  const [form] = Form.useForm()
  const [grantForm] = Form.useForm()

  const load = () => {
    setLoading(true)
    api.commerceProducts({ page: { page: 1, size: 200 } })
      .then((d: any) => setRows(d.records || []))
      .catch((e: any) => message.error(e.message))
      .finally(() => setLoading(false))
  }

  useEffect(() => { load() }, [])

  const openAdd = () => {
    setEditing(null)
    form.resetFields()
    form.setFieldsValue({ status: 1, sortOrder: 0, priceCents: 0 })
    setModalOpen(true)
  }

  const openEdit = (r: any) => {
    setEditing(r)
    form.setFieldsValue({
      id: r.id,
      productCode: r.productCode,
      productType: r.productType,
      titleKey: r.titleKey,
      priceCents: r.priceCents,
      metadataJson: r.metadataJson ? JSON.stringify(r.metadataJson, null, 2) : '{}',
      sortOrder: r.sortOrder,
      status: r.status,
    })
    setModalOpen(true)
  }

  const handleOk = async () => {
    try {
      const v = await form.validateFields()
      setSaving(true)
      let metadataJson = {}
      try {
        metadataJson = v.metadataJson ? JSON.parse(v.metadataJson) : {}
      } catch {
        message.error('metadata JSON 格式不正确')
        return
      }
      await api.saveCommerceProduct({ ...v, metadataJson })
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

  const handleGrant = async () => {
    try {
      const v = await grantForm.validateFields()
      setSaving(true)
      await api.grantCommerce({ userId: Number(v.userId), productId: Number(v.productId) })
      message.success('权益已发放')
      setGrantOpen(false)
      grantForm.resetFields()
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
        <h2 className="page-title">商业商品</h2>
        <Space>
          <Button onClick={() => { grantForm.resetFields(); setGrantOpen(true) }}>手动发放</Button>
          <Button type="primary" icon={<PlusOutlined />} onClick={openAdd}>新增商品</Button>
        </Space>
      </div>
      <Table
        rowKey="id"
        loading={loading}
        dataSource={rows}
        size="middle"
        columns={[
          { title: 'ID', dataIndex: 'id', width: 72 },
          { title: '编码', dataIndex: 'productCode' },
          { title: '类型', dataIndex: 'productType', width: 100 },
          { title: '标题 Key', dataIndex: 'titleKey', ellipsis: true },
          { title: '价格(分)', dataIndex: 'priceCents', width: 100 },
          { title: '排序', dataIndex: 'sortOrder', width: 72 },
          { title: '状态', dataIndex: 'status', width: 72 },
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
        title={editing ? '编辑商品' : '新增商品'}
        open={modalOpen}
        onOk={handleOk}
        onCancel={() => { setModalOpen(false); form.resetFields() }}
        confirmLoading={saving}
        destroyOnClose
        width={560}
      >
        <Form form={form} layout="vertical" style={{ marginTop: 16 }}>
          <Form.Item name="id" hidden><Input /></Form.Item>
          <Form.Item name="productCode" label="商品编码" rules={[{ required: true }]}>
            <Input placeholder="skin.vintage" />
          </Form.Item>
          <Form.Item name="productType" label="类型" rules={[{ required: true }]}>
            <Input placeholder="skin|font|template|export|vip_bundle" />
          </Form.Item>
          <Form.Item name="titleKey" label="标题 i18n key" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="priceCents" label="价格（分）">
            <InputNumber min={0} style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item name="sortOrder" label="排序">
            <InputNumber style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item name="status" label="状态（1=上架）">
            <InputNumber min={0} max={1} style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item name="metadataJson" label="metadata JSON">
            <Input.TextArea rows={4} placeholder='{"skinId":"vintage"}' />
          </Form.Item>
        </Form>
      </Modal>
      <Modal
        title="手动发放权益"
        open={grantOpen}
        onOk={handleGrant}
        onCancel={() => { setGrantOpen(false); grantForm.resetFields() }}
        confirmLoading={saving}
        destroyOnClose
        width={400}
      >
        <Form form={grantForm} layout="vertical" style={{ marginTop: 16 }}>
          <Form.Item name="userId" label="用户 ID" rules={[{ required: true }]}>
            <InputNumber min={1} style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item name="productId" label="商品 ID" rules={[{ required: true }]}>
            <InputNumber min={1} style={{ width: '100%' }} />
          </Form.Item>
        </Form>
      </Modal>
    </>
  )
}
