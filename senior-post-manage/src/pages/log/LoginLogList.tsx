import { Table } from 'antd'
import { useEffect, useState } from 'react'
import { api } from '../../services/api'

export default function LoginLogList() {
  const [rows, setRows] = useState<any[]>([])
  useEffect(() => { api.loginLogs({ page:{page:1,size:50} }).then((d:any)=>setRows(d.records||[])) }, [])
  return <Table rowKey="id" dataSource={rows} columns={[
    {title:'ID',dataIndex:'id'}, {title:'用户ID',dataIndex:'userId'}, {title:'设备',dataIndex:'deviceUuid'}, {title:'结果',dataIndex:'loginResult'}
  ]} />
}
