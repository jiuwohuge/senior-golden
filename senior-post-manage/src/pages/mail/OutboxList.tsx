import { Button, Col, Drawer, Form, Input, Space, Tag, Typography, message } from 'antd'
import type { ColumnsType } from 'antd/es/table'
import { useCallback, useEffect, useMemo, useState } from 'react'
import AdminProTable, { FILTER_COL_SHORT, FILTER_COL_TEXT } from '../../components/admin/AdminProTable'
import EnumSelect, { MAIL_OUTBOX_STATUS_OPTIONS } from '../../components/admin/EnumSelect'
import { api } from '../../services/api'

const { Paragraph, Text } = Typography

type OutboxRow = {
  id: number
  mailType?: string
  toEmail?: string
  payloadJson?: string
  localeTag?: string
  status?: string
  attempts?: number
  nextRetryAt?: string
  lastError?: string
  createdAt?: string
  updatedAt?: string
}

const STATUS_COLOR: Record<string, string> = {
  pending: 'gold',
  sending: 'processing',
  sent: 'green',
  failed: 'red',
}

function statusLabel(v?: string) {
  return MAIL_OUTBOX_STATUS_OPTIONS.find((o) => o.value === v)?.label ?? v ?? '—'
}

/** 系统邮件出站列表：筛选、详情预览与失败重试。 */
export default function OutboxList() {
  const [rows, setRows] = useState<OutboxRow[]>([])
  const [total, setTotal] = useState(0)
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(20)
  const [loading, setLoading] = useState(false)
  const [detail, setDetail] = useState<OutboxRow | null>(null)
  const [detailLoading, setDetailLoading] = useState(false)
  const [filterForm] = Form.useForm()

  const load = useCallback(
    async (p = page, ps = pageSize) => {
      setLoading(true)
      try {
        const f = filterForm.getFieldsValue()
        const d: any = await api.mailOutboxPaging({
          page: { page: p, size: ps },
          toEmail: f.toEmail?.trim() || undefined,
          mailType: f.mailType?.trim() || undefined,
          status: f.status || undefined,
          keyword: f.keyword?.trim() || undefined,
        })
        setRows(d.records || [])
        setTotal(Number(d.total) || 0)
        setPage(Number(d.page) || p)
        setPageSize(Number(d.size) || ps)
      } catch (e: any) {
        console.error('mailOutboxPaging failed', e?.message)
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

  const openDetail = async (id: number) => {
    setDetailLoading(true)
    setDetail({ id })
    try {
      const d: any = await api.mailOutboxDetail(id)
      setDetail(d)
    } catch (e: any) {
      console.error('mailOutboxDetail failed', e?.message)
      message.error(e.message || '加载详情失败')
      setDetail(null)
    } finally {
      setDetailLoading(false)
    }
  }

  const doRetry = async (id: number) => {
    try {
      await api.mailOutboxRetry(id)
      message.success('已重置为待发送')
      void load()
      if (detail?.id === id) void openDetail(id)
    } catch (e: any) {
      console.error('mailOutboxRetry failed', e?.message)
      message.error(e.message)
    }
  }

  const columns: ColumnsType<OutboxRow> = useMemo(
    () => [
      { title: 'ID', dataIndex: 'id', width: 72 },
      { title: '类型', dataIndex: 'mailType', width: 140, ellipsis: true },
      { title: '收件邮箱', dataIndex: 'toEmail', ellipsis: true },
      {
        title: '状态',
        dataIndex: 'status',
        width: 100,
        render: (v: string) => <Tag color={STATUS_COLOR[v] ?? 'default'}>{statusLabel(v)}</Tag>,
      },
      { title: '尝试次数', dataIndex: 'attempts', width: 88 },
      { title: '创建时间', dataIndex: 'createdAt', width: 170 },
      {
        title: '操作',
        fixed: 'right',
        width: 160,
        render: (_, r) => (
          <Space wrap size={[4, 4]}>
            <Button size="small" onClick={() => void openDetail(r.id)}>
              详情
            </Button>
            {r.status === 'failed' ? (
              <Button size="small" type="primary" onClick={() => void doRetry(r.id)}>
                重试
              </Button>
            ) : null}
          </Space>
        ),
      },
    ],
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [],
  )

  const filterItems = (
    <>
      <Col {...FILTER_COL_TEXT}>
        <Form.Item name="toEmail" label="收件邮箱">
          <Input allowClear placeholder="模糊搜索" />
        </Form.Item>
      </Col>
      <Col {...FILTER_COL_SHORT}>
        <Form.Item name="mailType" label="邮件类型">
          <Input allowClear placeholder="如 verify_code" />
        </Form.Item>
      </Col>
      <Col {...FILTER_COL_SHORT}>
        <Form.Item name="status" label="状态">
          <EnumSelect options={MAIL_OUTBOX_STATUS_OPTIONS} placeholder="全部" />
        </Form.Item>
      </Col>
      <Col {...FILTER_COL_TEXT}>
        <Form.Item name="keyword" label="关键词">
          <Input allowClear placeholder="payload / 邮箱" />
        </Form.Item>
      </Col>
    </>
  )

  let payloadPretty = detail?.payloadJson ?? ''
  if (payloadPretty) {
    try {
      payloadPretty = JSON.stringify(JSON.parse(payloadPretty), null, 2)
    } catch {
      // keep raw
    }
  }

  return (
    <div>
      <div className="page-header">
        <h2 className="page-title">出站邮件</h2>
      </div>
      <AdminProTable<OutboxRow>
        filterForm={filterForm}
        filterItems={filterItems}
        onSearch={() => void load(1, pageSize)}
        toolbar={
          <Button onClick={() => void load()}>刷新</Button>
        }
        columns={columns}
        dataSource={rows}
        loading={loading}
        total={total}
        page={page}
        pageSize={pageSize}
        onPageChange={(p, ps) => void load(p, ps)}
        scrollX={1000}
      />

      <Drawer
        title={detail ? `出站邮件 #${detail.id}` : '详情'}
        open={!!detail}
        width={560}
        onClose={() => setDetail(null)}
        extra={
          detail?.status === 'failed' ? (
            <Button type="primary" onClick={() => void doRetry(detail.id)}>
              重试
            </Button>
          ) : null
        }
      >
        {detailLoading ? (
          <Text type="secondary">加载中…</Text>
        ) : detail ? (
          <>
            <p>
              <Text type="secondary">类型</Text> {detail.mailType}
            </p>
            <p>
              <Text type="secondary">收件邮箱</Text> {detail.toEmail}
            </p>
            <p>
              <Text type="secondary">状态</Text>{' '}
              <Tag color={STATUS_COLOR[detail.status ?? ''] ?? 'default'}>
                {statusLabel(detail.status)}
              </Tag>
            </p>
            <p>
              <Text type="secondary">尝试次数</Text> {detail.attempts ?? 0}
            </p>
            <p>
              <Text type="secondary">下次重试</Text> {detail.nextRetryAt ?? '—'}
            </p>
            <p>
              <Text type="secondary">语言</Text> {detail.localeTag ?? '—'}
            </p>
            <p>
              <Text type="secondary">创建 / 更新</Text> {detail.createdAt ?? '—'} / {detail.updatedAt ?? '—'}
            </p>
            {detail.lastError ? (
              <Paragraph type="danger">错误：{detail.lastError}</Paragraph>
            ) : null}
            <Text type="secondary">Payload</Text>
            <pre
              style={{
                marginTop: 8,
                padding: 12,
                background: '#f5f5f5',
                borderRadius: 8,
                maxHeight: 360,
                overflow: 'auto',
                fontSize: 12,
              }}
            >
              {payloadPretty || '—'}
            </pre>
          </>
        ) : null}
      </Drawer>
    </div>
  )
}
