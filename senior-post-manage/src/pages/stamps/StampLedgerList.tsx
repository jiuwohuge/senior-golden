import { Button, Form, Input, Space, Table, message } from 'antd'
import { useEffect, useState } from 'react'
import { api } from '../../services/api'

export default function StampLedgerList() {
  const [loading, setLoading] = useState(false)
  const [rows, setRows] = useState<any[]>([])
  const [total, setTotal] = useState(0)
  const [page, setPage] = useState(1)
  const [size, setSize] = useState(20)
  const [userId, setUserId] = useState('')
  const [reason, setReason] = useState('')

  const load = async (p: number, s: number) => {
    setLoading(true)
    try {
      let uid: number | undefined
      if (userId.trim()) {
        const n = Number(userId.trim())
        if (Number.isNaN(n)) {
          message.error('用户 ID 须为数字')
          setLoading(false)
          return
        }
        uid = n
      }
      const d: any = await api.stampLedgerPaging({
        page: { page: p, size: s },
        userId: uid,
        reasonKeyword: reason.trim() || undefined,
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
      <Form layout="inline">
        <Form.Item label="用户 ID">
          <Input
            allowClear
            placeholder="可选"
            style={{ width: 140 }}
            value={userId}
            onChange={(e) => setUserId(e.target.value)}
          />
        </Form.Item>
        <Form.Item label="原因关键字">
          <Input
            allowClear
            placeholder="模糊匹配 reason"
            style={{ width: 220 }}
            value={reason}
            onChange={(e) => setReason(e.target.value)}
          />
        </Form.Item>
        <Form.Item>
          <Button
            type="primary"
            onClick={() => {
              void load(1, size)
            }}
          >
            查询
          </Button>
        </Form.Item>
      </Form>
      <Table
        rowKey="id"
        loading={loading}
        dataSource={rows}
        scroll={{ x: 900 }}
        pagination={{
          current: page,
          pageSize: size,
          total,
          showSizeChanger: true,
          onChange: (p, ps) => void load(p, ps || size),
        }}
        columns={[
          { title: '流水 ID', dataIndex: 'id', width: 100 },
          { title: '用户 ID', dataIndex: 'userId', width: 100 },
          { title: '变更', dataIndex: 'changeAmount', width: 90 },
          { title: '变更后余额', dataIndex: 'balanceAfter', width: 110 },
          { title: '原因', dataIndex: 'reason', ellipsis: true },
          { title: '关联 refId', dataIndex: 'refId', width: 110 },
          { title: '创建时间', dataIndex: 'createdAt', width: 180 },
        ]}
      />
    </Space>
  )
}
