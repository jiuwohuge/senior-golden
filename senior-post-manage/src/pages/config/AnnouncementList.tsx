import { PlusOutlined } from '@ant-design/icons'
import { Button, Form, Input, InputNumber, Modal, Popconfirm, Space, Switch, Table, Tag, Typography, message } from 'antd'
import { useCallback, useEffect, useState } from 'react'
import { api } from '../../services/api'

const { Text } = Typography

function ReleasePreview(props: { title?: string; versionLabel?: string; releaseNotes?: string }) {
  const t = props.title?.trim() || '（标题）'
  const v = props.versionLabel?.trim() || '（版本号）'
  const body = props.releaseNotes ?? ''
  return (
    <div style={{ border: '1px solid #f0f0f0', borderRadius: 8, padding: 12, background: '#fafafa' }}>
      <Text strong style={{ fontSize: 16 }}>{t}</Text>
      <div style={{ marginTop: 8 }}>
        <Text type="secondary">{v}</Text>
      </div>
      <pre style={{ marginTop: 12, whiteSpace: 'pre-wrap', wordBreak: 'break-word', fontFamily: 'inherit' }}>{body}</pre>
    </div>
  )
}

export default function AnnouncementList() {
  const [rows, setRows] = useState<any[]>([])
  const [total, setTotal] = useState(0)
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(20)
  const [loading, setLoading] = useState(false)
  const [modalOpen, setModalOpen] = useState(false)
  const [saving, setSaving] = useState(false)
  const [form] = Form.useForm()
  const titleW = Form.useWatch('title', form)
  const versionW = Form.useWatch('versionLabel', form)
  const contentW = Form.useWatch('content', form)

  const load = useCallback(() => {
    setLoading(true)
    api
      .announcements({ page: { page, size: pageSize } })
      .then((d: any) => {
        setRows(d.records || [])
        setTotal(d.total ?? 0)
      })
      .catch((e: any) => message.error(e.message))
      .finally(() => setLoading(false))
  }, [page, pageSize])

  useEffect(() => {
    void load()
  }, [load])

  const handleOk = async () => {
    try {
      const v = await form.validateFields()
      if (v.content && String(v.content).includes('<')) {
        message.error('更新说明不可包含「<」（禁止 HTML）')
        return
      }
      if (v.id === '' || v.id === undefined || v.id === null) {
        delete (v as any).id
      }
      setSaving(true)
      await api.saveAnnouncement(v)
      setModalOpen(false)
      form.resetFields()
      load()
    } catch (e: any) {
      if (e?.errorFields) return
      message.error(e.message)
    } finally {
      setSaving(false)
    }
  }

  return (
    <>
      <div className="page-header">
        <h2 className="page-title">公告管理</h2>
        <Button type="primary" icon={<PlusOutlined />} onClick={() => { form.resetFields(); setModalOpen(true) }}>
          新增公告
        </Button>
      </div>
      <Table
        rowKey="id"
        loading={loading}
        dataSource={rows}
        size="middle"
        pagination={{
          current: page,
          pageSize,
          total,
          showSizeChanger: true,
          showTotal: (t) => `共 ${t} 条`,
          onChange: (p, ps) => {
            setPage(p)
            setPageSize(ps)
          },
        }}
        columns={[
          { title: '标题', dataIndex: 'title' },
          { title: '版本号', dataIndex: 'versionLabel', width: 120, render: (v: string) => v || '—' },
          {
            title: '版本区间',
            width: 140,
            render: (_: unknown, r: any) => {
              const lo = r.minVersionCode
              const hi = r.maxVersionCode
              if (lo == null && hi == null) return '—'
              return `${lo ?? '—'} ~ ${hi ?? '—'}`
            },
          },
          {
            title: '状态',
            dataIndex: 'isActive',
            width: 88,
            render: (v: boolean) => v ? <Tag color="green">启用</Tag> : <Tag color="default">停用</Tag>,
          },
          {
            title: '操作',
            width: 100,
            render: (_, r) => (
              <Space>
                <Button
                  size="small"
                  onClick={() => {
                    form.setFieldsValue({
                      ...r,
                      startAt: r.startAt ?? undefined,
                      endAt: r.endAt ?? undefined,
                    })
                    setModalOpen(true)
                  }}
                >
                  编辑
                </Button>
                <Popconfirm title="确认删除？" onConfirm={async () => { await api.deleteAnnouncement(r.id); load() }}>
                  <Button danger size="small">删除</Button>
                </Popconfirm>
              </Space>
            ),
          },
        ]}
      />
      <Modal
        title="新增 / 编辑公告（版本说明）"
        open={modalOpen}
        onOk={handleOk}
        onCancel={() => { setModalOpen(false); form.resetFields() }}
        confirmLoading={saving}
        destroyOnClose
        width={720}
      >
        <Form form={form} layout="vertical" style={{ marginTop: 16 }}>
          <Form.Item name="id" hidden>
            <Input />
          </Form.Item>
          <Form.Item name="title" label="标题" rules={[{ required: true, message: '请输入标题' }]}>
            <Input placeholder="如：本次更新" />
          </Form.Item>
          <Form.Item name="versionLabel" label="版本号（展示）" rules={[{ required: true, message: '请输入版本号' }]}>
            <Input placeholder="如：1.2.0" />
          </Form.Item>
          <Form.Item name="content" label="更新说明（纯文本多行）" rules={[{ required: true, message: '请输入更新说明' }]}>
            <Input.TextArea placeholder="一段一条，可用换行分段；禁止 HTML" rows={8} showCount maxLength={8000} />
          </Form.Item>
          <Space size="large" wrap>
            <Form.Item
              name="minVersionCode"
              label="可见最小 versionCode（含）"
              extra="当前 App 默认 versionCode=2；留空表示不限制"
            >
              <InputNumber min={0} placeholder="留空不限制" style={{ width: 200 }} />
            </Form.Item>
            <Form.Item
              name="maxVersionCode"
              label="可见最大 versionCode（含）"
              extra="若最小值大于最大值，保存将失败"
            >
              <InputNumber min={0} placeholder="留空不限制" style={{ width: 200 }} />
            </Form.Item>
          </Space>
          <Form.Item name="startAt" label="生效开始（可选）">
            <Input placeholder="ISO 8601，如 2026-05-01T00:00:00" />
          </Form.Item>
          <Form.Item name="endAt" label="生效结束（可选）">
            <Input placeholder="ISO 8601" />
          </Form.Item>
          <Form.Item name="isActive" label="状态" valuePropName="checked" initialValue={true}>
            <Switch checkedChildren="启用" unCheckedChildren="停用" />
          </Form.Item>
          <Text type="secondary">与 App 弹层结构一致的预览（非 Markdown）</Text>
          <div style={{ marginTop: 8 }}>
            <ReleasePreview
              title={titleW}
              versionLabel={versionW}
              releaseNotes={contentW}
            />
          </div>
        </Form>
      </Modal>
    </>
  )
}
