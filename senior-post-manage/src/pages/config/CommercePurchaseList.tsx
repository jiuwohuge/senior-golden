import { Button, Col, DatePicker, Drawer, Form, Input, InputNumber, Modal, Space, Table, Tag, Timeline, message } from 'antd'
import type { ColumnsType } from 'antd/es/table'
import dayjs from 'dayjs'
import { useCallback, useEffect, useMemo, useState } from 'react'
import AdminProTable, { FILTER_COL_SHORT } from '../../components/admin/AdminProTable'
import EnumSelect from '../../components/admin/EnumSelect'
import { api } from '../../services/api'

type PurchaseRow = {
  id: number
  purchaseNo?: string
  userId?: number
  productId?: number
  productCode?: string
  provider?: string
  storeProductId?: string
  purchaseTokenPreview?: string
  externalOrderId?: string
  status?: string
  purchasedAt?: string
  paidAt?: string
  environment?: string
  createdAt?: string
}

const PURCHASE_STATUS_OPTIONS = [
  { value: 'pending', label: 'pending' },
  { value: 'purchased', label: 'purchased' },
  { value: 'canceled', label: 'canceled' },
  { value: 'refunded', label: 'refunded' },
  { value: 'revoked', label: 'revoked' },
]

/** 购买记录只读：筛选、详情时间线、webhook、可选强制同步（不退款） */
export default function CommercePurchaseList() {
  const [rows, setRows] = useState<PurchaseRow[]>([])
  const [total, setTotal] = useState(0)
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(20)
  const [loading, setLoading] = useState(false)
  const [detailOpen, setDetailOpen] = useState(false)
  const [detailLoading, setDetailLoading] = useState(false)
  const [detail, setDetail] = useState<any>(null)
  const [syncing, setSyncing] = useState(false)
  const [filterForm] = Form.useForm()

  /** 分页加载购买记录 */
  const load = useCallback(
    async (p = page, ps = pageSize) => {
      setLoading(true)
      try {
        const f = filterForm.getFieldsValue()
        const range = f.purchasedRange as [dayjs.Dayjs, dayjs.Dayjs] | undefined
        const d: any = await api.commercePurchasesPaging({
          page: { page: p, size: ps },
          userId: f.userId ? Number(f.userId) : undefined,
          purchaseNo: f.purchaseNo || undefined,
          productCode: f.productCode || undefined,
          productId: f.productId ? Number(f.productId) : undefined,
          status: f.status || undefined,
          purchasedAtFrom: range?.[0]?.format?.('YYYY-MM-DDTHH:mm:ss') || undefined,
          purchasedAtTo: range?.[1]?.format?.('YYYY-MM-DDTHH:mm:ss') || undefined,
        })
        setRows(d.records || [])
        setTotal(Number(d.total) || 0)
        setPage(Number(d.page) || p)
        setPageSize(Number(d.size) || ps)
      } catch (e: any) {
        console.error('commercePurchasesPaging failed', e?.message)
        message.error(e.message || '加载失败')
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

  /** 打开详情抽屉 */
  const openDetail = async (id: number) => {
    setDetailOpen(true)
    setDetailLoading(true)
    setDetail(null)
    try {
      const d = await api.commercePurchaseDetail({ purchaseId: id })
      setDetail(d)
    } catch (e: any) {
      message.error(e.message || '详情加载失败')
    } finally {
      setDetailLoading(false)
    }
  }

  /** 确认后强制同步（仅重查，不退款） */
  const forceSync = () => {
    if (!detail?.purchase?.id) return
    Modal.confirm({
      title: '强制同步',
      content: '将用已存密文（仅 mock）重查渠道状态，不会发起退款。确认继续？',
      onOk: async () => {
        setSyncing(true)
        try {
          const r: any = await api.commercePurchaseForceSync({ purchaseId: detail.purchase.id })
          if (r?.synced) {
            message.success(r.message || '已同步')
            await openDetail(detail.purchase.id)
            return
          }
          message.warning(r?.message || '无法同步')
        } catch (e: any) {
          message.error(e.message || '同步失败')
        } finally {
          setSyncing(false)
        }
      },
    })
  }

  const columns: ColumnsType<PurchaseRow> = useMemo(
    () => [
      { title: 'ID', dataIndex: 'id', width: 72 },
      { title: '购买号', dataIndex: 'purchaseNo', width: 160, ellipsis: true },
      { title: '用户', dataIndex: 'userId', width: 90 },
      {
        title: '商品',
        width: 160,
        ellipsis: true,
        render: (_, r) => r.productCode || r.productId || '-',
      },
      { title: '渠道', dataIndex: 'provider', width: 110 },
      { title: '商店SKU', dataIndex: 'storeProductId', width: 140, ellipsis: true },
      {
        title: 'Token预览',
        dataIndex: 'purchaseTokenPreview',
        width: 120,
        render: (v: string) => <code>{v || '-'}</code>,
      },
      {
        title: '状态',
        dataIndex: 'status',
        width: 100,
        render: (v: string) => <Tag>{v}</Tag>,
      },
      { title: '购买时间', dataIndex: 'purchasedAt', width: 170 },
      {
        title: '操作',
        width: 90,
        fixed: 'right',
        render: (_, r) => (
          <Button size="small" onClick={() => void openDetail(r.id)}>
            详情
          </Button>
        ),
      },
    ],
    [],
  )

  const filterItems = (
    <>
      <Col {...FILTER_COL_SHORT}>
        <Form.Item name="userId" label="用户ID">
          <InputNumber style={{ width: '100%' }} min={1} />
        </Form.Item>
      </Col>
      <Col {...FILTER_COL_SHORT}>
        <Form.Item name="purchaseNo" label="购买号">
          <Input allowClear />
        </Form.Item>
      </Col>
      <Col {...FILTER_COL_SHORT}>
        <Form.Item name="productId" label="商品ID">
          <InputNumber style={{ width: '100%' }} min={1} />
        </Form.Item>
      </Col>
      <Col {...FILTER_COL_SHORT}>
        <Form.Item name="productCode" label="商品编码">
          <Input allowClear />
        </Form.Item>
      </Col>
      <Col {...FILTER_COL_SHORT}>
        <Form.Item name="status" label="状态">
          <EnumSelect options={PURCHASE_STATUS_OPTIONS} placeholder="全部" />
        </Form.Item>
      </Col>
      <Col {...FILTER_COL_SHORT}>
        <Form.Item name="purchasedRange" label="购买时间">
          <DatePicker.RangePicker showTime style={{ width: '100%' }} />
        </Form.Item>
      </Col>
    </>
  )

  const p = detail?.purchase
  const sub = detail?.subscription

  return (
    <>
      <div className="page-header">
        <h2 className="page-title">购买记录</h2>
      </div>
      <AdminProTable<PurchaseRow>
        filterForm={filterForm}
        filterItems={filterItems}
        onSearch={() => void load(1, pageSize)}
        toolbar={
          <Space>
            <Button onClick={() => void load()}>刷新</Button>
          </Space>
        }
        columns={columns}
        dataSource={rows}
        loading={loading}
        total={total}
        page={page}
        pageSize={pageSize}
        onPageChange={(pg, ps) => void load(pg, ps)}
        scrollX={1400}
      />

      <Drawer
        title={p ? `购买详情 #${p.id}` : '购买详情'}
        open={detailOpen}
        width={720}
        onClose={() => setDetailOpen(false)}
        extra={
          <Button loading={syncing} onClick={forceSync}>
            强制同步
          </Button>
        }
      >
        {detailLoading && <div>加载中…</div>}
        {!detailLoading && detail && (
          <Space direction="vertical" size="large" style={{ width: '100%' }}>
            <div>
              <h3>主单</h3>
              <p>购买号：{p?.purchaseNo}</p>
              <p>
                用户：{p?.userId} / 商品：{p?.productCode} ({p?.productId})
              </p>
              <p>
                渠道：{p?.provider} / {p?.storeProductId} / {p?.environment}
              </p>
              <p>
                Token 预览：<code>{p?.purchaseTokenPreview || '-'}</code>
              </p>
              <p>
                状态：<Tag>{p?.status}</Tag> 购买时间：{p?.purchasedAt || '-'}
              </p>
            </div>
            <div>
              <h3>订阅</h3>
              {sub ? (
                <p>
                  #{sub.id} <Tag>{sub.status || '-'}</Tag>
                  周期：{sub.currentPeriodStart || '-'} ~ {sub.currentPeriodEnd || '-'} /
                  autoRenew={String(sub.autoRenew)} / 最近同步={sub.lastSyncedAt || '-'}
                </p>
              ) : (
                <p>无关联订阅</p>
              )}
            </div>
            <div>
              <h3>权益</h3>
              <Table
                size="small"
                rowKey="entitlementId"
                pagination={false}
                dataSource={detail.entitlements || []}
                columns={[
                  { title: 'ID', dataIndex: 'entitlementId', width: 70 },
                  { title: '商品', dataIndex: 'productCode', ellipsis: true },
                  { title: '来源', dataIndex: 'source', width: 120 },
                  { title: '到期', dataIndex: 'expiresAt', width: 170 },
                ]}
              />
            </div>
            <div>
              <h3>时间线</h3>
              <Timeline
                items={(detail.timeline || []).map((t: any) => ({
                  children: (
                    <div>
                      <div>
                        <b>{t.title}</b> <Tag>{t.kind}</Tag>
                      </div>
                      <div>{t.detail}</div>
                      <div style={{ color: '#888' }}>{t.at}</div>
                    </div>
                  ),
                }))}
              />
            </div>
            <div>
              <h3>Webhook 事件</h3>
              <Table
                size="small"
                rowKey="id"
                pagination={false}
                dataSource={detail.webhooks || []}
                columns={[
                  { title: 'ID', dataIndex: 'id', width: 70 },
                  { title: '类型', dataIndex: 'eventType', ellipsis: true },
                  { title: '处理', dataIndex: 'processStatus', width: 100 },
                  { title: '错误', dataIndex: 'errorMessage', ellipsis: true },
                  { title: '收到', dataIndex: 'receivedAt', width: 170 },
                  {
                    title: 'Payload',
                    dataIndex: 'payloadMasked',
                    ellipsis: true,
                    render: (v: string) => (v ? <code style={{ fontSize: 11 }}>{v}</code> : '-'),
                  },
                ]}
              />
            </div>
          </Space>
        )}
      </Drawer>
    </>
  )
}
