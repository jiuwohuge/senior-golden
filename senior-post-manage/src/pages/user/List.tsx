import { Button, Space, Table, message } from 'antd'
import { useEffect, useState } from 'react'
import { api } from '../../services/api'

export default function UserList() {
  const [rows, setRows] = useState<any[]>([])
  const load = () => {
    api.users({ page: { page: 1, size: 50 } })
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
        { title: 'Email', dataIndex: 'email' },
        { title: 'Nickname', dataIndex: 'nickname' },
        { title: 'Status', dataIndex: 'status' },
        {
          title: 'Actions',
          render: (_, r) => (
            <Space>
              <Button size="small" onClick={async () => { await api.userStatus(r.id, 1); load() }}>Enable</Button>
              <Button size="small" danger onClick={async () => { await api.userStatus(r.id, 2); load() }}>Ban</Button>
            </Space>
          ),
        },
      ]}
    />
  )
}
