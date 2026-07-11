import { MenuFoldOutlined, MenuUnfoldOutlined, UserOutlined } from '@ant-design/icons'
import type { MenuProps } from 'antd'
import { Avatar, Button, Layout, Menu, Space, Typography, theme } from 'antd'
import { useEffect, useMemo, useState } from 'react'
import { Link, Navigate, Route, Routes, useLocation, useNavigate } from 'react-router-dom'
import Dashboard from './Dashboard'
import AnnouncementList from './config/AnnouncementList'
import ConfigList from './config/List'
import SensitiveWordList from './config/SensitiveWordList'
import VersionList from './config/VersionList'
import VipConfig from './config/VipConfig'
import MatchConfig from './config/MatchConfig'
import LetterConfig from './config/LetterConfig'
import CommerceProductList from './config/CommerceProductList'
import ModerationConfig from './config/ModerationConfig'
import TimeLetterList from './content/TimeLetterList'
import LetterList from './content/LetterList'
import ActionLogList from './log/ActionLogList'
import LoginLogList from './log/LoginLogList'
import AdminOperationLogList from './log/AdminOperationLogList'
import OutboxList from './mail/OutboxList'
import PenpalList from './relation/PenpalList'
import ReportList from './report/List'
import UserList from './user/List'
import FeedbackList from './user/FeedbackList'
import CountryList from './config/CountryList'
import { api } from '../services/api'

const { Header, Sider, Content } = Layout

function flatLeafKeys(nodes: MenuProps['items']): string[] {
  const keys: string[] = []
  const walk = (list: MenuProps['items']) => {
    for (const n of list || []) {
      if (!n) continue
      if ('children' in n && n.children?.length) {
        walk(n.children)
      } else if ('key' in n && n.key != null) {
        keys.push(String(n.key))
      }
    }
  }
  walk(nodes)
  return keys
}

export default function AdminLayout() {
  const nav = useNavigate()
  const loc = useLocation()
  const [collapsed, setCollapsed] = useState(false)
  const [adminLabel, setAdminLabel] = useState('')
  const token = localStorage.getItem('admin_token')
  const {
    token: { colorBgContainer, borderRadiusLG },
  } = theme.useToken()

  const menuItems = useMemo<MenuProps['items']>(
    () => [
      { key: '/', label: <Link to="/">看板</Link> },
      {
        key: 'grp-user',
        label: '用户管理',
        children: [
          { key: '/user', label: <Link to="/user">用户列表</Link> },
          { key: '/user/feedback', label: <Link to="/user/feedback">用户反馈</Link> },
        ],
      },
      {
        key: 'grp-content',
        label: '内容审核',
        children: [
          { key: '/content/letter', label: <Link to="/content/letter">普通信件</Link> },
          { key: '/content/time-letter', label: <Link to="/content/time-letter">时光信</Link> },
          { key: '/report', label: <Link to="/report">举报处理</Link> },
        ],
      },
      {
        key: 'grp-relation',
        label: '关系运营',
        children: [
          { key: '/relation/penpal', label: <Link to="/relation/penpal">笔友关系</Link> },
        ],
      },
      {
        key: 'grp-mail',
        label: '系统邮件',
        children: [
          { key: '/mail/outbox', label: <Link to="/mail/outbox">出站邮件</Link> },
        ],
      },
      {
        key: 'grp-config',
        label: '系统配置',
        children: [
          { key: '/config/list', label: <Link to="/config/list">参数配置</Link> },
          { key: '/config/country', label: <Link to="/config/country">国家/地区</Link> },
          { key: '/config/sensitive', label: <Link to="/config/sensitive">敏感词</Link> },
          { key: '/config/version', label: <Link to="/config/version">版本管理</Link> },
          { key: '/config/announcement', label: <Link to="/config/announcement">公告管理</Link> },
          { key: '/config/vip', label: <Link to="/config/vip">VIP 配置</Link> },
          { key: '/config/match', label: <Link to="/config/match">匹配配置</Link> },
          { key: '/config/letter', label: <Link to="/config/letter">信件配置</Link> },
          { key: '/config/commerce', label: <Link to="/config/commerce">商业商品</Link> },
          { key: '/config/moderation', label: <Link to="/config/moderation">内容安全</Link> },
        ],
      },
      {
        key: 'grp-log',
        label: '日志审计',
        children: [
          { key: '/log/action', label: <Link to="/log/action">行为日志</Link> },
          { key: '/log/login', label: <Link to="/log/login">登录日志</Link> },
          { key: '/log/admin-operation', label: <Link to="/log/admin-operation">管理员操作</Link> },
        ],
      },
    ],
    [],
  )

  const leafKeys = useMemo(() => flatLeafKeys(menuItems), [menuItems])

  useEffect(() => {
    if (!token) return
    api
      .currentAdmin()
      .then((u: any) => setAdminLabel(u?.username || u?.nickname || ''))
      .catch(() => setAdminLabel(''))
  }, [token])

  if (!token) return <Navigate to="/login" replace />

  const selected = (() => {
    const matches = leafKeys.filter((k) => (k === '/' ? loc.pathname === '/' : loc.pathname.startsWith(k)))
    matches.sort((a, b) => b.length - a.length)
    return matches[0] ?? '/'
  })()

  const defaultOpenKeys = useMemo(
    () => ['grp-user', 'grp-content', 'grp-relation', 'grp-mail', 'grp-config', 'grp-log'],
    [],
  )

  return (
    <Layout style={{ minHeight: '100%' }}>
      <Sider trigger={null} collapsible collapsed={collapsed} style={{ boxShadow: '2px 0 8px rgba(0,21,41,0.15)' }}>
        <div style={{
          height: 64,
          display: 'flex',
          alignItems: 'center',
          justifyContent: collapsed ? 'center' : 'flex-start',
          padding: collapsed ? 0 : '0 20px',
          overflow: 'hidden',
          borderBottom: '1px solid rgba(255,255,255,0.08)',
        }}>
          <div style={{
            width: 32, height: 32,
            borderRadius: 8,
            background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            flexShrink: 0,
            fontSize: 15, color: '#fff', fontWeight: 700,
          }}>S</div>
          {!collapsed && (
            <Typography.Text style={{ color: '#fff', fontWeight: 600, marginLeft: 10, fontSize: 15, whiteSpace: 'nowrap' }}>
              Senior Post
            </Typography.Text>
          )}
        </div>
        <Menu
          theme="dark"
          mode="inline"
          selectedKeys={[selected]}
          defaultOpenKeys={defaultOpenKeys}
          items={menuItems}
          style={{ borderRight: 0 }}
        />
      </Sider>
      <Layout>
        <Header style={{
          padding: '0 16px 0 0',
          background: colorBgContainer,
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          boxShadow: '0 1px 4px rgba(0,21,41,0.08)',
          zIndex: 10,
          position: 'sticky',
          top: 0,
        }}>
          <Button
            type="text"
            icon={collapsed ? <MenuUnfoldOutlined /> : <MenuFoldOutlined />}
            onClick={() => setCollapsed(!collapsed)}
            style={{ fontSize: 16, width: 64, height: 64 }}
          />
          <Space size={12}>
            {adminLabel ? (
              <Space size={8}>
                <Avatar size={28} icon={<UserOutlined />} style={{ background: '#1677ff' }} />
                <Typography.Text style={{ fontSize: 13 }}>{adminLabel}</Typography.Text>
              </Space>
            ) : null}
            <Button
              size="small"
              onClick={() => {
                localStorage.removeItem('admin_token')
                nav('/login')
              }}
            >
              退出
            </Button>
          </Space>
        </Header>
        <Content style={{ margin: '16px', padding: 24, minHeight: 280, background: colorBgContainer, borderRadius: borderRadiusLG }}>
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/user" element={<UserList />} />
            <Route path="/user/feedback" element={<FeedbackList />} />
            <Route path="/content/letter" element={<LetterList />} />
            <Route path="/content/time-letter" element={<TimeLetterList />} />
            <Route path="/relation/penpal" element={<PenpalList />} />
            <Route path="/mail/outbox" element={<OutboxList />} />
            <Route path="/report" element={<ReportList />} />
            <Route path="/config/list" element={<ConfigList />} />
            <Route path="/config/country" element={<CountryList />} />
            <Route path="/config/sensitive" element={<SensitiveWordList />} />
            <Route path="/config/version" element={<VersionList />} />
            <Route path="/config/announcement" element={<AnnouncementList />} />
            <Route path="/config/vip" element={<VipConfig />} />
            <Route path="/config/match" element={<MatchConfig />} />
            <Route path="/config/letter" element={<LetterConfig />} />
            <Route path="/config/commerce" element={<CommerceProductList />} />
            <Route path="/config/moderation" element={<ModerationConfig />} />
            <Route path="/log/action" element={<ActionLogList />} />
            <Route path="/log/login" element={<LoginLogList />} />
            <Route path="/log/admin-operation" element={<AdminOperationLogList />} />
          </Routes>
        </Content>
      </Layout>
    </Layout>
  )
}
