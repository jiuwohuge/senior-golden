import { Button, Drawer, Form, Image, Input, Select, Space, Table, Tag, Typography, message } from 'antd'
import type { ColumnsType } from 'antd/es/table'
import { useCallback, useEffect, useMemo, useState } from 'react'
import { api } from '../../services/api'

const { Paragraph, Text } = Typography

type PostcardRow = {
  id: number
  userId: number
  content: string
  mainImageUrl?: string
  images?: string[] | null
  reviewStatus?: number
  status?: number
  machineReviewNote?: string | null
}

function normalizeImageList(row: PostcardRow): string[] {
  const fromArr = Array.isArray(row.images) ? row.images.filter(Boolean) : []
  if (fromArr.length) return fromArr
  if (row.mainImageUrl) return [row.mainImageUrl]
  return []
}

export default function PostcardList() {
  const [rows, setRows] = useState<PostcardRow[]>([])
  const [total, setTotal] = useState(0)
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(20)
  const [reviewFilter, setReviewFilter] = useState<number | undefined>(0)
  const [preview, setPreview] = useState<PostcardRow | null>(null)
  const [rejecting, setRejecting] = useState<PostcardRow | null>(null)
  const [rejectForm] = Form.useForm<{ reason: string }>()

  const load = useCallback(async () => {
    try {
      const d: any = await api.postcards({
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

  const columns: ColumnsType<PostcardRow> = useMemo(
    () => [
      { title: 'ID', dataIndex: 'id', width: 72 },
      { title: 'User', dataIndex: 'userId', width: 88 },
      {
        title: '配图',
        width: 120,
        render: (_, r) => {
          const urls = normalizeImageList(r)
          if (!urls.length) return <Text type="secondary">无图</Text>
          return (
            <Image.PreviewGroup items={urls}>
              <Image width={96} height={72} src={urls[0]} style={{ objectFit: 'cover', borderRadius: 6 }} />
            </Image.PreviewGroup>
          )
        },
      },
      {
        title: '正文',
        dataIndex: 'content',
        ellipsis: true,
        render: (t: string) => <Paragraph ellipsis={{ rows: 2 }}>{t}</Paragraph>,
      },
      {
        title: '审核',
        width: 96,
        dataIndex: 'reviewStatus',
        render: (v: number) => {
          if (v === 0) return <Tag color="gold">待审</Tag>
          if (v === 1) return <Tag color="green">通过</Tag>
          if (v === 2) return <Tag color="red">驳回</Tag>
          return <Tag>{String(v)}</Tag>
        },
      },
      {
        title: '机审备注',
        width: 200,
        dataIndex: 'machineReviewNote',
        ellipsis: true,
        render: (t: string | null | undefined) =>
          t ? <Paragraph ellipsis={{ rows: 2 }}>{t}</Paragraph> : <Text type="secondary">—</Text>,
      },
      {
        title: '操作',
        width: 220,
        fixed: 'right',
        render: (_, r) => (
          <Space wrap>
            <Button size="small" onClick={() => setPreview(r)}>
              预览
            </Button>
            <Button
              size="small"
              type="primary"
              disabled={r.reviewStatus === 1}
              onClick={async () => {
                await api.approvePostcard(r.id)
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
    [],
  )

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

      <Table<PostcardRow>
        rowKey="id"
        dataSource={rows}
        columns={columns}
        scroll={{ x: 900 }}
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
        title={`明信片 #${preview?.id ?? ''}`}
        width={520}
        open={!!preview}
        onClose={() => setPreview(null)}
        destroyOnClose
      >
        {preview && (
          <>
            <Paragraph>
              <Text strong>作者 userId：</Text> {preview.userId}
            </Paragraph>
            <Paragraph>
              <Text strong>正文</Text>
            </Paragraph>
            <Paragraph>{preview.content}</Paragraph>
            <Text strong>配图（可点击放大）</Text>
            <div style={{ marginTop: 8 }}>
              {normalizeImageList(preview).length ? (
                <Image.PreviewGroup items={normalizeImageList(preview)}>
                  <Space wrap>
                    {normalizeImageList(preview).map((u) => (
                      <Image key={u} width={200} src={u} style={{ borderRadius: 8 }} />
                    ))}
                  </Space>
                </Image.PreviewGroup>
              ) : (
                <Text type="secondary">无配图</Text>
              )}
            </div>
          </>
        )}
      </Drawer>

      <Drawer
        title="驳回明信片"
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
              await api.rejectPostcard(rejecting.id, v.reason || 'Rejected by admin')
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
