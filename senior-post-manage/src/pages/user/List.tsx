import { Button, Input, Modal, Space, Table, message } from 'antd'
import { useEffect, useState } from 'react'
import { api } from '../../services/api'

export default function UserList() {
  const [rows, setRows] = useState<any[]>([])
  const [deviceModalOpen, setDeviceModalOpen] = useState(false)
  const [deviceUser, setDeviceUser] = useState<any>(null)
  const [devices, setDevices] = useState<any[]>([])
  const [devicesLoading, setDevicesLoading] = useState(false)
  const [manualUuid, setManualUuid] = useState('')
  const [manualReason, setManualReason] = useState('')

  const load = () => {
    api
      .users({ page: { page: 1, size: 50 } })
      .then((d: any) => setRows(d.records || []))
      .catch((e: any) => message.error(e.message))
  }

  useEffect(() => {
    load()
  }, [])

  const openDeviceModal = (user: any) => {
    setDeviceUser(user)
    setDeviceModalOpen(true)
    setManualUuid('')
    setManualReason('')
    setDevicesLoading(true)
    api
      .userDevices(user.id)
      .then((list: any) => setDevices(Array.isArray(list) ? list : []))
      .catch((e: any) => {
        message.error(e.message)
        setDevices([])
      })
      .finally(() => setDevicesLoading(false))
  }

  const doBlock = async (deviceUuid: string, reason?: string) => {
    const u = deviceUuid.trim()
    if (!u) {
      message.error('deviceUuid 不能为空')
      return
    }
    try {
      await api.blockDevice({ deviceUuid: u, reason: reason?.trim() || undefined })
      message.success('设备已拉黑')
      if (deviceUser) {
        setDevicesLoading(true)
        api
          .userDevices(deviceUser.id)
          .then((list: any) => setDevices(Array.isArray(list) ? list : []))
          .catch(() => setDevices([]))
          .finally(() => setDevicesLoading(false))
      }
    } catch (e: any) {
      message.error(e.message)
    }
  }

  return (
    <>
      <Table
        rowKey="id"
        dataSource={rows}
        columns={[
          { title: 'ID', dataIndex: 'id' },
          { title: 'Email', dataIndex: 'email' },
          { title: 'Nickname', dataIndex: 'nickname' },
          {
            title: '管理后台',
            dataIndex: 'staffRole',
            render: (v: number | null | undefined) => (v != null && v !== 0 ? '是' : '否'),
          },
          { title: 'Status', dataIndex: 'status' },
          {
            title: 'Actions',
            render: (_, r) => (
              <Space wrap>
                <Button
                  size="small"
                  onClick={async () => {
                    await api.userStatus(r.id, 1)
                    load()
                  }}
                >
                  Enable
                </Button>
                <Button
                  size="small"
                  danger
                  onClick={async () => {
                    await api.userStatus(r.id, 2)
                    load()
                  }}
                >
                  Ban
                </Button>
                <Button size="small" onClick={() => openDeviceModal(r)}>
                  设备拉黑
                </Button>
              </Space>
            ),
          },
        ]}
      />
      <Modal
        title={deviceUser ? `设备 — 用户 #${deviceUser.id}` : '设备'}
        open={deviceModalOpen}
        onCancel={() => {
          setDeviceModalOpen(false)
          setDeviceUser(null)
          setDevices([])
        }}
        footer={null}
        width={720}
        destroyOnClose
      >
        <p style={{ marginBottom: 8, color: '#666' }}>
          从该用户已绑定设备中选择拉黑；若无记录，可在下方手动填写 deviceUuid（需与客户端上报一致）。
        </p>
        <Table
          size="small"
          rowKey={(d) => String(d.id ?? d.deviceUuid)}
          loading={devicesLoading}
          dataSource={devices}
          pagination={false}
          columns={[
            { title: 'deviceUuid', dataIndex: 'deviceUuid', ellipsis: true },
            { title: '类型', dataIndex: 'deviceType', width: 90 },
            { title: '状态', dataIndex: 'status', width: 72 },
            {
              title: '操作',
              width: 100,
              render: (_, d: any) => (
                <Button
                  size="small"
                  danger
                  disabled={Number(d.status) === 2}
                  onClick={() => void doBlock(d.deviceUuid, 'Manage block')}
                >
                  拉黑
                </Button>
              ),
            },
          ]}
        />
        <div style={{ marginTop: 16 }}>
          <div style={{ marginBottom: 8, fontWeight: 600 }}>手动拉黑</div>
          <Space direction="vertical" style={{ width: '100%' }}>
            <Input
              placeholder="deviceUuid"
              value={manualUuid}
              onChange={(e) => setManualUuid(e.target.value)}
            />
            <Input placeholder="原因（可选）" value={manualReason} onChange={(e) => setManualReason(e.target.value)} />
            <Button type="primary" danger onClick={() => void doBlock(manualUuid, manualReason)}>
              提交拉黑
            </Button>
          </Space>
        </div>
      </Modal>
    </>
  )
}
