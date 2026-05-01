import { Button, Form, Input, Space, Table, message } from 'antd'
import { useEffect, useState } from 'react'
import { api } from '../../services/api'

export default function CountryList() {
  const [rows, setRows] = useState<any[]>([])
  const [loading, setLoading] = useState(false)
  const [keyword, setKeyword] = useState('')
  const [form] = Form.useForm()

  const fetchList = (kw: string) => {
    setLoading(true)
    api.countries({ page: { page: 1, size: 500 }, keyword: kw.trim() || undefined })
      .then((d: any) => setRows(d.records || []))
      .catch((e: any) => message.error(e.message))
      .finally(() => setLoading(false))
  }

  useEffect(() => { fetchList('') }, [])

  const onFinish = async (v: any) => {
    const sortOrder = v.sortOrder === '' || v.sortOrder === undefined ? 0 : Number(v.sortOrder)
    await api.saveCountry({ ...v, sortOrder })
    form.resetFields()
    fetchList(keyword)
  }

  return (
    <>
      <Space style={{ marginBottom: 16 }}>
        <Input placeholder="代码/中英文名称" allowClear value={keyword} onChange={(e) => setKeyword(e.target.value)} style={{ width: 220 }} />
        <Button onClick={() => fetchList(keyword)}>查询</Button>
      </Space>
      <Form form={form} layout="inline" onFinish={onFinish} style={{ marginBottom: 16 }}>
        <Form.Item name="id" hidden><Input /></Form.Item>
        <Form.Item name="countryCode" rules={[{ required: true }]}><Input placeholder="ISO 代码" style={{ width: 100 }} /></Form.Item>
        <Form.Item name="countryNameEn" rules={[{ required: true }]}><Input placeholder="英文名" style={{ width: 140 }} /></Form.Item>
        <Form.Item name="countryNameZh" rules={[{ required: true }]}><Input placeholder="中文名" style={{ width: 140 }} /></Form.Item>
        <Form.Item name="sortOrder"><Input placeholder="排序" type="number" style={{ width: 80 }} /></Form.Item>
        <Button type="primary" htmlType="submit">保存</Button>
        <Button onClick={() => form.resetFields()}>清空表单</Button>
      </Form>
      <Table
        rowKey="id"
        loading={loading}
        dataSource={rows}
        columns={[
          { title: 'ID', dataIndex: 'id', width: 72 },
          { title: '代码', dataIndex: 'countryCode', width: 88 },
          { title: '英文', dataIndex: 'countryNameEn' },
          { title: '中文', dataIndex: 'countryNameZh' },
          { title: '排序', dataIndex: 'sortOrder', width: 72 },
          {
            title: '操作',
            width: 160,
            render: (_, r) => (
              <Space>
                <Button
                  size="small"
                  onClick={() => {
                    form.setFieldsValue({
                      id: r.id,
                      countryCode: r.countryCode,
                      countryNameEn: r.countryNameEn,
                      countryNameZh: r.countryNameZh,
                      sortOrder: r.sortOrder,
                    })
                  }}
                >
                  编辑
                </Button>
                <Button danger size="small" onClick={async () => { await api.deleteCountry(r.id); fetchList(keyword) }}>删除</Button>
              </Space>
            ),
          },
        ]}
      />
    </>
  )
}
