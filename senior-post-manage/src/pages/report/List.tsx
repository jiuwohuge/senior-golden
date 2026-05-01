import { useState, useEffect } from 'react'
import { Table, Button, Space, Tag, Modal, message, Select, Input, Row, Col } from 'antd'
import { CheckOutlined, CloseOutlined } from '@ant-design/icons'
import type { ColumnsType } from 'antd/es/table'
import { reportApi } from '../../services/api'
import type { Report, PageQuery } from '../../types/models'

const { TextArea } = Input
const { confirm } = Modal

const ReportList = () => {
  const [loading, setLoading] = useState(false)
  const [data, setData] = useState<Report[]>([])
  const [total, setTotal] = useState(0)
  const [query, setQuery] = useState<PageQuery & { status?: number }>({ page: 1, pageSize: 20 })
  const [status, setStatus] = useState<number | undefined>(0)
  const [handleNote, setHandleNote] = useState('')
  const [selectedId, setSelectedId] = useState<number | null>(null)

  const fetchData = async () => {
    setLoading(true)
    try {
      const res = await reportApi.list({ ...query, status })
      setData(res.data.list)
      setTotal(res.data.total)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchData()
  }, [query, status])

  const handleProcess = (record: Report) => {
    setSelectedId(record.id)
    confirm({
      title: '处理举报',
      content: (
        <div>
          <p>举报详情：{record.reason}</p>
          <TextArea
            placeholder="处理备注"
            value={handleNote}
            onChange={(e) => setHandleNote(e.target.value)}
            rows={3}
          />
        </div>
      ),
      onOk: async () => {
        await reportApi.handle(record.id, handleNote)
        message.success('已处理')
        setHandleNote('')
        setSelectedId(null)
        fetchData()
      },
    })
  }

  const handleReject = (record: Report) => {
    setSelectedId(record.id)
    confirm({
      title: '驳回举报',
      content: (
        <div>
          <p>确定要驳回该举报吗？</p>
          <TextArea
            placeholder="驳回原因"
            value={handleNote}
            onChange={(e) => setHandleNote(e.target.value)}
            rows={3}
          />
        </div>
      ),
      onOk: async () => {
        await reportApi.reject(record.id, handleNote)
        message.success('已驳回')
        setHandleNote('')
        setSelectedId(null)
        fetchData()
      },
    })
  }

  const columns: ColumnsType<Report> = [
    { title: 'ID', dataIndex: 'id', width: 80 },
    { title: '举报人ID', dataIndex: 'reporterUserId', width: 100 },
    {
      title: '举报对象',
      width: 150,
      render: (_, record) => `${record.targetType}:${record.targetId}`,
    },
    { title: '举报原因', dataIndex: 'reason', ellipsis: true },
    {
      title: '状态',
      dataIndex: 'status',
      width: 100,
      render: (s) => {
        const map: Record<number, { color: string; text: string }> = {
          0: { color: 'orange', text: '待处理' },
          1: { color: 'green', text: '已处理' },
          2: { color: 'gray', text: '已驳回' },
        }
        return <Tag color={map[s]?.color}>{map[s]?.text || s}</Tag>
      },
    },
    { title: '处理备注', dataIndex: 'handleNote', ellipsis: true },
    { title: '举报时间', dataIndex: 'createdAt', width: 180 },
    {
      title: '操作',
      width: 180,
      fixed: 'right',
      render: (_, record) =>
        record.status === 0 && (
          <Space>
            <Button size="small" type="primary" icon={<CheckOutlined />} onClick={() => handleProcess(record)}>
              处理
            </Button>
            <Button size="small" danger icon={<CloseOutlined />} onClick={() => handleReject(record)}>
              驳回
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
            placeholder="处理状态"
            value={status}
            onChange={setStatus}
            style={{ width: '100%' }}
          >
            <Select.Option value={0}>待处理</Select.Option>
            <Select.Option value={1}>已处理</Select.Option>
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
    </div>
  )
}

export default ReportList