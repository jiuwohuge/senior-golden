import { Button, Card, Form, Input, Typography, message } from 'antd'
import { useNavigate } from 'react-router-dom'
import { api } from '../services/api'

export default function Login() {
  const nav = useNavigate()

  const onFinish = async (values: any) => {
    try {
      const res: any = await api.login(values.username, values.password)
      localStorage.setItem('admin_token', res.token)
      nav('/')
    } catch (e: any) {
      message.error(e.message || '登录失败')
    }
  }

  return (
    <div style={{ minHeight: '100%', display: 'grid', placeItems: 'center' }}>
      <Card style={{ width: 380 }}>
        <Typography.Title level={3} style={{ textAlign: 'center' }}>Senior Post 管理后台</Typography.Title>
        <Form layout="vertical" onFinish={onFinish}>
          <Form.Item label="用户名" name="username" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item label="密码" name="password" rules={[{ required: true }]}>
            <Input.Password />
          </Form.Item>
          <Button block type="primary" htmlType="submit">登录</Button>
        </Form>
      </Card>
    </div>
  )
}
