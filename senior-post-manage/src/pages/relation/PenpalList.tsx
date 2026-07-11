import { Button, Col, Form, InputNumber, Popconfirm, message } from 'antd'
import type { ColumnsType } from 'antd/es/table'
import { useCallback, useEffect, useMemo, useState } from 'react'
import AdminProTable from '../../components/admin/AdminProTable'
import { api } from '../../services/api'

type PenpalRow = {
  id: number
  userA?: number
  userB?: number
  createdAt?: string
  letterCount?: number
}

/** 笔友关系运营：按用户筛选与强制解除。 */
export default function PenpalList() {
  const [rows, setRows] = useState<PenpalRow[]>([])
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
        const d: any = await api.penpalPaging({
          page: { page: p, size: ps },
          userId: f.userId,
          peerId: f.peerId,
        })
        setRows(d.records || [])
        setTotal(Number(d.total) || 0)
        setPage(Number(d.page) || p)
        setPageSize(Number(d.size) || ps)
      } catch (e: any) {
        console.error('penpalPaging failed', e?.message)
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

  const dissolve = async (id: number) => {
    try {
      await api.penpalDissolve(id)
      message.success('已解除笔友关系')
      void load()
    } catch (e: any) {
      console.error('penpalDissolve failed', e?.message)
      message.error(e.message)
    }
  }

  const columns: ColumnsType<PenpalRow> = useMemo(
    () => [
      { title: '关系 ID', dataIndex: 'id', width: 90 },
      { title: '用户 A', dataIndex: 'userA', width: 100 },
      { title: '用户 B', dataIndex: 'userB', width: 100 },
      { title: '往来封数', dataIndex: 'letterCount', width: 100 },
      { title: '建立时间', dataIndex: 'createdAt', width: 180 },
      {
        title: '操作',
        fixed: 'right',
        width: 120,
        render: (_, r) => (
          <Popconfirm
            title="确认强制解除该笔友关系？"
            onConfirm={() => void dissolve(r.id)}
            okButtonProps={{ danger: true }}
          >
            <Button size="small" danger>
              解除
            </Button>
          </Popconfirm>
        ),
      },
    ],
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [],
  )

  const filterItems = (
    <>
      <Col xs={24} sm={12} md={8} lg={6}>
        <Form.Item name="userId" label="用户 ID">
          <InputNumber style={{ width: '100%' }} min={1} placeholder="匹配任一侧" />
        </Form.Item>
      </Col>
      <Col xs={24} sm={12} md={8} lg={6}>
        <Form.Item name="peerId" label="对端用户 ID">
          <InputNumber style={{ width: '100%' }} min={1} placeholder="对端" />
        </Form.Item>
      </Col>
    </>
  )

  return (
    <div>
      <div className="page-header">
        <h2 className="page-title">笔友关系</h2>
      </div>
      <AdminProTable<PenpalRow>
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
        scrollX={800}
      />
    </div>
  )
}
