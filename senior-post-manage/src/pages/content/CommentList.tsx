import { Button, Drawer, Form, Image, Input, Select, Space, Table, Tag, Typography, message } from 'antd'
import type { ColumnsType } from 'antd/es/table'
import { useCallback, useEffect, useMemo, useState } from 'react'
import { api } from '../../services/api'

const { Paragraph, Text } = Typography

type CommentRow = {
  id: number
  postcardId: number
  userId: number
  content: string
  reviewStatus?: number
}

type PostcardDetail = {
  id: number
  userId: number
  content: string
  mainImageUrl?: string
  images?: string[] | null
  reviewStatus?: number
}

function normalizeImageList(p: PostcardDetail | null): string[] {
  if (!p) return []
  const fromArr = Array.isArray(p.images) ? p.images.filter(Boolean) : []
  if (fromArr.length) return fromArr
  if (p.mainImageUrl) return [p.mainImageUrl]
  return []
}

export default function CommentList() {
  const [rows, setRows] = useState<CommentRow[]>([])
  const [total, setTotal] = useState(0)
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(20)
  const [reviewFilter, setReviewFilter] = useState<number | undefined>(0)
  const [ctxOpen, setCtxOpen] = useState(false)
  const [ctxComment, setCtxComment] = useState<CommentRow | null>(null)
  const [ctxPostcard, setCtxPostcard] = useState<PostcardDetail | null>(null)
  const [ctxLoading, setCtxLoading] = useState(false)
  const [rejecting, setRejecting] = useState<CommentRow | null>(null)
  const [rejectForm] = Form.useForm<{ reason: string }>()

  const load = useCallback(async () => {
    try {
      const d: any = await api.comments({
        page: { page, size: pageSize },
        reviewStatus: reviewFilter,
      })
      setRows(d.records || [])
      setTotal(d.total ?? 0)
    } catch (e: any) {
      message.error(e?.message || '加载失败')
    }
  }, [page, pageSize, reviewFilter])

  useEffect(() => {
    void load()
  }, [load])

  const openContext = useCallback(async (c: CommentRow) => {
    setCtxComment(c)
    setCtxPostcard(null)
    setCtxOpen(true)
    setCtxLoading(true)
    try {
      const p: any = await api.postcardDetail(c.postcardId)
      setCtxPostcard(p as PostcardDetail)
    } catch (e: any) {
      message.error(e?.message || '加载原帖失败')
    } finally {
      setCtxLoading(false)
    }
  }, [])

  const columns: ColumnsType<CommentRow> = useMemo(
    () => [
      { title: 'ID', dataIndex: 'id', width: 72 },
      { title: 'Postcard', dataIndex: 'postcardId', width: 96 },
      { title: 'User', dataIndex: 'userId', width: 88 },
      {
        title: '正文',
        dataIndex: 'content',
        ellipsis: true,
        render: (t: string) => <Paragraph ellipsis={{ rows: 2 }}>{t}</Paragraph>,
      },
      {
        title: '审核',
        width: 88,
        dataIndex: 'reviewStatus',
        render: (v: number) => {
          if (v === 0) return <Tag color="gold">待审</Tag>
          if (v === 1) return <Tag color="green">通过</Tag>
          if (v === 2) return <Tag color="red">驳回</Tag>
          return <Tag>{String(v)}</Tag>
        },
      },
      {
        title: '操作',
        width: 260,
        fixed: 'right',
        render: (_, r) => (
          <Space wrap>
            <Button size="small" onClick={() => void openContext(r)}>
              原帖与配图
            </Button>
            <Button
              size="small"
              type="primary"
              disabled={r.reviewStatus === 1}
              onClick={async () => {
                await api.approveComment(r.id)
                message.success('已通过')
                void load()
              }}
            >
              通过
            </Button>
            <Button
              size="small"
              danger
              disabled={r.reviewStatus === 2}
              onClick={() => {
                setRejecting(r)
                rejectForm.setFieldsValue({ reason: '' })
              }}
            >
              驳回
            </Button>
          </Space>
        ),
      },
    ],
    [openContext, rejectForm],
  )

  const ctxUrls = normalizeImageList(ctxPostcard)

  return (
    <div style={{ padding: 16 }}>
      <Space style={{ marginBottom: 12 }} wrap>
        <span>审核状态：</span>
        <Select
          style={{ width: 160 }}
          value={reviewFilter === undefined ? 'all' : String(reviewFilter)}
          options={[
            { value: 'all', label: '全部' },
            { value: '0', label: '待审核' },
            { value: '1', label: '已通过' },
            { value: '2', label: '已驳回' },
          ]}
          onChange={(v) => {
            setPage(1)
            setReviewFilter(v === 'all' ? undefined : Number(v))
          }}
        />
        <Button onClick={() => void load()}>刷新</Button>
      </Space>

      <Table<CommentRow>
        rowKey="id"
        dataSource={rows}
        columns={columns}
        scroll={{ x: 960 }}
        pagination={{
          current: page,
          pageSize,
          total,
          showSizeChanger: true,
          onChange: (p, ps) => {
            setPage(p)
            setPageSize(ps || 20)
          },
        }}
      />

      <Drawer
        title={ctxComment ? `评论 #${ctxComment.id} · 原帖 #${ctxComment.postcardId}` : '上下文'}
        width={560}
        open={ctxOpen}
        onClose={() => {
          setCtxOpen(false)
          setCtxComment(null)
          setCtxPostcard(null)
        }}
        destroyOnClose
      >
        {ctxLoading ? (
          <Text type="secondary">加载中…</Text>
        ) : ctxComment && ctxPostcard ? (
          <>
            <Paragraph>
              <Text strong>评论内容</Text>
            </Paragraph>
            <Paragraph>{ctxComment.content}</Paragraph>
            <Paragraph>
              <Text strong>原帖作者 userId：</Text> {ctxPostcard.userId}
            </Paragraph>
            <Paragraph>
              <Text strong>原帖正文</Text>
            </Paragraph>
            <Paragraph>{ctxPostcard.content}</Paragraph>
            <Text strong>原帖配图（审核必看）</Text>
            <div style={{ marginTop: 8 }}>
              {ctxUrls.length ? (
                <Image.PreviewGroup items={ctxUrls}>
                  <Space wrap>
                    {ctxUrls.map((u) => (
                      <Image key={u} width={220} src={u} style={{ borderRadius: 8 }} />
                    ))}
                  </Space>
                </Image.PreviewGroup>
              ) : (
                <Text type="secondary">该帖无配图</Text>
              )}
            </div>
          </>
        ) : ctxComment ? (
          <Text type="secondary">未能加载原帖</Text>
        ) : null}
      </Drawer>

      <Drawer
        title="驳回评论"
        width={400}
        open={!!rejecting}
        onClose={() => setRejecting(null)}
        destroyOnClose
        extra={
          <Button
            type="primary"
            danger
            onClick={async () => {
              const v = await rejectForm.validateFields()
              if (!rejecting) return
              await api.rejectComment(rejecting.id, v.reason || 'Rejected by admin')
              message.success('已驳回')
              setRejecting(null)
              void load()
            }}
          >
            确认驳回
          </Button>
        }
      >
        <Form form={rejectForm} layout="vertical">
          <Form.Item name="reason" label="驳回原因" rules={[{ required: true, message: '请填写原因' }]}>
            <Input.TextArea rows={4} placeholder="审核备注" />
          </Form.Item>
        </Form>
      </Drawer>
    </div>
  )
}
