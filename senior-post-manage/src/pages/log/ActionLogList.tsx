import { useState, useEffect } from 'react'
import { Table, Tag, Space } from 'antd'
import type { ColumnsType } from 'antd/es/table'
import { logApi } from '../../services/api'
import type { ActionLog, PageQuery } from '../../types/models'

const ActionLogList = () => {
  const [loading, setLoading] = useState(false)
  const [data, setData] = useState<ActionLog[]>([])
  const [total, setTotal] = useState(0)
  const [query, setQuery] = useState<PageQuery>({ page: 1, pageSize: 20 })

  const fetchData = async () => {
    setLoading(true)
    try {
      const res = await logApi.actionList(query)
      setData(res.data.list)
      setTotal(res.data.total)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchData()
  }, [query])

  const columns: ColumnsType<ActionLog> = [
    { title: 'ID', dataIndex: 'id', width: 80 },
    { title: '用户ID', dataIndex: 'userId', width: 100 },
    { title: '行为类型', dataIndex: 'actionType', width: 120 },
    { title: '目标类型', dataIndex: 'targetType', width: 120 },
    { title: '目标ID', dataIndex: 'targetId', width: 100 },
    {
      title: '详情',
      dataIndex: 'details',
      width: 200,
      render: (d) => d ? <pre style={{ margin: 0, fontSize: 12 }}>{JSON.stringify(d, null, 2)}</pre> : '-',
    },
    { title: '时间', dataIndex: 'createdAt', width: 180 },
  ]

  return (
    <div>
      <Table
        columns={columns}
        dataSource={data}
        rowKey="id"
        loading={loading}
        scroll={{ x: 1200 }}
        pagination={{
          total,
          current: query.page,
          pageSize: query.pageSize,
          showSizeChanger: true,
          showTotal: (t) => `共 ${t} 条`,
          onChange: (page, pageSize) => setQuery({ ...query, page, pageSize }),
        }}
      />
    </div>
  )
}

export default ActionLogList