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
      <Form.Item name="version" rules={[{required:true}]}><Input placeholder="版本号" /></Form.Item>
      <Form.Item name="platform" rules={[{required:true}]}><Select style={{width:120}} options={[{value:1,label:'iOS'},{value:2,label:'Android'}]} /></Form.Item>
      <Form.Item name="downloadUrl" rules={[{required:true}]}><Input placeholder="下载地址" /></Form.Item>
      <Form.Item name="isForceUpdate" valuePropName="checked" initialValue={false}><Switch checkedChildren="强制" unCheckedChildren="非强制" /></Form.Item>
      <Button type="primary" htmlType="submit">保存</Button>
    </Form>
    <Table rowKey="id" dataSource={rows} columns={[
      { title: '版本', dataIndex: 'versionCode' }, { title: '平台', dataIndex: 'appPlatform' }, { title: '强制更新', dataIndex: 'forceUpdate', render: (v) => String(v) },
      { title: '操作', render: (_, r) => <Space><Button danger size="small" onClick={async () => { await api.deleteVersion(r.id); load() }}>删除</Button></Space> },
    ]} />
  </>
}
