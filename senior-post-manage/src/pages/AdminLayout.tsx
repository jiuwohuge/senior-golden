import { useNavigate, useLocation, MenuProps } from 'react-router-dom'
import { Layout, Menu, Avatar, Dropdown } from 'antd'
import {
  DashboardOutlined,
  UserOutlined,
  FileTextOutlined,
  WarningOutlined,
  SettingOutlined,
  LogoutOutlined,
  HistoryOutlined,
} from '@ant-design/icons'
import { useAuthStore } from '../store/auth'
import { Outlet } from 'react-router-dom'

const { Header, Sider, Content } = Layout

const menuItems: MenuProps['items'] = [
  {
    key: '/',
    icon: <DashboardOutlined />,
    label: '数据看板',
  },
  {
    key: 'user',
    icon: <UserOutlined />,
    label: '用户管理',
    children: [{ key: '/user', label: '用户列表' }],
  },
  {
    key: 'content',
    icon: <FileTextOutlined />,
    label: '内容管理',
    children: [
      { key: '/postcard', label: '明信片管理' },
      { key: '/comment', label: '评论管理' },
    ],
  },
  {
    key: 'report',
    icon: <WarningOutlined />,
    label: '举报管理',
    children: [{ key: '/report', label: '举报工单' }],
  },
  {
    key: 'config',
    icon: <SettingOutlined />,
    label: '配置中心',
    children: [
      { key: '/config/stamps', label: '邮票配置' },
      { key: '/config/vip', label: 'VIP权益' },
      { key: '/config/system', label: '系统配置' },
      { key: '/config/sensitive', label: '敏感词管理' },
      { key: '/config/announcement', label: '公告管理' },
      { key: '/config/version', label: '版本管理' },
    ],
  },
  {
    key: 'log',
    icon: <HistoryOutlined />,
    label: '日志查看',
    children: [
      { key: '/log/login', label: '登录日志' },
      { key: '/log/action', label: '行为日志' },
    ],
  },
]

const AdminLayout = () => {
  const navigate = useNavigate()
  const location = useLocation()
  const { admin, logout } = useAuthStore()

  const selectedKey = location.pathname === '/' ? '/' : '/' + location.pathname.split('/')[1]

  const userMenu: MenuProps['items'] = [
    {
      key: 'logout',
      icon: <LogoutOutlined />,
      label: '退出登录',
      danger: true,
    },
  ]

  const handleMenuClick: MenuProps['onClick'] = ({ key }) => {
    if (key === 'logout') {
      logout()
      navigate('/login')
    }
  }

  return (
    <Layout style={{ height: '100vh' }}>
      <Header
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          background: '#001529',
          padding: '0 24px',
        }}
      >
        <div style={{ color: 'white', fontSize: 18, fontWeight: 'bold' }}>Senior Post Admin</div>
        <Dropdown menu={{ items: userMenu, onClick: handleMenuClick }} placement="bottomRight">
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, cursor: 'pointer' }}>
            <Avatar icon={<UserOutlined />} />
            <span style={{ color: 'white' }}>{admin?.nickname || admin?.username}</span>
          </div>
        </Dropdown>
      </Header>
      <Layout>
        <Sider width={220} style={{ background: '#fff', overflow: 'auto' }}>
          <Menu
            mode="inline"
            selectedKeys={[selectedKey]}
            defaultOpenKeys={['user', 'content', 'report', 'config', 'log']}
            items={menuItems}
            onClick={({ key }) => navigate(key)}
            style={{ height: '100%', borderRight: 0 }}
          />
        </Sider>
        <Content style={{ padding: 24, overflow: 'auto', background: '#f0f2f5' }}>
          <Outlet />
        </Content>
      </Layout>
    </Layout>
  )
}

export default AdminLayout