import { Button, Drawer, Form, Input, Select, Space, Table, Tag, Typography, message } from 'antd'
import type { ColumnsType } from 'antd/es/table'
import { useCallback, useEffect, useMemo, useState } from 'react'
import UserCell, { useUserBriefs } from '../../components/admin/UserCell'
import { api } from '../../services/api'

const { Paragraph, Text } = Typography

type TimeLetterRow = {
  id: number
  senderId: number
  recipientId?: number | null
  recipientType?: number
  body: string
  deliveryDate?: string
  deliveryTz?: string
  status?: number
  stampCost?: number
  failReason?: string | null
  takedownReason?: string | null
}

const statusLabel: Record<number, { text: string; color: string }> = {
  1: { text: '草稿', color: 'default' },
  2: { text: '待发', color: 'gold' },
  3: { text: '已送达', color: 'blue' },
  4: { text: '已读', color: 'green' },
  5: { text: '已取消', color: 'default' },
  6: { text: '失败', color: 'red' },
}

export default function TimeLetterList() {
  const [rows, setRows] = useState<TimeLetterRow[]>([])
  const [total, setTotal] = useState(0)
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(20)
  const [statusFilter, setStatusFilter] = useState<number | undefined>()
  const [preview, setPreview] = useState<TimeLetterRow | null>(null)
  const [takedownTarget, setTakedownTarget] = useState<TimeLetterRow | null>(null)
  const [takedownForm] = Form.useForm<{ reason: string }>()
  const userIds = useMemo(
    () => rows.flatMap((r) => [r.senderId, r.recipientId]),
    [rows],
  )
  const { briefs, signed } = useUserBriefs(userIds)

  const load = useCallback(async () => {
    try {
      const d: any = await api.timeLetters({
        page: { page, size: pageSize },
        status: statusFilter,
      })
      setRows(d.records || [])
      setTotal(d.total ?? 0)
    } catch (e: any) {
      message.error(e?.message || '加载失败')
    }
  }, [page, pageSize, statusFilter])

  useEffect(() => {
    void load()
  }, [load])

  const columns: ColumnsType<TimeLetterRow> = useMemo(
    () => [
      { title: 'ID', dataIndex: 'id', width: 72 },
      {
        title: '发件人',
        width: 160,
        render: (_, r) => (
          <UserCell userId={r.senderId} brief={briefs[r.senderId]} signedUrl={signed[r.senderId]} />
        ),
      },
      {
        title: '收件人',
        width: 160,
        render: (_, r) =>
          r.recipientId != null ? (
            <UserCell
              userId={r.recipientId}
              brief={briefs[r.recipientId]}
              signedUrl={signed[r.recipientId]}
            />
          ) : (
            <Text type="secondary">自己</Text>
          ),
      },
      {
        title: '送达日',
        width: 120,
        render: (_, r) => (
          <span>
            {r.deliveryDate || '—'}
            {r.deliveryTz ? <Text type="secondary"> ({r.deliveryTz})</Text> : null}
          </span>
        ),
      },
      {
        title: '正文',
        dataIndex: 'body',
        ellipsis: true,
        render: (t: string) => <Paragraph ellipsis={{ rows: 2 }}>{t}</Paragraph>,
      },
      {
        title: '状态',
        width: 96,
        dataIndex: 'status',
        render: (v: number) => {
          const s = statusLabel[v] || { text: String(v), color: 'default' }
          return <Tag color={s.color}>{s.text}</Tag>
        },
      },
      {
        title: '操作',
        width: 180,
        fixed: 'right',
        render: (_, r) => (
          <Space wrap>
            <Button size="small" onClick={() => setPreview(r)}>
              查看
            </Button>
            {r.status !== 6 && !r.takedownReason ? (
              <Button size="small" danger onClick={() => setTakedownTarget(r)}>
                下架
              </Button>
            ) : null}
          </Space>
        ),
      },
    ],
    [briefs, signed],
  )

  return (
    <div>
      <div className="page-header">
        <h2 className="page-title">时光信</h2>
        <Select
          allowClear
          placeholder="状态"
          style={{ width: 140 }}
          value={statusFilter}
          onChange={(v) => {
            setPage(1)
            setStatusFilter(v)
          }}
          options={Object.entries(statusLabel).map(([k, v]) => ({
            value: Number(k),
            label: v.text,
          }))}
        />
      </div>
      <Table
        rowKey="id"
        dataSource={rows}
        columns={columns}
        scroll={{ x: 1100 }}
        pagination={{
          current: page,
          pageSize,
          total,
          showSizeChanger: true,
          onChange: (p, ps) => {
            setPage(p)
            setPageSize(ps)
          },
        }}
      />
      <Drawer open={!!preview} onClose={() => setPreview(null)} width={480} title="时光信详情">
        {preview && (
          <>
            <Paragraph>{preview.body}</Paragraph>
            {preview.failReason ? <Text type="danger">失败原因：{preview.failReason}</Text> : null}
            {preview.takedownReason ? (
              <Text type="warning">下架原因：{preview.takedownReason}</Text>
            ) : null}
          </>
        )}
      </Drawer>
      <Drawer
        open={!!takedownTarget}
        onClose={() => setTakedownTarget(null)}
        width={400}
        title="下架时光信"
        extra={
          <Button
            type="primary"
            danger
            onClick={async () => {
              const v = await takedownForm.validateFields()
              if (!takedownTarget) return
              try {
                await api.takedownTimeLetter(takedownTarget.id, v.reason)
                message.success('已下架')
                setTakedownTarget(null)
                takedownForm.resetFields()
                void load()
              } catch (e: any) {
                message.error(e.message)
              }
            }}
          >
            确认
          </Button>
        }
      >
        <Form form={takedownForm} layout="vertical">
          <Form.Item name="reason" label="原因" rules={[{ required: true, message: '请填写原因' }]}>
            <Input.TextArea rows={4} />
          </Form.Item>
        </Form>
      </Drawer>
    </div>
  )
}
