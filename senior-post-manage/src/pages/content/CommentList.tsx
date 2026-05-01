import { useState, useEffect } from 'react'
import { Table, Button, Space, Tag, Modal, message, Select, Row, Col } from 'antd'
import { CheckOutlined, CloseOutlined, DeleteOutlined } from '@ant-design/icons'
import type { ColumnsType } from 'antd/es/table'
import { commentApi } from '../../services/api'
import type { PostcardComment, PageQuery } from '../../types/models'

const { confirm } = Modal

const CommentList = () => {
  const [loading, setLoading] = useState(false)
  const [data, setData] = useState<PostcardComment[]>([])
  const [total, setTotal] = useState(0)
  const [query, setQuery] = useState<PageQuery & { reviewStatus?: number }>({ page: 1, pageSize: 20 })
  const [reviewStatus, setReviewStatus] = useState<number | undefined>(0)

  const fetchData = async () => {
    setLoading(true)
    try {
      const res = await commentApi.list({ ...query, reviewStatus })
      setData(res.data.list)
      setTotal(res.data.total)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchData()
  }, [query, reviewStatus])

  const handleApprove = async (record: PostcardComment) => {
    await commentApi.approve(record.id)
    message.success('已通过')
    fetchData()
  }

  const handleReject = async (record: PostcardComment) => {
    await commentApi.reject(record.id)
    message.success('已驳回')
    fetchData()
  }

  const handleDelete = (record: PostcardComment) => {
    confirm({
      title: '删除评论',
      content: '确定要删除该评论吗？',
      okText: '删除',
      okType: 'danger',
      onOk: async () => {
        await commentApi.delete(record.id)
        message.success('已删除')
        fetchData()
      },
    })
  }

  const columns: ColumnsType<PostcardComment> = [
    { title: 'ID', dataIndex: 'id', width: 80 },
    { title: '明信片ID', dataIndex: 'postcardId', width: 100 },
    { title: '用户ID', dataIndex: 'userId', width: 100 },
    { title: '内容', dataIndex: 'content', ellipsis: true },
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
      title: '状态',
      dataIndex: 'status',
      width: 80,
      render: (s) => (s === 1 ? <Tag color="green">正常</Tag> : <Tag color="gray">已删除</Tag>),
    },
    { title: '评论时间', dataIndex: 'createdAt', width: 180 },
    {
      title: '操作',
      width: 220,
      fixed: 'right',
      render: (_, record) => (
        <Space>
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

export default CommentList