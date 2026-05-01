import { Button, Space, Table, message } from 'antd'
import { useEffect, useState } from 'react'
import { api } from '../../services/api'

export default function ReportList() {
  const [rows, setRows] = useState<any[]>([])
  const load = () => {
    api.reports({ page: { page: 1, size: 50 } })
      .then((d: any) => setRows(d.records || []))
      .catch((e: any) => message.error(e.message))
  }
  useEffect(() => { load() }, [])

  return (
    <Table
      rowKey="id"
      dataSource={rows}
      columns={[
        { title: 'ID', dataIndex: 'id' },
        { title: 'Type', dataIndex: 'targetType' },
        { title: 'Target', dataIndex: 'targetId' },
        { title: 'Reason', dataIndex: 'reason' },
        { title: 'Status', dataIndex: 'status' },
        {
          title: 'Actions',
          render: (_, r) => (
            <Space>
              <Button size="small" type="primary" onClick={async () => { await api.handleReport(r.id, 'Handled'); load() }}>Handle</Button>
              <Button size="small" danger onClick={async () => { await api.rejectReport(r.id, 'Rejected'); load() }}>Reject</Button>
            </Space>
          ),
        },
      ]}
    />
  )
}
