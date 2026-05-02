import { Button, Form, Input, Space, Table } from 'antd'
import { useEffect, useState } from 'react'
import { api } from '../../services/api'

export default function SensitiveWordList() {
  const [rows, setRows] = useState<any[]>([])
  const [form] = Form.useForm()
  const load = () => api.sensitiveWords({ page:{page:1,size:50} }).then((d:any)=>setRows(d.records||[]))
  useEffect(() => { void load() }, [])

  return <>
    <Form form={form} layout="inline" onFinish={async(v)=>{await api.saveSensitiveWord(v);form.resetFields();load()}} style={{ marginBottom:16 }}>
      <Form.Item name="word" rules={[{required:true}]}><Input placeholder="敏感词" /></Form.Item>
      <Form.Item name="langCode" rules={[{required:true}]}><Input placeholder="语言代码，如 zh、en" /></Form.Item>
      <Button type="primary" htmlType="submit">保存</Button>
    </Form>
    <Table rowKey="id" dataSource={rows} columns={[
      { title: '敏感词', dataIndex: 'word' }, { title: '语言', dataIndex: 'langCode' },
      { title: '操作', render: (_, r) => <Space><Button danger size="small" onClick={async () => { await api.deleteSensitiveWord(r.id); load() }}>删除</Button></Space> },
    ]} />
  </>
}
