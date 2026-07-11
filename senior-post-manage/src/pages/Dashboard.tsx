import {
  AuditOutlined,
  CrownOutlined,
  MailOutlined,
  SendOutlined,
  TeamOutlined,
  WarningOutlined,
} from '@ant-design/icons'
import { Card, Col, Row, Spin, Statistic, Table, message } from 'antd'
import { useEffect, useState } from 'react'
import { api } from '../services/api'

const STATS = [
  { title: '用户数', key: 'users', color: '#1677ff', bg: '#e6f4ff', icon: <TeamOutlined /> },
  { title: '今日新增用户', key: 'usersToday', color: '#13c2c2', bg: '#e6fffb', icon: <TeamOutlined /> },
  { title: '信件数', key: 'letters', color: '#722ed1', bg: '#f9f0ff', icon: <MailOutlined /> },
  { title: '今日信件', key: 'lettersToday', color: '#531dab', bg: '#f9f0ff', icon: <MailOutlined /> },
  { title: '在途信件', key: 'lettersInTransit', color: '#2f54eb', bg: '#f0f5ff', icon: <SendOutlined /> },
  { title: '待审信件', key: 'lettersPendingAudit', color: '#d48806', bg: '#fffbe6', icon: <AuditOutlined /> },
  { title: '出站失败', key: 'mailOutboxFailed', color: '#cf1322', bg: '#fff1f0', icon: <WarningOutlined /> },
  { title: '笔友关系', key: 'penpalCount', color: '#389e0d', bg: '#f6ffed', icon: <TeamOutlined /> },
  { title: '待处理举报', key: 'reportsPending', color: '#fa8c16', bg: '#fff7e6', icon: <WarningOutlined /> },
  { title: 'VIP 订阅', key: 'vipSubscriptions', color: '#eb2f96', bg: '#fff0f6', icon: <CrownOutlined /> },
]

/** 管理端数据看板：汇总指标与近 7 日用户/信件序列。 */
export default function Dashboard() {
  const [summary, setSummary] = useState<any>({})
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    setLoading(true)
    api
      .dashboard()
      .then(setSummary)
      .catch((e: any) => {
        console.error('dashboard failed', e?.message)
        message.error(e.message || '加载看板失败')
        setSummary({})
      })
      .finally(() => setLoading(false))
  }, [])

  const series7d: { date?: string; users?: number; letters?: number }[] = Array.isArray(summary.series7d)
    ? summary.series7d
    : []

  return (
    <Spin spinning={loading}>
      <div className="page-header">
        <h2 className="page-title">数据看板</h2>
      </div>
      <Row gutter={[16, 16]}>
        {STATS.map(({ title, key, color, bg, icon }) => (
          <Col key={key} xs={24} sm={12} lg={8} xl={6}>
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
                <div
                  style={{
                    width: 48,
                    height: 48,
                    borderRadius: 12,
                    background: bg,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: 22,
                    color,
                  }}
                >
                  {icon}
                </div>
              </div>
            </Card>
          </Col>
        ))}
      </Row>

      <Card
        title="近 7 日新增"
        bordered={false}
        style={{ marginTop: 16, borderRadius: 12, boxShadow: '0 2px 8px rgba(0,0,0,0.06)' }}
      >
        <Table
          rowKey={(r) => String(r.date)}
          size="small"
          pagination={false}
          dataSource={series7d}
          columns={[
            { title: '日期', dataIndex: 'date' },
            { title: '新增用户', dataIndex: 'users' },
            { title: '新增信件', dataIndex: 'letters' },
          ]}
        />
      </Card>
    </Spin>
  )
}
