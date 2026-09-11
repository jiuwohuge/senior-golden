import { MinusCircleOutlined, PlusOutlined } from '@ant-design/icons'
import { Button, Col, Form, Input, InputNumber, Modal, Select, Space, Tag, message } from 'antd'
import type { ColumnsType } from 'antd/es/table'
import { useCallback, useEffect, useMemo, useState } from 'react'
import AdminProTable, { FILTER_COL_SHORT } from '../../components/admin/AdminProTable'
import EnumSelect, { PRODUCT_STATUS_OPTIONS, PRODUCT_TYPE_OPTIONS } from '../../components/admin/EnumSelect'
import { api } from '../../services/api'

type ChannelRow = {
  id?: number
  provider?: string
  storeProductId?: string
  basePlanId?: string
  offerId?: string
  appIdOrPackageName?: string
  environment?: string
  status?: number
  providerConfigJson?: unknown
}

type ProductRow = {
  id: number
  productCode?: string
  productType?: string
  entitlementCode?: string
  titleKey?: string
  priceCents?: number
  sortOrder?: number
  status?: number
  metadataJson?: unknown
  channels?: ChannelRow[]
}

const PROVIDER_OPTIONS = [
  { value: 'google_play', label: 'Google Play' },
  { value: 'apple_app_store', label: 'Apple' },
  { value: 'mock', label: 'Mock' },
]

const ENV_OPTIONS = [
  { value: 'sandbox', label: 'sandbox' },
  { value: 'production', label: 'production' },
]

/** 商业商品列表：分页筛选、渠道字段、批量上下架、CRUD */
export default function CommerceProductList() {
  const [rows, setRows] = useState<ProductRow[]>([])
  const [total, setTotal] = useState(0)
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(20)
  const [loading, setLoading] = useState(false)
  const [selectedIds, setSelectedIds] = useState<number[]>([])
  const [modalOpen, setModalOpen] = useState(false)
  const [grantOpen, setGrantOpen] = useState(false)
  const [editing, setEditing] = useState<ProductRow | null>(null)
  const [saving, setSaving] = useState(false)
  const [filterForm] = Form.useForm()
  const [form] = Form.useForm()
  const [grantForm] = Form.useForm()

  const load = useCallback(
    async (p = page, ps = pageSize) => {
      setLoading(true)
      try {
        const f = filterForm.getFieldsValue()
        const d: any = await api.commerceProducts({
          page: { page: p, size: ps },
          productType: f.productType || undefined,
          status: f.status,
        })
        setRows(d.records || [])
        setTotal(Number(d.total) || 0)
        setPage(Number(d.page) || p)
        setPageSize(Number(d.size) || ps)
        setSelectedIds([])
      } catch (e: any) {
        console.error('commerceProducts failed', e?.message)
        message.error(e.message)
      } finally {
        setLoading(false)
      }
    },
    [filterForm, page, pageSize],
  )

  useEffect(() => {
    void load(1, pageSize)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  const openAdd = () => {
    setEditing(null)
    form.resetFields()
    form.setFieldsValue({
      status: 1,
      sortOrder: 0,
      priceCents: 0,
      channels: [],
    })
    setModalOpen(true)
  }

  const openEdit = (r: ProductRow) => {
    setEditing(r)
    form.setFieldsValue({
      id: r.id,
      productCode: r.productCode,
      productType: r.productType,
      entitlementCode: r.entitlementCode,
      titleKey: r.titleKey,
      priceCents: r.priceCents,
      metadataJson: r.metadataJson ? JSON.stringify(r.metadataJson, null, 2) : '{}',
      sortOrder: r.sortOrder,
      status: r.status,
      channels: (r.channels || []).map((c) => ({
        ...c,
        providerConfigJson:
          c.providerConfigJson == null
            ? ''
            : typeof c.providerConfigJson === 'string'
              ? c.providerConfigJson
              : JSON.stringify(c.providerConfigJson, null, 2),
      })),
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
      const channels = (v.channels || []).map((c: any) => {
        let providerConfigJson: unknown = c.providerConfigJson
        if (typeof providerConfigJson === 'string') {
          const s = providerConfigJson.trim()
          if (!s) providerConfigJson = null
          else {
            try {
              providerConfigJson = JSON.parse(s)
            } catch {
              providerConfigJson = s
            }
          }
        }
        return { ...c, providerConfigJson }
      })
      await api.saveCommerceProduct({ ...v, metadataJson, channels })
      setModalOpen(false)
      form.resetFields()
      void load()
    } catch (e: any) {
      if (e?.errorFields) return
      console.error('saveCommerceProduct failed', e?.message)
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
      console.error('grantCommerce failed', e?.message)
      message.error(e.message)
    } finally {
      setSaving(false)
    }
  }

  const batchStatus = async (status: number) => {
    if (!selectedIds.length) {
      message.warning('请先勾选商品')
      return
    }
    try {
      await api.commerceBatchStatus(selectedIds, status)
      message.success(status === 1 ? '已批量上架' : '已批量下架')
      void load()
    } catch (e: any) {
      console.error('commerceBatchStatus failed', e?.message)
      message.error(e.message)
    }
  }

  const columns: ColumnsType<ProductRow> = useMemo(
    () => [
      { title: 'ID', dataIndex: 'id', width: 72 },
      { title: '编码', dataIndex: 'productCode', ellipsis: true },
      {
        title: '类型',
        dataIndex: 'productType',
        width: 110,
        render: (v: string) => PRODUCT_TYPE_OPTIONS.find((o) => o.value === v)?.label ?? v,
      },
      { title: '权益', dataIndex: 'entitlementCode', width: 90, ellipsis: true },
      { title: '标题 Key', dataIndex: 'titleKey', ellipsis: true },
      { title: '价格(分)', dataIndex: 'priceCents', width: 100 },
      {
        title: '渠道',
        dataIndex: 'channels',
        width: 220,
        render: (chs: ChannelRow[] | undefined) => {
          if (!chs?.length) return '-'
          return chs.map((c) => `${c.provider}:${c.storeProductId || ''}`).join(' | ')
        },
      },
      { title: '排序', dataIndex: 'sortOrder', width: 72 },
      {
        title: '状态',
        dataIndex: 'status',
        width: 80,
        render: (v: number) => (
          <Tag color={v === 1 ? 'green' : 'default'}>
            {PRODUCT_STATUS_OPTIONS.find((o) => o.value === v)?.label ?? v}
          </Tag>
        ),
      },
      {
        title: '操作',
        width: 100,
        fixed: 'right',
        render: (_, r) => (
          <Button size="small" onClick={() => openEdit(r)}>
            编辑
          </Button>
        ),
      },
    ],
    [],
  )

  const filterItems = (
    <>
      <Col {...FILTER_COL_SHORT}>
        <Form.Item name="productType" label="商品类型">
          <EnumSelect options={PRODUCT_TYPE_OPTIONS} placeholder="全部" />
        </Form.Item>
      </Col>
      <Col {...FILTER_COL_SHORT}>
        <Form.Item name="status" label="状态">
          <EnumSelect options={PRODUCT_STATUS_OPTIONS} placeholder="全部" />
        </Form.Item>
      </Col>
    </>
  )

  return (
    <>
      <div className="page-header">
        <h2 className="page-title">商业商品</h2>
      </div>
      <AdminProTable<ProductRow>
        filterForm={filterForm}
        filterItems={filterItems}
        onSearch={() => void load(1, pageSize)}
        toolbar={
          <Space wrap>
            <Button type="primary" disabled={!selectedIds.length} onClick={() => void batchStatus(1)}>
              批量上架
            </Button>
            <Button disabled={!selectedIds.length} onClick={() => void batchStatus(0)}>
              批量下架
            </Button>
            <Button
              onClick={() => {
                grantForm.resetFields()
                setGrantOpen(true)
              }}
            >
              手动发放
            </Button>
            <Button type="primary" icon={<PlusOutlined />} onClick={openAdd}>
              新增商品
            </Button>
            <Button onClick={() => void load()}>刷新</Button>
          </Space>
        }
        columns={columns}
        dataSource={rows}
        loading={loading}
        total={total}
        page={page}
        pageSize={pageSize}
        onPageChange={(p, ps) => void load(p, ps)}
        rowSelection={{
          selectedRowKeys: selectedIds,
          onChange: (keys) => setSelectedIds(keys.map(Number)),
        }}
        scrollX={1200}
      />

      <Modal
        title={editing ? '编辑商品' : '新增商品'}
        open={modalOpen}
        onOk={handleOk}
        onCancel={() => {
          setModalOpen(false)
          form.resetFields()
        }}
        confirmLoading={saving}
        destroyOnClose
        width={720}
      >
        <Form form={form} layout="vertical" style={{ marginTop: 16 }}>
          <Form.Item name="id" hidden>
            <Input />
          </Form.Item>
          <Form.Item name="productCode" label="商品编码" rules={[{ required: true }]}>
            <Input placeholder="plus.monthly / skin.vintage" />
          </Form.Item>
          <Form.Item name="productType" label="类型" rules={[{ required: true }]}>
            <EnumSelect options={PRODUCT_TYPE_OPTIONS} allowClear={false} />
          </Form.Item>
          <Form.Item name="entitlementCode" label="权益编码">
            <Input placeholder="plus" />
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
          <Form.Item name="status" label="状态">
            <EnumSelect options={PRODUCT_STATUS_OPTIONS} allowClear={false} />
          </Form.Item>
          <Form.Item name="metadataJson" label="metadata JSON">
            <Input.TextArea rows={3} placeholder='{"skinId":"vintage"}' />
          </Form.Item>

          <Form.List name="channels">
            {(fields, { add, remove }) => (
              <div>
                <div style={{ marginBottom: 8, fontWeight: 600 }}>渠道配置（Play / Mock）</div>
                {fields.map((field) => (
                  <Space key={field.key} align="start" style={{ display: 'flex', marginBottom: 8 }} wrap>
                    <Form.Item name={[field.name, 'id']} hidden>
                      <Input />
                    </Form.Item>
                    <Form.Item
                      name={[field.name, 'provider']}
                      rules={[{ required: true, message: 'provider' }]}
                      style={{ width: 140 }}
                    >
                      <Select options={PROVIDER_OPTIONS} placeholder="provider" />
                    </Form.Item>
                    <Form.Item
                      name={[field.name, 'storeProductId']}
                      rules={[{ required: true, message: 'store id' }]}
                      style={{ width: 160 }}
                    >
                      <Input placeholder="store_product_id" />
                    </Form.Item>
                    <Form.Item name={[field.name, 'basePlanId']} style={{ width: 120 }}>
                      <Input placeholder="base_plan" />
                    </Form.Item>
                    <Form.Item name={[field.name, 'offerId']} style={{ width: 100 }}>
                      <Input placeholder="offer" />
                    </Form.Item>
                    <Form.Item name={[field.name, 'appIdOrPackageName']} style={{ width: 180 }}>
                      <Input placeholder="package name" />
                    </Form.Item>
                    <Form.Item
                      name={[field.name, 'environment']}
                      rules={[{ required: true, message: 'env' }]}
                      style={{ width: 120 }}
                    >
                      <Select options={ENV_OPTIONS} placeholder="env" />
                    </Form.Item>
                    <Form.Item name={[field.name, 'status']} initialValue={1} style={{ width: 90 }}>
                      <Select
                        options={[
                          { value: 1, label: '启用' },
                          { value: 0, label: '停用' },
                        ]}
                      />
                    </Form.Item>
                    <Form.Item name={[field.name, 'providerConfigJson']} style={{ width: 200 }}>
                      <Input.TextArea rows={1} placeholder="provider_config JSON" />
                    </Form.Item>
                    <MinusCircleOutlined onClick={() => remove(field.name)} style={{ marginTop: 8 }} />
                  </Space>
                ))}
                <Button type="dashed" onClick={() => add({ environment: 'sandbox', status: 1 })} block icon={<PlusOutlined />}>
                  添加渠道
                </Button>
              </div>
            )}
          </Form.List>
        </Form>
      </Modal>
      <Modal
        title="手动发放权益"
        open={grantOpen}
        onOk={handleGrant}
        onCancel={() => {
          setGrantOpen(false)
          grantForm.resetFields()
        }}
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
