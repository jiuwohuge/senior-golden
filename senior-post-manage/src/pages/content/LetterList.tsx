import { Button, Col, Drawer, Form, Input, InputNumber, Space, Tag, Typography, message } from 'antd'
import type { ColumnsType } from 'antd/es/table'
import { useCallback, useEffect, useMemo, useState } from 'react'
import AdminProTable, { FILTER_COL_SHORT, FILTER_COL_TEXT } from '../../components/admin/AdminProTable'
import EnumSelect, {
  LETTER_AUDIT_OPTIONS,
  LETTER_MODE_OPTIONS,
  LETTER_STATUS_OPTIONS,
  labelOf,
} from '../../components/admin/EnumSelect'
import UserCell, { useUserBriefs } from '../../components/admin/UserCell'
import { api } from '../../services/api'

const { Paragraph, Text } = Typography

type LetterRow = {
  id: number
  fromUserId?: number
  toUserId?: number
  mode?: number
  status?: number
  auditStatus?: number
  content?: string
  expectedArrivalTime?: string
  actualArrivalTime?: string
  matchedAt?: string
  recipientReadAt?: string
  createdAt?: string
}

const AUDIT_COLOR: Record<number, string> = { 0: 'gold', 1: 'green', 2: 'red' }
const STATUS_COLOR: Record<number, string> = {
  0: 'default',
  1: 'processing',
  2: 'blue',
  3: 'cyan',
  4: 'purple',
  5: 'green',
  6: 'geekblue',
  7: 'default',
  8: 'orange',
}

/** 普通信件运营：审核、批量操作与正文预览。 */
export default function LetterList() {
  const [rows, setRows] = useState<LetterRow[]>([])
  const [total, setTotal] = useState(0)
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(20)
  const [loading, setLoading] = useState(false)
  const [selectedIds, setSelectedIds] = useState<number[]>([])
  const [preview, setPreview] = useState<LetterRow | null>(null)
  const [filterForm] = Form.useForm()
  const userIds = useMemo(
    () => rows.flatMap((r) => [r.fromUserId, r.toUserId]),
    [rows],
  )
  const { briefs, signed } = useUserBriefs(userIds)

  const load = useCallback(
    async (p = page, ps = pageSize) => {
      setLoading(true)
      try {
        const f = filterForm.getFieldsValue()
        const d: any = await api.letterAuditPaging({
          page: { page: p, size: ps },
          auditStatus: f.auditStatus,
          mode: f.mode,
          status: f.status,
          fromUserId: f.fromUserId,
          toUserId: f.toUserId,
          keyword: f.keyword?.trim() || undefined,
        })
        setRows(d.records || [])
        setTotal(Number(d.total) || 0)
        setPage(Number(d.page) || p)
        setPageSize(Number(d.size) || ps)
        setSelectedIds([])
      } catch (e: any) {
        console.error('letterAuditPaging failed', e?.message)
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

  const doApprove = async (id: number) => {
    try {
      await api.letterAuditApprove(id)
      message.success('已通过')
      void load()
    } catch (e: any) {
      console.error('letterAuditApprove failed', e?.message)
      message.error(e.message)
    }
  }

  const doReject = async (id: number) => {
    try {
      await api.letterAuditReject(id)
      message.success('已拒绝')
      void load()
    } catch (e: any) {
      console.error('letterAuditReject failed', e?.message)
      message.error(e.message)
    }
  }

  const batchApprove = async () => {
    if (!selectedIds.length) {
      message.warning('请先勾选信件')
      return
    }
    try {
      await api.letterAuditBatchApprove(selectedIds)
      message.success('批量通过完成')
      void load()
    } catch (e: any) {
      console.error('letterAuditBatchApprove failed', e?.message)
      message.error(e.message)
    }
  }

  const batchReject = async () => {
    if (!selectedIds.length) {
      message.warning('请先勾选信件')
      return
    }
    try {
      await api.letterAuditBatchReject(selectedIds)
      message.success('批量拒绝完成')
      void load()
    } catch (e: any) {
      console.error('letterAuditBatchReject failed', e?.message)
      message.error(e.message)
    }
  }

  const columns: ColumnsType<LetterRow> = useMemo(
    () => [
      { title: 'ID', dataIndex: 'id', width: 72 },
      {
        title: '发件人',
        dataIndex: 'fromUserId',
        width: 160,
        render: (id: number) => (
          <UserCell userId={id} brief={briefs[id]} signedUrl={signed[id]} />
        ),
      },
      {
        title: '收件人',
        dataIndex: 'toUserId',
        width: 160,
        render: (id: number) =>
          id ? <UserCell userId={id} brief={briefs[id]} signedUrl={signed[id]} /> : '—',
      },
      {
        title: '模式',
        dataIndex: 'mode',
        width: 110,
        render: (v: number) => labelOf(LETTER_MODE_OPTIONS, v),
      },
      {
        title: '状态',
        dataIndex: 'status',
        width: 110,
        render: (v: number) => (
          <Tag color={STATUS_COLOR[v] ?? 'default'}>{labelOf(LETTER_STATUS_OPTIONS, v)}</Tag>
        ),
      },
      {
        title: '审核',
        dataIndex: 'auditStatus',
        width: 88,
        render: (v: number) => (
          <Tag color={AUDIT_COLOR[v] ?? 'default'}>{labelOf(LETTER_AUDIT_OPTIONS, v)}</Tag>
        ),
      },
      {
        title: '正文预览',
        dataIndex: 'content',
        ellipsis: true,
        render: (t: string) => <Paragraph ellipsis={{ rows: 1 }} style={{ marginBottom: 0 }}>{t}</Paragraph>,
      },
      {
        title: '操作',
        fixed: 'right',
        width: 220,
        render: (_, r) => (
          <Space wrap size={[4, 4]}>
            <Button size="small" onClick={() => setPreview(r)}>
              详情
            </Button>
            <Button
              size="small"
              type="primary"
              disabled={r.auditStatus === 1}
              onClick={() => void doApprove(r.id)}
            >
              通过
            </Button>
            <Button
              size="small"
              danger
              disabled={r.auditStatus === 2}
              onClick={() => void doReject(r.id)}
            >
              拒绝
            </Button>
          </Space>
        ),
      },
    ],
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [briefs, signed],
  )

  const filterItems = (
    <>
      <Col {...FILTER_COL_SHORT}>
        <Form.Item name="auditStatus" label="审核状态">
          <EnumSelect options={LETTER_AUDIT_OPTIONS} placeholder="全部" />
        </Form.Item>
      </Col>
      <Col {...FILTER_COL_SHORT}>
        <Form.Item name="mode" label="模式">
          <EnumSelect options={LETTER_MODE_OPTIONS} placeholder="全部" />
        </Form.Item>
      </Col>
      <Col {...FILTER_COL_SHORT}>
        <Form.Item name="status" label="信件状态">
          <EnumSelect options={LETTER_STATUS_OPTIONS} placeholder="全部" />
        </Form.Item>
      </Col>
      <Col {...FILTER_COL_SHORT}>
        <Form.Item name="fromUserId" label="发件人">
          <InputNumber style={{ width: '100%' }} min={1} placeholder="用户 ID" />
        </Form.Item>
      </Col>
      <Col {...FILTER_COL_SHORT}>
        <Form.Item name="toUserId" label="收件人">
          <InputNumber style={{ width: '100%' }} min={1} placeholder="用户 ID" />
        </Form.Item>
      </Col>
      <Col {...FILTER_COL_TEXT}>
        <Form.Item name="keyword" label="关键词">
          <Input allowClear placeholder="正文模糊搜索" />
        </Form.Item>
      </Col>
    </>
  )

  return (
    <div>
      <div className="page-header">
        <h2 className="page-title">普通信件</h2>
      </div>
      <AdminProTable<LetterRow>
        filterForm={filterForm}
        filterItems={filterItems}
        onSearch={() => void load(1, pageSize)}
        toolbar={
          <Space wrap>
            <Button type="primary" disabled={!selectedIds.length} onClick={() => void batchApprove()}>
              批量通过
            </Button>
            <Button danger disabled={!selectedIds.length} onClick={() => void batchReject()}>
              批量拒绝
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
        scrollX={1100}
      />

      <Drawer
        title={preview ? `信件 #${preview.id}` : '信件详情'}
        open={!!preview}
        width={560}
        onClose={() => setPreview(null)}
      >
        {preview ? (
          <>
            <p>
              <Text type="secondary">发件人</Text> {preview.fromUserId}
            </p>
            <p>
              <Text type="secondary">收件人</Text> {preview.toUserId ?? '—'}
            </p>
            <p>
              <Text type="secondary">模式</Text> {labelOf(LETTER_MODE_OPTIONS, preview.mode)}
            </p>
            <p>
              <Text type="secondary">状态</Text>{' '}
              <Tag color={STATUS_COLOR[preview.status ?? -1] ?? 'default'}>
                {labelOf(LETTER_STATUS_OPTIONS, preview.status)}
              </Tag>
            </p>
            <p>
              <Text type="secondary">审核</Text>{' '}
              <Tag color={AUDIT_COLOR[preview.auditStatus ?? -1] ?? 'default'}>
                {labelOf(LETTER_AUDIT_OPTIONS, preview.auditStatus)}
              </Tag>
            </p>
            <p>
              <Text type="secondary">预计送达</Text> {String(preview.expectedArrivalTime ?? '—')}
            </p>
            <p>
              <Text type="secondary">实际送达</Text> {String(preview.actualArrivalTime ?? '—')}
            </p>
            <p>
              <Text type="secondary">匹配时间</Text> {preview.matchedAt ?? '—'}
            </p>
            <p>
              <Text type="secondary">已读时间</Text> {preview.recipientReadAt ?? '—'}
            </p>
            <p>
              <Text type="secondary">创建时间</Text> {preview.createdAt ?? '—'}
            </p>
            <Paragraph style={{ whiteSpace: 'pre-wrap', marginTop: 12 }}>{preview.content}</Paragraph>
            <Space style={{ marginTop: 16 }}>
              <Button
                type="primary"
                disabled={preview.auditStatus === 1}
                onClick={() => void doApprove(preview.id).then(() => setPreview(null))}
              >
                通过
              </Button>
              <Button
                danger
                disabled={preview.auditStatus === 2}
                onClick={() => void doReject(preview.id).then(() => setPreview(null))}
              >
                拒绝
              </Button>
            </Space>
          </>
        ) : null}
      </Drawer>
    </div>
  )
}
