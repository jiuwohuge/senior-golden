import { Button, Col, Form, Input, InputNumber, message } from 'antd'
import type { ColumnsType } from 'antd/es/table'
import { useCallback, useEffect, useMemo, useState } from 'react'
import AdminProTable from '../../components/admin/AdminProTable'
import { api } from '../../services/api'

type OpLogRow = {
  id: number
  adminId?: number
  actionType?: string
  targetType?: string
  targetId?: number
  details?: unknown
  ipAddress?: unknown
  createdAt?: string
}

/** 管理员操作日志：按管理员/动作/目标类型筛选分页。 */
export default function AdminOperationLogList() {
  const [rows, setRows] = useState<OpLogRow[]>([])
  const [total, setTotal] = useState(0)
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(20)
  const [loading, setLoading] = useState(false)
  const [filterForm] = Form.useForm()

  const load = useCallback(
    async (p = page, ps = pageSize) => {
      setLoading(true)
      try {
        const f = filterForm.getFieldsValue()
        const d: any = await api.adminOperationLogs({
          page: { page: p, size: ps },
          adminId: f.adminId,
          actionType: f.actionType?.trim() || undefined,
          targetType: f.targetType?.trim() || undefined,
        })
        setRows(d.records || [])
        setTotal(Number(d.total) || 0)
        setPage(Number(d.page) || p)
        setPageSize(Number(d.size) || ps)
      } catch (e: any) {
        console.error('adminOperationLogs failed', e?.message)
        message.error(e.message || '加载失败')
      } finally {
        setLoading(false)
      }
    },
    [filterForm, page, pageSize],
  )

  useEffect(() => {
    void load(1, pageSize)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  const columns: ColumnsType<OpLogRow> = useMemo(
    () => [
      { title: 'ID', dataIndex: 'id', width: 80 },
      { title: '管理员 ID', dataIndex: 'adminId', width: 100 },
      { title: '操作类型', dataIndex: 'actionType', width: 160, ellipsis: true },
      { title: '目标类型', dataIndex: 'targetType', width: 120 },
      { title: '目标 ID', dataIndex: 'targetId', width: 100 },
      {
        title: '详情',
        dataIndex: 'details',
        ellipsis: true,
        render: (v) => (v == null ? '—' : typeof v === 'string' ? v : JSON.stringify(v)),
      },
      { title: 'IP', dataIndex: 'ipAddress', width: 120, render: (v) => (v == null ? '—' : String(v)) },
      { title: '时间', dataIndex: 'createdAt', width: 170 },
    ],
    [],
  )

  const filterItems = (
    <>
      <Col xs={24} sm={12} md={8} lg={6}>
        <Form.Item name="adminId" label="管理员 ID">
          <InputNumber style={{ width: '100%' }} min={1} />
        </Form.Item>
      </Col>
      <Col xs={24} sm={12} md={8} lg={6}>
        <Form.Item name="actionType" label="操作类型">
          <Input allowClear placeholder="如 user.batch_status" />
        </Form.Item>
      </Col>
      <Col xs={24} sm={12} md={8} lg={6}>
        <Form.Item name="targetType" label="目标类型">
          <Input allowClear placeholder="如 user / letter" />
        </Form.Item>
      </Col>
    </>
  )

  return (
    <div>
      <div className="page-header">
        <h2 className="page-title">管理员操作</h2>
      </div>
      <AdminProTable<OpLogRow>
        filterForm={filterForm}
        filterItems={filterItems}
        onSearch={() => void load(1, pageSize)}
        toolbar={<Button onClick={() => void load()}>刷新</Button>}
        columns={columns}
        dataSource={rows}
        loading={loading}
        total={total}
        page={page}
        pageSize={pageSize}
        onPageChange={(p, ps) => void load(p, ps)}
        scrollX={1100}
      />
    </div>
  )
}
