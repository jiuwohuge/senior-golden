import { useState, useEffect } from 'react'
import { Table, Button, Space, Tag, Modal, message, Input, Select, Row, Col } from 'antd'
import { SearchOutlined, BanOutlined, UnlockOutlined, BlockOutlined } from '@ant-design/icons'
import type { ColumnsType } from 'antd/es/table'
import { userApi } from '../../services/api'
import type { User, UserQuery } from '../../types/models'

const { confirm } = Modal

const UserList = () => {
  const [loading, setLoading] = useState(false)
  const [data, setData] = useState<User[]>([])
  const [total, setTotal] = useState(0)
  const [query, setQuery] = useState<UserQuery>({ page: 1, pageSize: 20 })
  const [keyword, setKeyword] = useState('')
  const [status, setStatus] = useState<number | undefined>()

  const fetchData = async () => {
    setLoading(true)
    try {
      const res = await userApi.list({ ...query, keyword, status })
      setData(res.data.list)
      setTotal(res.data.total)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchData()
  }, [query, keyword, status])

  const handleBan = (record: User) => {
    confirm({
      title: '确认封禁该用户？',
      content: `封禁用户 ${record.nickname} (${record.email})`,
      onOk: async () => {
        await userApi.ban(record.id)
        message.success('已封禁')
        fetchData()
      },
    })
  }

  const handleUnban = async (record: User) => {
    await userApi.unban(record.id)
    message.success('已解封')
    fetchData()
  }

  const handleBlockDevice = (record: User) => {
    confirm({
      title: '确认拉黑该用户设备？',
      content: '该用户所有设备将被拉黑，无法再注册新账号',
      onOk: async () => {
        await userApi.blockDevice(record.id)
        message.success('已拉黑设备')
        fetchData()
      },
    })
  }

  const columns: ColumnsType<User> = [
    { title: 'ID', dataIndex: 'id', width: 80 },
    { title: '邮箱', dataIndex: 'email', width: 200 },
    { title: '昵称', dataIndex: 'nickname', width: 120 },
    {
      title: '年龄',
      dataIndex: 'birthYear',
      width: 80,
      render: (year: number) => new Date().getFullYear() - year,
    },
    { title: '国家', dataIndex: 'countryCode', width: 80 },
    {
      title: '邮票余额',
      dataIndex: 'stampsBalance',
      width: 100,
      render: (val) => <Tag color="orange">{val}</Tag>,
    },
    {
      title: 'VIP',
      dataIndex: 'isVip',
      width: 80,
      render: (vip) => (vip ? <Tag color="gold">VIP</Tag> : '-'),
    },
    {
      title: '状态',
      dataIndex: 'status',
      width: 80,
      render: (s) => {
        const map: Record<number, { color: string; text: string }> = {
          1: { color: 'green', text: '正常' },
          2: { color: 'red', text: '封禁' },
          3: { color: 'gray', text: '注销' },
        }
        return <Tag color={map[s]?.color}>{map[s]?.text || s}</Tag>
      },
    },
    { title: '注册IP', dataIndex: 'registerIp', width: 140 },
    { title: '注册时间', dataIndex: 'createdAt', width: 180 },
    {
      title: '操作',
      width: 200,
      fixed: 'right',
      render: (_, record) => (
        <Space>
          {record.status === 1 ? (
            <Button size="small" danger icon={<BanOutlined />} onClick={() => handleBan(record)}>
              封禁
            </Button>
          ) : (
            <Button size="small" icon={<UnlockOutlined />} onClick={() => handleUnban(record)}>
              解封
            </Button>
          )}
          <Button size="small" danger icon={<BlockOutlined />} onClick={() => handleBlockDevice(record)}>
            拉黑设备
          </Button>
        </Space>
      ),
    },
  ]

  return (
    <div>
      <Row gutter={16} style={{ marginBottom: 16 }}>
        <Col span={6}>
          <Input
            placeholder="搜索邮箱/昵称"
            prefix={<SearchOutlined />}
            value={keyword}
            onChange={(e) => setKeyword(e.target.value)}
            allowClear
          />
        </Col>
        <Col span={4}>
          <Select
            placeholder="状态筛选"
            value={status}
            onChange={setStatus}
            allowClear
            style={{ width: '100%' }}
          >
            <Select.Option value={1}>正常</Select.Option>
            <Select.Option value={2}>封禁</Select.Option>
            <Select.Option value={3}>注销</Select.Option>
          </Select>
        </Col>
      </Row>

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
          showQuickJumper: true,
          showTotal: (t) => `共 ${t} 条`,
          onChange: (page, pageSize) => setQuery({ ...query, page, pageSize }),
        }}
      />
    </div>
  )
}

export default UserList