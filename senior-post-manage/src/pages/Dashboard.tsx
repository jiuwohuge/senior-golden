import { useState, useEffect } from 'react'
import { Row, Col, Card, Statistic, Skeleton } from 'antd'
import { UserOutlined, TeamOutlined, MailOutlined, SendOutlined, CrownOutlined, RiseOutlined } from '@ant-design/icons'
import { dashboardApi } from '../services/api'
import type { DashboardStats } from '../types/models'

const DashboardPage = () => {
  const [stats, setStats] = useState<DashboardStats | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    dashboardApi.stats()
      .then((res) => setStats(res.data))
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [])

  if (loading) {
    return (
      <Row gutter={16}>
        {[1, 2, 3, 4, 5, 6].map((i) => (
          <Col span={4} key={i}>
            <Card><Skeleton active paragraph={{ rows: 1 }} /></Card>
          </Col>
        ))}
      </Row>
    )
  }

  const vipRate = stats && stats.totalUsers > 0 ? ((stats.vipCount / stats.totalUsers) * 100).toFixed(1) : '0'

  return (
    <div>
      <Row gutter={16} style={{ marginBottom: 24 }}>
        <Col span={8}>
          <Card>
            <Statistic
              title="总用户数"
              value={stats?.totalUsers || 0}
              prefix={<UserOutlined />}
              valueStyle={{ color: '#1890ff' }}
            />
          </Card>
        </Col>
        <Col span={8}>
          <Card>
            <Statistic
              title="今日新增用户"
              value={stats?.todayNewUsers || 0}
              prefix={<RiseOutlined />}
              valueStyle={{ color: '#52c41a' }}
            />
          </Card>
        </Col>
        <Col span={8}>
          <Card>
            <Statistic
              title="日活用户"
              value={stats?.dailyActiveUsers || 0}
              prefix={<TeamOutlined />}
              valueStyle={{ color: '#722ed1' }}
            />
          </Card>
        </Col>
      </Row>

      <Row gutter={16} style={{ marginBottom: 24 }}>
        <Col span={6}>
          <Card>
            <Statistic
              title="明信片总数"
              value={stats?.totalPostcards || 0}
              prefix={<MailOutlined />}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic
              title="信件总数"
              value={stats?.totalLetters || 0}
              prefix={<SendOutlined />}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic
              title="VIP用户"
              value={stats?.vipCount || 0}
              prefix={<CrownOutlined />}
              valueStyle={{ color: '#faad14' }}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic
              title="VIP转化率"
              value={vipRate}
              suffix="%"
              valueStyle={{ color: '#faad14' }}
            />
          </Card>
        </Col>
      </Row>

      <Row gutter={16}>
        <Col span={24}>
          <Card title="Welcome" styles={{ body: { padding: 16 } }}>
            <p style={{ color: '#666' }}>
              欢迎使用 Senior Post 管理后台。请从左侧菜单选择功能模块进行管理。
            </p>
          </Card>
        </Col>
      </Row>
    </div>
  )
}

export default DashboardPage