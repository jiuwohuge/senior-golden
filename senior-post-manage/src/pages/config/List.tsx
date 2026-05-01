import { Button, Form, Input, Space, Table, message } from 'antd'
import { useEffect, useState } from 'react'
import { api } from '../../services/api'

export default function ConfigList() {
  const [rows, setRows] = useState<any[]>([])
  const [form] = Form.useForm()
  const load = () => {
    api.configs({ page: { page: 1, size: 500 } })
      .then((d: any) => setRows(d.records || []))
      .catch((e: any) => message.error(e.message))
  }
  useEffect(() => { load() }, [])

  const onFinish = async (v: any) => {
    await api.saveConfig(v)
    form.resetFields()
    load()
  }

  return (
    <>
      <Form form={form} layout="inline" onFinish={onFinish} style={{ marginBottom: 16 }}>
        <Form.Item name="configKey" rules={[{ required: true }]}><Input placeholder="key" /></Form.Item>
        <Form.Item name="configValue" rules={[{ required: true }]}><Input placeholder="value" /></Form.Item>
        <Form.Item name="configGroup" rules={[{ required: true }]}><Input placeholder="group" /></Form.Item>
        <Button type="primary" htmlType="submit">Save</Button>
      </Form>
      <Table
        rowKey="id"
        dataSource={rows}
        columns={[
          { title: 'ID', dataIndex: 'id' },
          { title: 'Key', dataIndex: 'configKey' },
          { title: 'Value', dataIndex: 'configValue' },
          { title: 'Group', dataIndex: 'configGroup' },
          {
            title: 'Actions',
            render: (_, r) => (
              <Space>
                <Button danger size="small" onClick={async () => { await api.deleteConfig(r.id); load() }}>Delete</Button>
              </Space>
            ),
          },
        ]}
      />
    </>
  )
}
