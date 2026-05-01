import { Routes, Route, Navigate } from 'react-router-dom'
import Login from './pages/Login'
import AdminLayout from './pages/AdminLayout'
import Dashboard from './pages/Dashboard'
import UserList from './pages/user/List'
import PostcardList from './pages/content/PostcardList'
import CommentList from './pages/content/CommentList'
import ReportList from './pages/report/List'
import ConfigList from './pages/config/List'
import VipConfig from './pages/config/VipConfig'
import SensitiveWordList from './pages/config/SensitiveWordList'
import AnnouncementList from './pages/config/AnnouncementList'
import VersionList from './pages/config/VersionList'
import LoginLogList from './pages/log/LoginLogList'
import ActionLogList from './pages/log/ActionLogList'
import { useAuthStore } from './store/auth'

const ProtectedRoute = ({ children }: { children: React.ReactNode }) => {
  const token = useAuthStore((state) => state.token)
  if (!token) {
    return <Navigate to="/login" replace />
  }
  return <>{children}</>
}

const App = () => {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route
        path="/*"
        element={
          <ProtectedRoute>
            <AdminLayout />
          </ProtectedRoute>
        }
      />
    </Routes>
  )
}

export default App