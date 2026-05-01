import { Card, Col, Row, Spin, Statistic, message } from 'antd'
import { useEffect, useState } from 'react'
import { api } from '../services/api'

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
      <Row gutter={16}>
        {[
          ['用户数', summary.users],
          ['明信片数', summary.postcards],
          ['信件数', summary.letters],
          ['待处理举报', summary.reportsPending],
          ['VIP 订阅', summary.vipSubscriptions],
        ].map(([title, val]) => (
          <Col key={String(title)} span={8} style={{ marginBottom: 16 }}>
            <Card><Statistic title={String(title)} value={Number(val || 0)} /></Card>
          </Col>
        ))}
      </Row>
    </Spin>
  )
}
