import { Button, Space, Table, message } from 'antd'
import { useEffect, useState } from 'react'
import { api } from '../../services/api'

export default function CommentList() {
  const [rows, setRows] = useState<any[]>([])
  const load = () => {
    api.comments({ page: { page: 1, size: 50 } })
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
        { title: 'Postcard ID', dataIndex: 'postcardId' },
        { title: 'Content', dataIndex: 'content', ellipsis: true },
        { title: 'Review', dataIndex: 'reviewStatus' },
        {
          title: 'Actions',
          render: (_, r) => (
            <Space>
              <Button size="small" type="primary" onClick={async () => { await api.approveComment(r.id); load() }}>Approve</Button>
              <Button size="small" danger onClick={async () => { await api.rejectComment(r.id, 'Rejected by admin'); load() }}>Reject</Button>
            </Space>
          ),
        },
      ]}
    />
  )
}
