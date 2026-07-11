import { Button, Space, Table, Tag, message } from 'antd'
import { useCallback, useEffect, useMemo, useState } from 'react'
import {
  REPORT_STATUS_OPTIONS,
  REPORT_TARGET_TYPE_OPTIONS,
  labelOf,
} from '../../components/admin/EnumSelect'
import UserCell, { useUserBriefs } from '../../components/admin/UserCell'
import { api } from '../../services/api'

export default function ReportList() {
  const [rows, setRows] = useState<any[]>([])
  const [total, setTotal] = useState(0)
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(20)
  const userIds = useMemo(() => rows.map((r) => r.reporterUserId), [rows])
  const { briefs, signed } = useUserBriefs(userIds)

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
      scroll={{ x: 960 }}
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
        {
          title: '举报人',
          width: 160,
          render: (_, r) => (
            <UserCell
              userId={r.reporterUserId}
              brief={briefs[r.reporterUserId]}
              signedUrl={signed[r.reporterUserId]}
            />
          ),
        },
        {
          title: '类型',
          dataIndex: 'targetType',
          width: 96,
          render: (v: string) => labelOf(REPORT_TARGET_TYPE_OPTIONS, v),
        },
        { title: '目标', dataIndex: 'targetId', width: 96 },
        { title: '原因', dataIndex: 'reason', ellipsis: true },
        {
          title: '状态',
          dataIndex: 'status',
          width: 90,
          render: (v: number) => <Tag>{labelOf(REPORT_STATUS_OPTIONS, v)}</Tag>,
        },
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
