import { Table, message } from 'antd'
import { useCallback, useEffect, useState } from 'react'
import { api } from '../../services/api'

/** 用户行为日志分页列表。 */
export default function ActionLogList() {
  const [rows, setRows] = useState<any[]>([])
  const [total, setTotal] = useState(0)
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(20)
  const [loading, setLoading] = useState(false)

  const load = useCallback(async (p: number, ps: number) => {
    setLoading(true)
    try {
      const d: any = await api.actionLogs({ page: { page: p, size: ps } })
      setRows(d.records || [])
      setTotal(Number(d.total) || 0)
      setPage(Number(d.page) || p)
      setPageSize(Number(d.size) || ps)
    } catch (e: any) {
      console.error('actionLogs failed', e?.message)
      message.error(e.message || '加载失败')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    void load(1, 20)
  }, [load])

  return (
    <div>
      <div className="page-header">
        <h2 className="page-title">行为日志</h2>
      </div>
      <Table
        rowKey="id"
        loading={loading}
        dataSource={rows}
        scroll={{ x: 800 }}
        pagination={{
          current: page,
          pageSize,
          total,
          showSizeChanger: true,
          showTotal: (t) => `共 ${t} 条`,
          onChange: (p, ps) => void load(p, ps),
        }}
        columns={[
          { title: 'ID', dataIndex: 'id', width: 80 },
          { title: '用户 ID', dataIndex: 'userId', width: 100 },
          { title: '行为', dataIndex: 'actionType', ellipsis: true },
          { title: '目标类型', dataIndex: 'targetType', width: 120 },
          { title: '目标 ID', dataIndex: 'targetId', width: 100 },
          { title: '时间', dataIndex: 'createdAt', width: 170 },
        ]}
      />
    </div>
  )
}
