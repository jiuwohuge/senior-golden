import { Button, Space, Table, message } from 'antd'
import { useEffect, useMemo, useState } from 'react'
import UserCell, { useUserBriefs } from '../../components/admin/UserCell'
import { api } from '../../services/api'

export default function FeedbackList() {
  const [loading, setLoading] = useState(false)
  const [rows, setRows] = useState<any[]>([])
  const [total, setTotal] = useState(0)
  const [page, setPage] = useState(1)
  const [size, setSize] = useState(20)
  const userIds = useMemo(() => rows.map((r) => r.userId), [rows])
  const { briefs, signed } = useUserBriefs(userIds)

  const load = async (p: number, s: number) => {
    setLoading(true)
    try {
      const d: any = await api.feedbackPaging({
        page: { page: p, size: s },
      })
      setRows(d.records || d.list || [])
      setTotal(Number(d.total) || 0)
      setPage(Number(d.page) || p)
      setSize(Number(d.size) || s)
    } catch (e: any) {
      message.error(e?.message || '加载失败')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    void load(1, 20)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  return (
    <Space direction="vertical" style={{ width: '100%' }} size="middle">
      <Button
        type="default"
        onClick={() => {
          void load(page, size)
        }}
      >
        刷新
      </Button>
      <Table
        rowKey="id"
        loading={loading}
        dataSource={rows}
        scroll={{ x: 960 }}
        pagination={{
          current: page,
          pageSize: size,
          total,
          showSizeChanger: true,
          onChange: (p, ps) => void load(p, ps || size),
        }}
        columns={[
          { title: 'ID', dataIndex: 'id', width: 90 },
          {
            title: '用户',
            width: 180,
            render: (_, r) => (
              <UserCell
                userId={r.userId}
                brief={{
                  id: r.userId,
                  nickname: r.nickname || briefs[r.userId]?.nickname,
                  avatarUrl: briefs[r.userId]?.avatarUrl,
                }}
                signedUrl={signed[r.userId]}
              />
            ),
          },
          { title: '客户端版本', dataIndex: 'clientVersion', width: 120, ellipsis: true },
          { title: '内容', dataIndex: 'content', ellipsis: true },
          { title: '创建时间', dataIndex: 'createdAt', width: 180 },
        ]}
      />
    </Space>
  )
}
