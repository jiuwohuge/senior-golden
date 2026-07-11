import { Button, Space, Table, message } from 'antd'
import { useCallback, useEffect, useState } from 'react'
import { api } from '../../services/api'

export default function ReportList() {
  const [rows, setRows] = useState<any[]>([])
  const [total, setTotal] = useState(0)
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(20)

  const load = useCallback(() => {
    api
      .reports({ page: { page, size: pageSize } })
      .then((d: any) => {
        setRows(d.records || d.list || [])
        setTotal(d.total ?? 0)
      })
      .catch((e: any) => message.error(e.message))
  }, [page, pageSize])

  useEffect(() => {
    load()
  }, [load])

  return (
    <Table
      rowKey="id"
      dataSource={rows}
      pagination={{
        current: page,
        pageSize,
        total,
        showSizeChanger: true,
        showTotal: (t) => `共 ${t} 条`,
        onChange: (p, ps) => {
          setPage(p)
          setPageSize(ps)
        },
      }}
      columns={[
        { title: 'ID', dataIndex: 'id', width: 72 },
        { title: '举报人', dataIndex: 'reporterUserId', width: 96 },
        { title: '类型', dataIndex: 'targetType', width: 96 },
        { title: '目标', dataIndex: 'targetId', width: 96 },
        { title: '原因', dataIndex: 'reason', ellipsis: true },
        { title: '状态', dataIndex: 'status', width: 80 },
        {
          title: '操作',
          width: 180,
          render: (_, r) => (
            <Space>
              <Button
                size="small"
                type="primary"
                onClick={async () => {
                  await api.handleReport(r.id, 'Handled')
                  load()
                }}
              >
                处理
              </Button>
              <Button
                size="small"
                danger
                onClick={async () => {
                  await api.rejectReport(r.id, 'Rejected')
                  load()
                }}
              >
                驳回
              </Button>
            </Space>
          ),
        },
      ]}
    />
  )
}
