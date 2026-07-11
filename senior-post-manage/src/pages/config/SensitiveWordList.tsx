import { PlusOutlined } from '@ant-design/icons'
import { Button, Form, Input, Modal, Popconfirm, Table, message } from 'antd'
import { useCallback, useEffect, useState } from 'react'
import { api } from '../../services/api'

export default function SensitiveWordList() {
  const [rows, setRows] = useState<any[]>([])
  const [total, setTotal] = useState(0)
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(20)
  const [loading, setLoading] = useState(false)
  const [modalOpen, setModalOpen] = useState(false)
  const [saving, setSaving] = useState(false)
  const [form] = Form.useForm()

  const load = useCallback(() => {
    setLoading(true)
    api
      .sensitiveWords({ page: { page, size: pageSize } })
      .then((d: any) => {
        setRows(d.records || [])
        setTotal(d.total ?? 0)
      })
      .catch((e: any) => message.error(e.message))
      .finally(() => setLoading(false))
  }, [page, pageSize])

  useEffect(() => {
    void load()
  }, [load])

  const handleOk = async () => {
    try {
      const v = await form.validateFields()
      setSaving(true)
      await api.saveSensitiveWord(v)
      setModalOpen(false)
      form.resetFields()
      load()
    } catch (e: any) {
      if (e?.errorFields) return
      message.error(e.message)
    } finally {
      setSaving(false)
    }
  }

  return (
    <>
      <div className="page-header">
        <h2 className="page-title">敏感词管理</h2>
        <Button type="primary" icon={<PlusOutlined />} onClick={() => { form.resetFields(); setModalOpen(true) }}>
          新增敏感词
        </Button>
      </div>
      <Table
        rowKey="id"
        loading={loading}
        dataSource={rows}
        size="middle"
        pagination={{
          current: page,
          pageSize,
          total,
          showSizeChanger: true,
          showTotal: (t) => `共 ${t} 条`,
          onChange: (p, ps) => {
            setPage(p)
            setPageSize(ps)
          },
        }}
        columns={[
          { title: '敏感词', dataIndex: 'word' },
          { title: '语言', dataIndex: 'langCode', width: 120 },
          {
            title: '操作',
            width: 100,
            render: (_, r) => (
              <Popconfirm title="确认删除？" onConfirm={async () => { await api.deleteSensitiveWord(r.id); load() }}>
                <Button danger size="small">删除</Button>
              </Popconfirm>
            ),
          },
        ]}
      />
      <Modal
        title="新增敏感词"
        open={modalOpen}
        onOk={handleOk}
        onCancel={() => { setModalOpen(false); form.resetFields() }}
        confirmLoading={saving}
        destroyOnClose
        width={400}
      >
        <Form form={form} layout="vertical" style={{ marginTop: 16 }}>
          <Form.Item name="word" label="敏感词" rules={[{ required: true, message: '请输入敏感词' }]}>
            <Input placeholder="敏感词内容" />
          </Form.Item>
          <Form.Item name="langCode" label="语言代码" rules={[{ required: true, message: '请输入语言代码' }]}>
            <Input placeholder="如 zh、en、ja" />
          </Form.Item>
        </Form>
      </Modal>
    </>
  )
}
