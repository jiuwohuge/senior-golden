import { Button, Form, Input, Space, Switch, Table } from 'antd'
import { useEffect, useState } from 'react'
import { api } from '../../services/api'

export default function AnnouncementList() {
  const [rows, setRows] = useState<any[]>([])
  const [form] = Form.useForm()
  const load = () => api.announcements({ page:{page:1,size:50} }).then((d:any)=>setRows(d.records||[]))
  useEffect(() => { void load() }, [])

  return <>
    <Form form={form} layout="inline" onFinish={async(v)=>{await api.saveAnnouncement(v);form.resetFields();load()}} style={{ marginBottom:16 }}>
      <Form.Item name="title" rules={[{required:true}]}><Input placeholder="标题" /></Form.Item>
      <Form.Item name="content" rules={[{required:true}]}><Input placeholder="正文内容" /></Form.Item>
      <Form.Item name="isActive" valuePropName="checked" initialValue={true}><Switch checkedChildren="启用" unCheckedChildren="停用" /></Form.Item>
      <Button type="primary" htmlType="submit">保存</Button>
    </Form>
    <Table rowKey="id" dataSource={rows} columns={[
      { title: '标题', dataIndex: 'title' }, { title: '启用', dataIndex: 'isActive', render: (v) => String(v) },
      { title: '操作', render: (_, r) => <Space><Button danger size="small" onClick={async () => { await api.deleteAnnouncement(r.id); load() }}>删除</Button></Space> },
    ]} />
  </>
}
