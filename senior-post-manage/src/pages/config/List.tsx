import { PlusOutlined } from '@ant-design/icons'
import { Button, Form, Input, Modal, Popconfirm, Table, message } from 'antd'
import { useCallback, useEffect, useState } from 'react'
import { api } from '../../services/api'

export default function ConfigList() {
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
      .configs({ page: { page, size: pageSize } })
      .then((d: any) => {
        setRows(d.records || [])
        setTotal(d.total ?? 0)
      })
      .catch((e: any) => message.error(e.message))
      .finally(() => setLoading(false))
  }, [page, pageSize])

  useEffect(() => {
    load()
  }, [load])

  const handleOk = async () => {
    try {
      const v = await form.validateFields()
      setSaving(true)
      await api.saveConfig(v)
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
        <h2 className="page-title">参数配置</h2>
        <Button
          type="primary"
          icon={<PlusOutlined />}
          onClick={() => {
            form.resetFields()
            setModalOpen(true)
          }}
        >
          新增配置
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
          { title: 'ID', dataIndex: 'id', width: 72 },
          { title: 'Key', dataIndex: 'configKey' },
          { title: 'Value', dataIndex: 'configValue', ellipsis: true },
          { title: 'Group', dataIndex: 'configGroup', width: 120 },
          {
            title: '操作',
            width: 100,
            render: (_, r) => (
              <Popconfirm
                title="确认删除？"
                onConfirm={async () => {
                  await api.deleteConfig(r.id)
                  load()
                }}
              >
                <Button danger size="small">
                  删除
                </Button>
              </Popconfirm>
            ),
          },
        ]}
      />
      <Modal
        title="新增配置"
        open={modalOpen}
        onOk={handleOk}
        onCancel={() => {
          setModalOpen(false)
          form.resetFields()
        }}
        confirmLoading={saving}
        destroyOnClose
        width={480}
      >
        <Form form={form} layout="vertical" style={{ marginTop: 16 }}>
          <Form.Item name="configKey" label="Key" rules={[{ required: true, message: '请输入配置键' }]}>
            <Input placeholder="配置键" />
          </Form.Item>
          <Form.Item name="configValue" label="Value" rules={[{ required: true, message: '请输入配置值' }]}>
            <Input.TextArea placeholder="配置值" rows={3} />
          </Form.Item>
          <Form.Item name="configGroup" label="Group" rules={[{ required: true, message: '请输入分组' }]}>
            <Input placeholder="分组，如 sys、vip" />
          </Form.Item>
        </Form>
      </Modal>
    </>
  )
}
