import { MenuFoldOutlined, MenuUnfoldOutlined } from '@ant-design/icons'
import type { MenuProps } from 'antd'
import { Button, Layout, Menu, Space, Typography, theme } from 'antd'
import { useEffect, useMemo, useState } from 'react'
import { Link, Navigate, Route, Routes, useLocation, useNavigate } from 'react-router-dom'
import Dashboard from './Dashboard'
import AnnouncementList from './config/AnnouncementList'
import ConfigList from './config/List'
import SensitiveWordList from './config/SensitiveWordList'
import VersionList from './config/VersionList'
import VipConfig from './config/VipConfig'
import CommentList from './content/CommentList'
import PostcardList from './content/PostcardList'
import ActionLogList from './log/ActionLogList'
import LoginLogList from './log/LoginLogList'
import ReportList from './report/List'
import UserList from './user/List'
import FeedbackList from './user/FeedbackList'
import StampLedgerList from './stamps/StampLedgerList'
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
          { key: '/stamps/ledger', label: <Link to="/stamps/ledger">邮票流水</Link> },
        ],
      },
      {
        key: 'grp-content',
        label: '内容审核',
        children: [
          { key: '/content/postcard', label: <Link to="/content/postcard">明信片审核</Link> },
          { key: '/content/comment', label: <Link to="/content/comment">评论审核</Link> },
          { key: '/report', label: <Link to="/report">明信片举报</Link> },
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
        ],
      },
      {
        key: 'grp-log',
        label: '日志审计',
        children: [
          { key: '/log/action', label: <Link to="/log/action">行为日志</Link> },
          { key: '/log/login', label: <Link to="/log/login">登录日志</Link> },
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

  const defaultOpenKeys = useMemo(() => ['grp-user', 'grp-content', 'grp-config', 'grp-log'], [])

  return (
    <Layout style={{ minHeight: '100%' }}>
      <Sider trigger={null} collapsible collapsed={collapsed}>
        <div style={{ color: '#fff', textAlign: 'center', lineHeight: '48px', fontWeight: 600 }}>Senior Post</div>
        <Menu
          theme="dark"
          mode="inline"
          selectedKeys={[selected]}
          defaultOpenKeys={defaultOpenKeys}
          items={menuItems}
        />
      </Sider>
      <Layout>
        <Header style={{ padding: 0, background: colorBgContainer, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Button
            type="text"
            icon={collapsed ? <MenuUnfoldOutlined /> : <MenuFoldOutlined />}
            onClick={() => setCollapsed(!collapsed)}
            style={{ fontSize: 16, width: 64, height: 64 }}
          />
          <Space style={{ marginRight: 16 }}>
            {adminLabel ? <Typography.Text type="secondary">{adminLabel}</Typography.Text> : null}
            <Button
              onClick={() => {
                localStorage.removeItem('admin_token')
                nav('/login')
              }}
            >
              退出
            </Button>
          </Space>
        </Header>
        <Content style={{ margin: '16px', padding: 16, minHeight: 280, background: colorBgContainer, borderRadius: borderRadiusLG }}>
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/user" element={<UserList />} />
            <Route path="/user/feedback" element={<FeedbackList />} />
            <Route path="/stamps/ledger" element={<StampLedgerList />} />
            <Route path="/content/postcard" element={<PostcardList />} />
            <Route path="/content/comment" element={<CommentList />} />
            <Route path="/report" element={<ReportList />} />
            <Route path="/config/list" element={<ConfigList />} />
            <Route path="/config/country" element={<CountryList />} />
            <Route path="/config/sensitive" element={<SensitiveWordList />} />
            <Route path="/config/version" element={<VersionList />} />
            <Route path="/config/announcement" element={<AnnouncementList />} />
            <Route path="/config/vip" element={<VipConfig />} />
            <Route path="/log/action" element={<ActionLogList />} />
            <Route path="/log/login" element={<LoginLogList />} />
          </Routes>
        </Content>
      </Layout>
    </Layout>
  )
}
