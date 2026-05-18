import { Button, Form, Input, Modal, Popconfirm, Select, Space, Table, message } from 'antd'
import { useEffect, useState } from 'react'
import { api } from '../../services/api'

export default function UserList() {
  const [rows, setRows] = useState<any[]>([])
  const [userModalOpen, setUserModalOpen] = useState(false)
  const [editingUser, setEditingUser] = useState<any>(null)
  const [savingUser, setSavingUser] = useState(false)
  const [deviceModalOpen, setDeviceModalOpen] = useState(false)
  const [deviceUser, setDeviceUser] = useState<any>(null)
  const [devices, setDevices] = useState<any[]>([])
  const [devicesLoading, setDevicesLoading] = useState(false)
  const [manualUuid, setManualUuid] = useState('')
  const [manualReason, setManualReason] = useState('')
  const [userForm] = Form.useForm()

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

  const openUserEditModal = (user: any) => {
    setEditingUser(user)
    userForm.setFieldsValue({
      id: user.id,
      email: user.email,
      nickname: user.nickname ?? '',
      birthYear: user.birthYear ?? undefined,
      countryCode: user.countryCode ?? '',
      bio: user.bio ?? '',
      status: Number(user.status ?? 1),
    })
    setUserModalOpen(true)
  }

  const submitUserSave = async () => {
    try {
      const v = await userForm.validateFields()
      setSavingUser(true)
      const body: {
        id: number
        nickname?: string
        birthYear?: number
        countryCode?: string
        bio?: string
        status?: number
      } = {
        id: Number(v.id),
      }
      if (typeof v.nickname === 'string' && v.nickname.trim()) {
        body.nickname = v.nickname.trim()
      }
      if (v.birthYear !== undefined && v.birthYear !== null && `${v.birthYear}`.trim() !== '') {
        body.birthYear = Number(v.birthYear)
      }
      if (typeof v.countryCode === 'string' && v.countryCode.trim()) {
        body.countryCode = v.countryCode.trim().toUpperCase()
      }
      if (typeof v.bio === 'string' && v.bio.trim()) {
        body.bio = v.bio.trim()
      }
      if (v.status !== undefined && v.status !== null) {
        body.status = Number(v.status)
      }
      await api.saveUser(body)
      message.success('用户已更新')
      setUserModalOpen(false)
      setEditingUser(null)
      userForm.resetFields()
      load()
    } catch (e: any) {
      if (e?.errorFields) return
      message.error(e.message || '保存失败')
    } finally {
      setSavingUser(false)
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
            title: 'VIP',
            dataIndex: 'isVip',
            width: 64,
            render: (v: boolean | undefined) => (v ? 'Y' : ''),
          },
          {
            title: 'Actions',
            render: (_, r) => (
              <Space wrap>
                <Button
                  size="small"
                  onClick={() => openUserEditModal(r)}
                >
                  编辑
                </Button>
                <Button size="small" onClick={() => openDeviceModal(r)}>
                  设备拉黑
                </Button>
                <Popconfirm
                  title="确认删除该用户？"
                  description="删除后该账号将被软删除，不可登录。"
                  onConfirm={async () => {
                    await api.deleteUser(r.id)
                    message.success('用户已删除')
                    load()
                  }}
                  okButtonProps={{ danger: true }}
                >
                  <Button size="small" danger>
                    删除
                  </Button>
                </Popconfirm>
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
      <Modal
        title={editingUser ? `编辑用户 #${editingUser.id}` : '编辑用户'}
        open={userModalOpen}
        onOk={() => void submitUserSave()}
        onCancel={() => {
          setUserModalOpen(false)
          setEditingUser(null)
          userForm.resetFields()
        }}
        confirmLoading={savingUser}
        okText="保存"
        destroyOnClose
        width={560}
      >
        <Form form={userForm} layout="vertical" style={{ marginTop: 12 }}>
          <Form.Item name="id" hidden>
            <Input
              readOnly
            />
          </Form.Item>
          <Form.Item label="邮箱" name="email">
            <Input disabled />
          </Form.Item>
          <Form.Item
            label="昵称"
            name="nickname"
            rules={[{ required: true, message: '请输入昵称' }]}
          >
            <Input maxLength={32} />
          </Form.Item>
          <Form.Item label="出生年份" name="birthYear">
            <Input type="number" placeholder="例如 1980" />
          </Form.Item>
          <Form.Item label="国家代码" name="countryCode">
            <Input maxLength={2} placeholder="CN / US / JP" />
          </Form.Item>
          <Form.Item label="个人简介" name="bio">
            <Input.TextArea maxLength={300} rows={3} />
          </Form.Item>
          <Form.Item label="状态" name="status">
            <Select
              options={[
                { label: '正常', value: 1 },
                { label: '封禁', value: 2 },
                { label: '注销', value: 3 },
              ]}
            />
          </Form.Item>
        </Form>
      </Modal>
    </>
  )
}
