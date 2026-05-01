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
      <Form.Item name="word" rules={[{required:true}]}><Input placeholder="��д�" /></Form.Item>
      <Form.Item name="langCode" rules={[{required:true}]}><Input placeholder="����" /></Form.Item>
      <Button type="primary" htmlType="submit">����</Button>
    </Form>
    <Table rowKey="id" dataSource={rows} columns={[
      { title:'��', dataIndex:'word' }, { title:'����', dataIndex:'langCode' },
      { title:'����', render:(_,r)=><Space><Button danger size="small" onClick={async()=>{await api.deleteSensitiveWord(r.id);load()}}>ɾ��</Button></Space>}
    ]} />
  </>
}
