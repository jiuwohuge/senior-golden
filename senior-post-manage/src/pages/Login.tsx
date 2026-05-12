import { LockOutlined, UserOutlined } from '@ant-design/icons'
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
    <div style={{
      minHeight: '100%',
      display: 'grid',
      placeItems: 'center',
      background: 'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)',
    }}>
      <Card
        style={{ width: 400, borderRadius: 16, boxShadow: '0 20px 60px rgba(0,0,0,0.4)' }}
        bordered={false}
      >
        <div style={{ textAlign: 'center', marginBottom: 32 }}>
          <div style={{
            width: 56, height: 56,
            borderRadius: 14,
            background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
            display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
            marginBottom: 14,
            fontSize: 22, color: '#fff', fontWeight: 700,
          }}>S</div>
          <Typography.Title level={4} style={{ margin: 0 }}>Senior Post 管理后台</Typography.Title>
          <Typography.Text type="secondary" style={{ fontSize: 13 }}>请使用管理员账号登录</Typography.Text>
        </div>
        <Form layout="vertical" onFinish={onFinish} size="large">
          <Form.Item label="用户名" name="username" rules={[{ required: true, message: '请输入用户名' }]}>
            <Input prefix={<UserOutlined style={{ color: '#bfbfbf' }} />} placeholder="admin 或完整邮箱" />
          </Form.Item>
          <Form.Item label="密码" name="password" rules={[{ required: true, message: '请输入密码' }]}>
            <Input.Password prefix={<LockOutlined style={{ color: '#bfbfbf' }} />} />
          </Form.Item>
          <Form.Item style={{ marginBottom: 0, marginTop: 8 }}>
            <Button block type="primary" htmlType="submit" size="large">登录</Button>
          </Form.Item>
        </Form>
      </Card>
    </div>
  )
}
