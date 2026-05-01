import { Navigate, Route, Routes } from 'react-router-dom'
import AdminLayout from './pages/AdminLayout'
import Login from './pages/Login'

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route path="/*" element={<AdminLayout />} />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  )
}
