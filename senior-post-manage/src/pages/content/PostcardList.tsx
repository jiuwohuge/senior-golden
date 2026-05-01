import { Button, Space, Table, message } from 'antd'
import { useEffect, useState } from 'react'
import { api } from '../../services/api'

export default function PostcardList() {
  const [rows, setRows] = useState<any[]>([])
  const load = () => {
    api.postcards({ page: { page: 1, size: 50 } })
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
        { title: 'User ID', dataIndex: 'userId' },
        { title: 'Content', dataIndex: 'content', ellipsis: true },
        { title: 'Review', dataIndex: 'reviewStatus' },
        {
          title: 'Actions',
          render: (_, r) => (
            <Space>
              <Button size="small" type="primary" onClick={async () => { await api.approvePostcard(r.id); load() }}>Approve</Button>
              <Button size="small" danger onClick={async () => { await api.rejectPostcard(r.id, 'Rejected by admin'); load() }}>Reject</Button>
            </Space>
          ),
        },
      ]}
    />
  )
}
