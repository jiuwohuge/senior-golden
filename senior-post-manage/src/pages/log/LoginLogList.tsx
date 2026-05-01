import { useState, useEffect } from 'react'
import { Table, Input, Space } from 'antd'
import { SearchOutlined } from '@ant-design/icons'
import type { ColumnsType } from 'antd/es/table'
import { logApi } from '../../services/api'
import type { LoginLog, PageQuery } from '../../types/models'

const LoginLogList = () => {
  const [loading, setLoading] = useState(false)
  const [data, setData] = useState<LoginLog[]>([])
  const [total, setTotal] = useState(0)
  const [query, setQuery] = useState<PageQuery>({ page: 1, pageSize: 20 })

  const fetchData = async () => {
    setLoading(true)
    try {
      const res = await logApi.loginList(query)
      setData(res.data.list)
      setTotal(res.data.total)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchData()
  }, [query])

  const columns: ColumnsType<LoginLog> = [
    { title: 'ID', dataIndex: 'id', width: 80 },
    { title: '用户ID', dataIndex: 'userId', width: 100 },
    { title: '登录IP', dataIndex: 'loginIp', width: 140 },
    { title: '设备UUID', dataIndex: 'deviceUuid', ellipsis: true },
    {
      title: '结果',
      dataIndex: 'loginResult',
      width: 100,
      render: (r) => (r === 1 ? '成功' : '失败'),
    },
    { title: '失败原因', dataIndex: 'failReason', ellipsis: true },
    { title: '登录时间', dataIndex: 'createdAt', width: 180 },
  ]

  return (
    <div>
      <Table
        columns={columns}
        dataSource={data}
        rowKey="id"
        loading={loading}
        scroll={{ x: 1000 }}
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

export default LoginLogList