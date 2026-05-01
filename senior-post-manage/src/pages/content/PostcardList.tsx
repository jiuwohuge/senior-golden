import { useState, useEffect } from 'react'
import { Table, Button, Space, Tag, Modal, message, Select, Image, Drawer, Descriptions } from 'antd'
import { CheckOutlined, CloseOutlined, DeleteOutlined, EyeOutlined } from '@ant-design/icons'
import type { ColumnsType } from 'antd/es/table'
import { postcardApi } from '../../services/api'
import type { Postcard, User, PageQuery } from '../../types/models'

const { confirm } = Modal

const PostcardList = () => {
  const [loading, setLoading] = useState(false)
  const [data, setData] = useState<Postcard[]>([])
  const [total, setTotal] = useState(0)
  const [query, setQuery] = useState<PageQuery & { reviewStatus?: number }>({ page: 1, pageSize: 20 })
  const [reviewStatus, setReviewStatus] = useState<number | undefined>(0)
  const [selectedRow, setSelectedRow] = useState<Postcard | null>(null)
  const [drawerVisible, setDrawerVisible] = useState(false)

  const fetchData = async () => {
    setLoading(true)
    try {
      const res = await postcardApi.list({ ...query, reviewStatus })
      setData(res.data.list)
      setTotal(res.data.total)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchData()
  }, [query, reviewStatus])

  const handleApprove = async (record: Postcard) => {
    await postcardApi.approve(record.id)
    message.success('已通过')
    fetchData()
  }

  const handleReject = (record: Postcard) => {
    confirm({
      title: '驳回明信片',
      content: '确定要驳回该明信片吗？',
      onOk: async () => {
        await postcardApi.reject(record.id, '内容违规')
        message.success('已驳回')
        fetchData()
      },
    })
  }

  const handleDelete = (record: Postcard) => {
    confirm({
      title: '删除明信片',
      content: '确定要删除该明信片吗？',
      okText: '删除',
      okType: 'danger',
      onOk: async () => {
        await postcardApi.delete(record.id)
        message.success('已删除')
        fetchData()
      },
    })
  }

  const showDetail = (record: Postcard) => {
    setSelectedRow(record)
    setDrawerVisible(true)
  }

  const columns: ColumnsType<Postcard> = [
    { title: 'ID', dataIndex: 'id', width: 80 },
    { title: '用户ID', dataIndex: 'userId', width: 100 },
    {
      title: '内容',
      dataIndex: 'content',
      ellipsis: true,
      width: 200,
      render: (text) => text?.substring(0, 50) + '...',
    },
    {
      title: '图片',
      dataIndex: 'images',
      width: 120,
      render: (imgs: string[]) =>
        imgs && imgs.length > 0 ? <Image width={80} height={60} src={imgs[0]} /> : '-',
    },
    {
      title: '审核状态',
      dataIndex: 'reviewStatus',
      width: 100,
      render: (s) => {
        const map: Record<number, { color: string; text: string }> = {
          0: { color: 'orange', text: '待审核' },
          1: { color: 'green', text: '已通过' },
          2: { color: 'red', text: '已驳回' },
        }
        return <Tag color={map[s]?.color}>{map[s]?.text || s}</Tag>
      },
    },
    {
      title: '发布状态',
      dataIndex: 'status',
      width: 100,
      render: (s) => {
        const map: Record<number, { color: string; text: string }> = {
          1: { color: 'green', text: '公开' },
          2: { color: 'gray', text: '隐藏' },
          3: { color: 'red', text: '违规删除' },
        }
        return <Tag color={map[s]?.color}>{map[s]?.text || s}</Tag>
      },
    },
    { title: '发布时间', dataIndex: 'publishedAt', width: 180 },
    {
      title: '操作',
      width: 220,
      fixed: 'right',
      render: (_, record) => (
        <Space>
          <Button size="small" icon={<EyeOutlined />} onClick={() => showDetail(record)}>
            查看
          </Button>
          {record.reviewStatus === 0 && (
            <>
              <Button size="small" type="primary" icon={<CheckOutlined />} onClick={() => handleApprove(record)}>
                通过
              </Button>
              <Button size="small" danger icon={<CloseOutlined />} onClick={() => handleReject(record)}>
                驳回
              </Button>
            </>
          )}
          <Button size="small" danger icon={<DeleteOutlined />} onClick={() => handleDelete(record)}>
            删除
          </Button>
        </Space>
      ),
    },
  ]

  return (
    <div>
      <Row gutter={16} style={{ marginBottom: 16 }}>
        <Col span={4}>
          <Select
            placeholder="审核状态"
            value={reviewStatus}
            onChange={setReviewStatus}
            style={{ width: '100%' }}
          >
            <Select.Option value={0}>待审核</Select.Option>
            <Select.Option value={1}>已通过</Select.Option>
            <Select.Option value={2}>已驳回</Select.Option>
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
          showTotal: (t) => `共 ${t} 条`,
          onChange: (page, pageSize) => setQuery({ ...query, page, pageSize }),
        }}
      />

      <Drawer
        title="明信片详情"
        placement="right"
        width={600}
        open={drawerVisible}
        onClose={() => setDrawerVisible(false)}
      >
        {selectedRow && (
          <Descriptions column={1} bordered>
            <Descriptions.Item label="ID">{selectedRow.id}</Descriptions.Item>
            <Descriptions.Item label="用户ID">{selectedRow.userId}</Descriptions.Item>
            <Descriptions.Item label="内容">{selectedRow.content}</Descriptions.Item>
            <Descriptions.Item label="图片">
              {selectedRow.images?.map((url, i) => (
                <Image key={i} width={100} height={100} src={url} style={{ marginRight: 8 }} />
              ))}
            </Descriptions.Item>
            <Descriptions.Item label="审核状态">
              {selectedRow.reviewStatus === 0 ? '待审核' : selectedRow.reviewStatus === 1 ? '已通过' : '已驳回'}
            </Descriptions.Item>
            <Descriptions.Item label="发布状态">
              {selectedRow.status === 1 ? '公开' : selectedRow.status === 2 ? '隐藏' : '违规删除'}
            </Descriptions.Item>
            <Descriptions.Item label="发布时间">{selectedRow.publishedAt}</Descriptions.Item>
          </Descriptions>
        )}
      </Drawer>
    </div>
  )
}

export default PostcardList