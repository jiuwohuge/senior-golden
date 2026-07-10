import { CrownOutlined, MailOutlined, TeamOutlined, WarningOutlined } from '@ant-design/icons'
import { Card, Col, Row, Spin, Statistic, message } from 'antd'
import { useEffect, useState } from 'react'
import { api } from '../services/api'

const STATS = [
  { title: '用户数', key: 'users', color: '#1677ff', bg: '#e6f4ff', icon: <TeamOutlined /> },
  { title: '信件数', key: 'letters', color: '#722ed1', bg: '#f9f0ff', icon: <MailOutlined /> },
  { title: '待处理举报', key: 'reportsPending', color: '#fa8c16', bg: '#fff7e6', icon: <WarningOutlined /> },
  { title: 'VIP 订阅', key: 'vipSubscriptions', color: '#eb2f96', bg: '#fff0f6', icon: <CrownOutlined /> },
]

export default function Dashboard() {
  const [summary, setSummary] = useState<any>({})
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    setLoading(true)
    api.dashboard()
      .then(setSummary)
      .catch((e: any) => {
        message.error(e.message || '加载看板失败')
        setSummary({})
      })
      .finally(() => setLoading(false))
  }, [])

  return (
    <Spin spinning={loading}>
      <div className="page-header">
        <h2 className="page-title">数据看板</h2>
      </div>
      <Row gutter={[16, 16]}>
        {STATS.map(({ title, key, color, bg, icon }) => (
          <Col key={key} xs={24} sm={12} lg={8}>
            <Card
              bordered={false}
              style={{ borderRadius: 12, boxShadow: '0 2px 8px rgba(0,0,0,0.06)' }}
              bodyStyle={{ padding: '20px 24px' }}
            >
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <Statistic
                  title={<span style={{ fontSize: 13, color: 'rgba(0,0,0,0.45)' }}>{title}</span>}
                  value={Number(summary[key] || 0)}
                  valueStyle={{ fontSize: 28, fontWeight: 700, color }}
                />
                <div style={{
                  width: 48, height: 48,
                  borderRadius: 12,
                  background: bg,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontSize: 22, color,
                }}>
                  {icon}
                </div>
              </div>
            </Card>
          </Col>
        ))}
      </Row>
    </Spin>
  )
}
