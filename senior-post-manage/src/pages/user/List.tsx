import {
  Avatar,
  Button,
  Col,
  DatePicker,
  Form,
  Image,
  Input,
  InputNumber,
  Modal,
  Popconfirm,
  Select,
  Space,
  Table,
  Tag,
  Tooltip,
  Typography,
  Upload,
  message,
} from 'antd'
import type { ColumnsType } from 'antd/es/table'
import { DeleteOutlined, LoadingOutlined, PlusOutlined, UserOutlined } from '@ant-design/icons'
import dayjs from 'dayjs'
import { useCallback, useEffect, useMemo, useState } from 'react'
import AdminProTable from '../../components/admin/AdminProTable'
import EnumSelect, {
  AVATAR_AUDIT_OPTIONS,
  GENDER_OPTIONS,
  USER_STATUS_OPTIONS,
} from '../../components/admin/EnumSelect'
import { api } from '../../services/api'
import { signObjectKeysForPreview, uploadAdminUserAvatar } from '../../services/ossUpload'

const { Text } = Typography
const { RangePicker } = DatePicker

type UserRow = {
  id: number
  email?: string
  nickname?: string
  avatarUrl?: string
  avatarAuditStatus?: number
  staffRole?: number
  status?: number
  gender?: number
  isVip?: boolean
  birthYear?: number
  countryCode?: string
  bio?: string
  createdAt?: string
  lastLoginAt?: string
}

const AVATAR_AUDIT_LABEL: Record<number, { label: string; color: string }> = {
  0: { label: '待审', color: 'gold' },
  1: { label: '通过', color: 'green' },
  2: { label: '驳回', color: 'red' },
}

function isStaff(row: UserRow) {
  return row.staffRole != null && row.staffRole !== 0
}

function rangeToIso(range: unknown): { from?: string; to?: string } {
  if (!Array.isArray(range) || range.length !== 2 || !range[0] || !range[1]) return {}
  return {
    from: dayjs(range[0]).startOf('day').format('YYYY-MM-DDTHH:mm:ss'),
    to: dayjs(range[1]).endOf('day').format('YYYY-MM-DDTHH:mm:ss'),
  }
}

async function signAvatarKeys(rows: UserRow[]): Promise<Record<number, string>> {
  const withKey = rows.filter((r) => r.avatarUrl?.trim())
  if (!withKey.length) return {}
  const keys = withKey.map((r) => r.avatarUrl!.trim())
  try {
    const res: any = await api.ossGetSign({ objectKeys: keys })
    const items: { objectKey?: string; signedUrl?: string }[] = res?.items ?? []
    const byKey = new Map<string, string>()
    for (const it of items) {
      if (it.objectKey && it.signedUrl) byKey.set(it.objectKey, it.signedUrl)
    }
    const out: Record<number, string> = {}
    for (const r of withKey) {
      const url = byKey.get(r.avatarUrl!.trim())
      if (url) out[r.id] = url
    }
    return out
  } catch (e: any) {
    console.warn('ossGetSign failed', e?.message)
    return {}
  }
}

/** 用户运营列表：多维筛选、分页、批量封禁/解封、资料编辑与头像审核。 */
export default function UserList() {
  const [rows, setRows] = useState<UserRow[]>([])
  const [total, setTotal] = useState(0)
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(20)
  const [loading, setLoading] = useState(false)
  const [selectedIds, setSelectedIds] = useState<number[]>([])
  const [signedAvatars, setSignedAvatars] = useState<Record<number, string>>({})
  const [countryOptions, setCountryOptions] = useState<{ value: string; label: string }[]>([])
  const [userModalOpen, setUserModalOpen] = useState(false)
  const [editingUser, setEditingUser] = useState<UserRow | null>(null)
  const [editAvatarPreview, setEditAvatarPreview] = useState<string | null>(null)
  const [avatarUploading, setAvatarUploading] = useState(false)
  const [savingUser, setSavingUser] = useState(false)
  const [deviceModalOpen, setDeviceModalOpen] = useState(false)
  const [deviceUser, setDeviceUser] = useState<UserRow | null>(null)
  const [devices, setDevices] = useState<any[]>([])
  const [devicesLoading, setDevicesLoading] = useState(false)
  const [manualUuid, setManualUuid] = useState('')
  const [manualReason, setManualReason] = useState('')
  const [filterForm] = Form.useForm()
  const [userForm] = Form.useForm()

  useEffect(() => {
    api
      .countries({ page: { page: 1, size: 500 } })
      .then((d: any) => {
        const list = d.records || []
        setCountryOptions(
          list.map((c: any) => ({
            value: c.countryCode,
            label: `${c.countryNameZh || c.countryNameEn || c.countryCode} (${c.countryCode})`,
          })),
        )
      })
      .catch((e: any) => console.warn('load countries failed', e?.message))
  }, [])

  const load = useCallback(
    async (p = page, ps = pageSize) => {
      setLoading(true)
      try {
        const f = filterForm.getFieldsValue()
        const created = rangeToIso(f.createdRange)
        const lastLogin = rangeToIso(f.lastLoginRange)
        const d: any = await api.users({
          page: { page: p, size: ps },
          email: f.email?.trim() || undefined,
          nickname: f.nickname?.trim() || undefined,
          status: f.status,
          gender: f.gender,
          countryCode: f.countryCode || undefined,
          minBirthYear: f.minBirthYear,
          maxBirthYear: f.maxBirthYear,
          isVip: f.isVip,
          avatarAuditStatus: f.avatarAuditStatus,
          createdFrom: created.from,
          createdTo: created.to,
          lastLoginFrom: lastLogin.from,
          lastLoginTo: lastLogin.to,
        })
        const list: UserRow[] = d.records || []
        setRows(list)
        setTotal(Number(d.total) || 0)
        setPage(Number(d.page) || p)
        setPageSize(Number(d.size) || ps)
        setSelectedIds([])
        const signed = await signAvatarKeys(list)
        setSignedAvatars(signed)
      } catch (e: any) {
        console.error('users paging failed', e?.message)
        message.error(e.message || '加载失败')
      } finally {
        setLoading(false)
      }
    },
    [filterForm, page, pageSize],
  )

  useEffect(() => {
    void load(1, pageSize)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  const openDeviceModal = (user: UserRow) => {
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
      console.error('blockDevice failed', e?.message)
      message.error(e.message)
    }
  }

  const handleAvatarUpload = async (file: File) => {
    if (!editingUser) return
    if (!file.type.startsWith('image/')) {
      message.error('请选择图片文件（JPG / PNG / WebP / GIF）')
      return
    }
    if (file.size > 5 * 1024 * 1024) {
      message.error('图片不能超过 5MB')
      return
    }
    setAvatarUploading(true)
    try {
      const objectKey = await uploadAdminUserAvatar(editingUser.id, file)
      userForm.setFieldsValue({ avatarUrl: objectKey })
      const preview = await signObjectKeysForPreview([objectKey])
      setEditAvatarPreview(preview)
      message.success('头像已上传至 OSS，点击保存写入用户资料')
    } catch (e: any) {
      console.error('avatar upload failed', e?.message)
      message.error(e.message || '头像上传失败')
    } finally {
      setAvatarUploading(false)
    }
  }

  const clearEditAvatar = () => {
    userForm.setFieldsValue({ avatarUrl: '' })
    setEditAvatarPreview(null)
  }

  const openUserEditModal = (user: UserRow) => {
    setEditingUser(user)
    setEditAvatarPreview(signedAvatars[user.id] ?? null)
    userForm.setFieldsValue({
      id: user.id,
      email: user.email,
      nickname: user.nickname ?? '',
      birthYear: user.birthYear ?? undefined,
      countryCode: user.countryCode ?? undefined,
      bio: user.bio ?? '',
      status: Number(user.status ?? 1),
      avatarUrl: user.avatarUrl ?? '',
      isVip: !!user.isVip,
    })
    setUserModalOpen(true)
  }

  const submitUserSave = async () => {
    try {
      const v = await userForm.validateFields()
      setSavingUser(true)
      // AdminUserSaveInDto 无 gender 字段，编辑侧不提交性别
      const body: {
        id: number
        nickname?: string
        birthYear?: number
        countryCode?: string
        bio?: string
        status?: number
        avatarUrl?: string
      } = { id: Number(v.id) }
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
      if (v.avatarUrl !== undefined) {
        body.avatarUrl = typeof v.avatarUrl === 'string' ? v.avatarUrl.trim() : ''
      }
      await api.saveUser(body)
      message.success('用户已更新')
      setUserModalOpen(false)
      setEditingUser(null)
      setEditAvatarPreview(null)
      userForm.resetFields()
      void load()
    } catch (e: any) {
      if (e?.errorFields) return
      console.error('saveUser failed', e?.message)
      message.error(e.message || '保存失败')
    } finally {
      setSavingUser(false)
    }
  }

  const batchStatus = async (status: number) => {
    if (!selectedIds.length) {
      message.warning('请先勾选用户')
      return
    }
    try {
      await api.userBatchStatus(selectedIds, status)
      message.success(status === 2 ? '已批量封禁' : '已批量解封')
      void load()
    } catch (e: any) {
      console.error('userBatchStatus failed', e?.message)
      message.error(e.message || '批量操作失败')
    }
  }

  const columns: ColumnsType<UserRow> = useMemo(
    () => [
      { title: 'ID', dataIndex: 'id', width: 72 },
      {
        title: '头像',
        width: 88,
        render: (_, r) => {
          const src = signedAvatars[r.id]
          const audit = AVATAR_AUDIT_LABEL[r.avatarAuditStatus ?? 1] ?? AVATAR_AUDIT_LABEL[1]
          return (
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4 }}>
              {src ? (
                <Image
                  width={48}
                  height={48}
                  src={src}
                  style={{ objectFit: 'cover', borderRadius: '50%', border: '2px solid #d4c4a8' }}
                  preview
                />
              ) : (
                <Avatar size={48} icon={<UserOutlined />} style={{ background: '#8b9a7a' }} />
              )}
              {r.avatarUrl ? <Tag color={audit.color}>{audit.label}</Tag> : <Text type="secondary">无</Text>}
            </div>
          )
        },
      },
      { title: '邮箱', dataIndex: 'email', ellipsis: true },
      { title: '昵称', dataIndex: 'nickname', width: 120 },
      { title: '国家', dataIndex: 'countryCode', width: 72 },
      {
        title: '状态',
        dataIndex: 'status',
        width: 80,
        render: (v: number) => {
          const opt = USER_STATUS_OPTIONS.find((o) => o.value === v)
          const color = v === 1 ? 'green' : v === 2 ? 'red' : 'default'
          return <Tag color={color}>{opt?.label ?? v}</Tag>
        },
      },
      {
        title: 'VIP',
        dataIndex: 'isVip',
        width: 56,
        render: (v: boolean | undefined) => (v ? <Tag color="gold">VIP</Tag> : null),
      },
      {
        title: '管理后台',
        dataIndex: 'staffRole',
        width: 88,
        render: (v: number | null | undefined) =>
          v != null && v !== 0 ? <Tag color="blue">管理员</Tag> : <Text type="secondary">否</Text>,
      },
      {
        title: '操作',
        fixed: 'right',
        width: 300,
        render: (_, r) => {
          const hasAvatar = !!r.avatarUrl?.trim()
          const audit = r.avatarAuditStatus ?? (hasAvatar ? 1 : 0)
          return (
            <Space wrap size={[4, 4]}>
              <Button size="small" onClick={() => openUserEditModal(r)}>
                编辑
              </Button>
              <Tooltip title={!hasAvatar ? '无头像' : audit === 1 ? '已通过' : '通过审核'}>
                <Button
                  size="small"
                  type="primary"
                  disabled={!hasAvatar || audit === 1}
                  onClick={async () => {
                    try {
                      await api.approveUserAvatar(r.id)
                      message.success('头像已通过')
                      void load()
                    } catch (e: any) {
                      message.error(e.message)
                    }
                  }}
                >
                  头像通过
                </Button>
              </Tooltip>
              <Tooltip title={!hasAvatar ? '无头像' : audit === 2 ? '已驳回' : '驳回头像'}>
                <Button
                  size="small"
                  danger
                  disabled={!hasAvatar || audit === 2}
                  onClick={async () => {
                    try {
                      await api.rejectUserAvatar(r.id)
                      message.success('头像已驳回')
                      void load()
                    } catch (e: any) {
                      message.error(e.message)
                    }
                  }}
                >
                  头像驳回
                </Button>
              </Tooltip>
              <Button size="small" onClick={() => openDeviceModal(r)}>
                设备拉黑
              </Button>
              {isStaff(r) ? (
                <Tooltip title="管理员账号不可删除">
                  <Button size="small" danger disabled>
                    删除
                  </Button>
                </Tooltip>
              ) : (
                <Popconfirm
                  title="确认删除该用户？"
                  description="删除后该账号将被软删除，不可登录。"
                  onConfirm={async () => {
                    try {
                      await api.deleteUser(r.id)
                      message.success('用户已删除')
                      void load()
                    } catch (e: any) {
                      message.error(e.message)
                    }
                  }}
                  okButtonProps={{ danger: true }}
                >
                  <Button size="small" danger>
                    删除
                  </Button>
                </Popconfirm>
              )}
            </Space>
          )
        },
      },
    ],
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [signedAvatars, load],
  )

  const filterItems = (
    <>
      <Col xs={24} sm={12} md={8} lg={6}>
        <Form.Item name="email" label="邮箱">
          <Input allowClear placeholder="模糊搜索" />
        </Form.Item>
      </Col>
      <Col xs={24} sm={12} md={8} lg={6}>
        <Form.Item name="nickname" label="昵称">
          <Input allowClear placeholder="模糊搜索" />
        </Form.Item>
      </Col>
      <Col xs={24} sm={12} md={8} lg={6}>
        <Form.Item name="status" label="状态">
          <EnumSelect options={USER_STATUS_OPTIONS} placeholder="全部" />
        </Form.Item>
      </Col>
      <Col xs={24} sm={12} md={8} lg={6}>
        <Form.Item name="gender" label="性别">
          <EnumSelect options={GENDER_OPTIONS} placeholder="全部" />
        </Form.Item>
      </Col>
      <Col xs={24} sm={12} md={8} lg={6}>
        <Form.Item name="countryCode" label="国家">
          <EnumSelect options={countryOptions} placeholder="全部" />
        </Form.Item>
      </Col>
      <Col xs={24} sm={12} md={8} lg={6}>
        <Form.Item name="minBirthYear" label="出生年起">
          <InputNumber style={{ width: '100%' }} placeholder="如 1950" />
        </Form.Item>
      </Col>
      <Col xs={24} sm={12} md={8} lg={6}>
        <Form.Item name="maxBirthYear" label="出生年止">
          <InputNumber style={{ width: '100%' }} placeholder="如 1990" />
        </Form.Item>
      </Col>
      <Col xs={24} sm={12} md={8} lg={6}>
        <Form.Item name="isVip" label="VIP">
          <Select
            allowClear
            placeholder="全部"
            options={[
              { value: true, label: '是' },
              { value: false, label: '否' },
            ]}
          />
        </Form.Item>
      </Col>
      <Col xs={24} sm={12} md={8} lg={6}>
        <Form.Item name="avatarAuditStatus" label="头像审核">
          <EnumSelect options={AVATAR_AUDIT_OPTIONS} placeholder="全部" />
        </Form.Item>
      </Col>
      <Col xs={24} sm={12} md={8} lg={6}>
        <Form.Item name="createdRange" label="注册时间">
          <RangePicker style={{ width: '100%' }} />
        </Form.Item>
      </Col>
      <Col xs={24} sm={12} md={8} lg={6}>
        <Form.Item name="lastLoginRange" label="最后登录">
          <RangePicker style={{ width: '100%' }} />
        </Form.Item>
      </Col>
    </>
  )

  return (
    <div>
      <div className="page-header">
        <h2 className="page-title">用户列表</h2>
      </div>
      <AdminProTable<UserRow>
        filterForm={filterForm}
        filterItems={filterItems}
        onSearch={() => void load(1, pageSize)}
        toolbar={
          <Space wrap>
            <Button danger disabled={!selectedIds.length} onClick={() => void batchStatus(2)}>
              批量封禁
            </Button>
            <Button disabled={!selectedIds.length} onClick={() => void batchStatus(1)}>
              批量解封
            </Button>
            <Button onClick={() => void load()}>刷新</Button>
          </Space>
        }
        columns={columns}
        dataSource={rows}
        loading={loading}
        total={total}
        page={page}
        pageSize={pageSize}
        onPageChange={(p, ps) => void load(p, ps)}
        rowSelection={{
          selectedRowKeys: selectedIds,
          onChange: (keys) => setSelectedIds(keys.map(Number)),
        }}
        scrollX={1200}
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
          setEditAvatarPreview(null)
          userForm.resetFields()
        }}
        confirmLoading={savingUser}
        okText="保存"
        destroyOnClose
        width={600}
      >
        <Form form={userForm} layout="vertical" style={{ marginTop: 12 }}>
          <Form.Item name="id" hidden>
            <Input readOnly />
          </Form.Item>
          <Form.Item label="邮箱" name="email">
            <Input disabled />
          </Form.Item>
          <Form.Item name="avatarUrl" hidden>
            <Input />
          </Form.Item>
          <Form.Item label="头像" extra="先通过 put-sign 直传 OSS，保存后自动通过审核。">
            <div
              style={{
                display: 'flex',
                flexWrap: 'wrap',
                alignItems: 'center',
                gap: 16,
                padding: 14,
                background: 'linear-gradient(145deg, #f8f3ea 0%, #efe6d6 100%)',
                borderRadius: 12,
                border: '1px solid #d4c4a8',
              }}
            >
              {editAvatarPreview ? (
                <Image
                  width={88}
                  height={88}
                  src={editAvatarPreview}
                  style={{ objectFit: 'cover', borderRadius: '50%', border: '2px solid #8b9a7a' }}
                  preview
                />
              ) : (
                <Avatar size={88} icon={<UserOutlined />} style={{ background: '#8b9a7a' }} />
              )}
              <Space direction="vertical" size={8}>
                <Upload
                  accept="image/jpeg,image/png,image/webp,image/gif"
                  showUploadList={false}
                  disabled={avatarUploading || savingUser}
                  beforeUpload={(file) => {
                    void handleAvatarUpload(file)
                    return false
                  }}
                >
                  <Button
                    type="primary"
                    icon={avatarUploading ? <LoadingOutlined /> : <PlusOutlined />}
                    loading={avatarUploading}
                    disabled={savingUser}
                  >
                    {avatarUploading ? '上传中…' : '选择并上传头像'}
                  </Button>
                </Upload>
                <Button
                  size="small"
                  danger
                  icon={<DeleteOutlined />}
                  disabled={avatarUploading || savingUser || !userForm.getFieldValue('avatarUrl')}
                  onClick={clearEditAvatar}
                >
                  清空头像
                </Button>
              </Space>
            </div>
          </Form.Item>
          <Form.Item label="昵称" name="nickname" rules={[{ required: true, message: '请输入昵称' }]}>
            <Input maxLength={32} />
          </Form.Item>
          <Form.Item label="出生年份" name="birthYear">
            <InputNumber style={{ width: '100%' }} placeholder="例如 1980" />
          </Form.Item>
          <Form.Item label="国家" name="countryCode">
            <EnumSelect options={countryOptions} placeholder="选择国家" />
          </Form.Item>
          <Form.Item label="个人简介" name="bio">
            <Input.TextArea maxLength={300} rows={3} />
          </Form.Item>
          <Form.Item label="状态" name="status">
            <EnumSelect options={USER_STATUS_OPTIONS} allowClear={false} />
          </Form.Item>
          <Form.Item label="VIP 调试">
            <Space wrap>
              <Button
                size="small"
                type="primary"
                onClick={async () => {
                  if (!editingUser) return
                  try {
                    await api.userVipDebug(editingUser.id, {
                      isVip: true,
                      vipExpireAt: dayjs().add(30, 'day').toISOString(),
                    })
                    message.success('已开通 VIP（30 天）')
                    void load()
                  } catch (e: any) {
                    message.error(e.message)
                  }
                }}
              >
                开通 VIP 30 天
              </Button>
              <Button
                size="small"
                danger
                onClick={async () => {
                  if (!editingUser) return
                  try {
                    await api.userVipDebug(editingUser.id, { isVip: false, clearVipExpireAt: true })
                    message.success('已清除 VIP')
                    void load()
                  } catch (e: any) {
                    message.error(e.message)
                  }
                }}
              >
                清除 VIP
              </Button>
            </Space>
          </Form.Item>
        </Form>
      </Modal>
    </div>
  )
}
