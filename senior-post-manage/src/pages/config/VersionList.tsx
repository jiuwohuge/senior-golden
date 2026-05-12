import { PlusOutlined } from '@ant-design/icons'
import { Button, Form, Input, Modal, Popconfirm, Select, Space, Switch, Table, message } from 'antd'
import { useEffect, useState } from 'react'
import { api } from '../../services/api'

export default function VersionList() {
  const [rows, setRows] = useState<any[]>([])
  const [loading, setLoading] = useState(false)
  const [modalOpen, setModalOpen] = useState(false)
  const [saving, setSaving] = useState(false)
  const [form] = Form.useForm()

  const load = () => {
    setLoading(true)
    api.versions()
      .then((d: any) => setRows(d.records || []))
      .catch((e: any) => message.error(e.message))
      .finally(() => setLoading(false))
  }
  useEffect(() => { void load() }, [])

  const handleOk = async () => {
    try {
      const v = await form.validateFields()
      setSaving(true)
      await api.saveVersion(v)
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
        <h2 className="page-title">版本管理</h2>
        <Button type="primary" icon={<PlusOutlined />} onClick={() => { form.resetFields(); setModalOpen(true) }}>
          新增版本
        </Button>
      </div>
      <Table
        rowKey="id"
        loading={loading}
        dataSource={rows}
        size="middle"
        columns={[
          { title: '版本', dataIndex: 'versionCode' },
          { title: '平台', dataIndex: 'appPlatform' },
          { title: '强制更新', dataIndex: 'forceUpdate', render: (v) => String(v) },
          {
            title: '操作',
            width: 100,
            render: (_, r) => (
              <Popconfirm title="确认删除？" onConfirm={async () => { await api.deleteVersion(r.id); load() }}>
                <Button danger size="small">删除</Button>
              </Popconfirm>
            ),
          },
        ]}
      />
      <Modal
        title="新增版本"
        open={modalOpen}
        onOk={handleOk}
        onCancel={() => { setModalOpen(false); form.resetFields() }}
        confirmLoading={saving}
        destroyOnClose
        width={480}
      >
        <Form form={form} layout="vertical" style={{ marginTop: 16 }}>
          <Form.Item name="version" label="版本号" rules={[{ required: true, message: '请输入版本号' }]}>
            <Input placeholder="如 1.2.3" />
          </Form.Item>
          <Form.Item name="platform" label="平台" rules={[{ required: true, message: '请选择平台' }]}>
            <Select options={[{ value: 1, label: 'iOS' }, { value: 2, label: 'Android' }]} placeholder="选择平台" />
          </Form.Item>
          <Form.Item name="downloadUrl" label="下载地址" rules={[{ required: true, message: '请输入下载地址' }]}>
            <Input placeholder="https://..." />
          </Form.Item>
          <Form.Item name="isForceUpdate" label="是否强制更新" valuePropName="checked" initialValue={false}>
            <Switch checkedChildren="强制" unCheckedChildren="非强制" />
          </Form.Item>
        </Form>
      </Modal>
    </>
  )
}
