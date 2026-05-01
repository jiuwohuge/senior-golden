import { Button, Form, Input, Select, Space, Switch, Table } from 'antd'
import { useEffect, useState } from 'react'
import { api } from '../../services/api'

export default function VersionList() {
  const [rows, setRows] = useState<any[]>([])
  const [form] = Form.useForm()
  const load = () => api.versions().then((d:any)=>setRows(d.records||[]))
  useEffect(() => { void load() }, [])

  return <>
    <Form form={form} layout="inline" onFinish={async(v)=>{await api.saveVersion(v);form.resetFields();load()}} style={{ marginBottom:16 }}>
      <Form.Item name="version" rules={[{required:true}]}><Input placeholder="�汾��" /></Form.Item>
      <Form.Item name="platform" rules={[{required:true}]}><Select style={{width:120}} options={[{value:1,label:'iOS'},{value:2,label:'Android'}]} /></Form.Item>
      <Form.Item name="downloadUrl" rules={[{required:true}]}><Input placeholder="���ص�ַ" /></Form.Item>
      <Form.Item name="isForceUpdate" valuePropName="checked" initialValue={false}><Switch checkedChildren="ǿ��" unCheckedChildren="��ǿ��" /></Form.Item>
      <Button type="primary" htmlType="submit">����</Button>
    </Form>
    <Table rowKey="id" dataSource={rows} columns={[
      { title:'�汾', dataIndex:'versionCode' }, { title:'ƽ̨', dataIndex:'appPlatform' }, { title:'ǿ��', dataIndex:'forceUpdate', render:(v)=>String(v) },
      { title:'����', render:(_,r)=><Space><Button danger size="small" onClick={async()=>{await api.deleteVersion(r.id);load()}}>ɾ��</Button></Space>}
    ]} />
  </>
}
