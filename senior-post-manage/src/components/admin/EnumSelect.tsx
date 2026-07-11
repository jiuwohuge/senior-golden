import { Select } from 'antd'
import type { SelectProps } from 'antd'

export type EnumOption = { value: string | number; label: string }

type Props = Omit<SelectProps, 'options'> & {
  options: EnumOption[]
}

/** 枚举下拉：禁止手输，统一运营端固定类别选择。 */
export default function EnumSelect({ options, allowClear = true, ...rest }: Props) {
  return (
    <Select
      allowClear={allowClear}
      showSearch
      optionFilterProp="label"
      options={options.map((o) => ({ value: o.value, label: o.label }))}
      {...rest}
    />
  )
}

/** 按 value 取中文标签；未知码回退原文。 */
export function labelOf(options: EnumOption[], value: string | number | null | undefined): string {
  if (value === null || value === undefined || value === '') return '—'
  const hit = options.find((o) => o.value === value || String(o.value) === String(value))
  return hit?.label ?? String(value)
}

export const USER_STATUS_OPTIONS: EnumOption[] = [
  { value: 1, label: '正常' },
  { value: 2, label: '封禁' },
  { value: 3, label: '注销' },
]

export const GENDER_OPTIONS: EnumOption[] = [
  { value: 1, label: '男' },
  { value: 2, label: '女' },
]

export const AVATAR_AUDIT_OPTIONS: EnumOption[] = [
  { value: 0, label: '待审核' },
  { value: 1, label: '已通过' },
  { value: 2, label: '已驳回' },
]

export const LETTER_MODE_OPTIONS: EnumOption[] = [
  { value: 1, label: '邮局匹配' },
  { value: 2, label: '直寄' },
  { value: 3, label: '时光信' },
]

export const LETTER_AUDIT_OPTIONS: EnumOption[] = [
  { value: 0, label: '待审' },
  { value: 1, label: '通过' },
  { value: 2, label: '拒绝' },
]

export const LETTER_STATUS_OPTIONS: EnumOption[] = [
  { value: 0, label: '待处理' },
  { value: 1, label: '投递中' },
  { value: 2, label: '已送达' },
  { value: 3, label: '挂号' },
  { value: 4, label: '已匹配' },
  { value: 5, label: '已读' },
  { value: 6, label: '已回复' },
  { value: 7, label: '已归档' },
  { value: 8, label: '已预约' },
]

export const MAIL_OUTBOX_STATUS_OPTIONS: EnumOption[] = [
  { value: 'pending', label: '待发送' },
  { value: 'sending', label: '发送中' },
  { value: 'sent', label: '已发送' },
  { value: 'failed', label: '发送失败' },
]

export const PRODUCT_TYPE_OPTIONS: EnumOption[] = [
  { value: 'skin', label: '皮肤' },
  { value: 'font', label: '字体' },
  { value: 'template', label: '模板' },
  { value: 'export', label: '导出' },
  { value: 'vip_bundle', label: 'VIP 包' },
]

export const PRODUCT_STATUS_OPTIONS: EnumOption[] = [
  { value: 1, label: '上架' },
  { value: 0, label: '下架' },
]

export const REPORT_STATUS_OPTIONS: EnumOption[] = [
  { value: 0, label: '待处理' },
  { value: 1, label: '已处理' },
  { value: 2, label: '已驳回' },
]

export const REPORT_TARGET_TYPE_OPTIONS: EnumOption[] = [
  { value: 'user', label: '用户' },
  { value: 'letter', label: '信件' },
]

export const ACTION_TYPE_OPTIONS: EnumOption[] = [
  { value: 'send_letter', label: '发信' },
  { value: 'open_letter', label: '开信' },
  { value: 'reply_letter', label: '回信' },
  { value: 'login', label: '登录' },
  { value: 'add_penpal_request', label: '申请笔友' },
  { value: 'accept_penpal', label: '接受笔友' },
  { value: 'reject_penpal', label: '拒绝笔友' },
  { value: 'view_recommendation', label: '查看推荐' },
  { value: 'write_from_recommendation', label: '从推荐写信' },
  { value: 'mock_purchase', label: '模拟购买' },
]

export const ACTION_TARGET_TYPE_OPTIONS: EnumOption[] = [
  { value: 'letter', label: '信件' },
  { value: 'user', label: '用户' },
]

export const LOGIN_RESULT_OPTIONS: EnumOption[] = [
  { value: 'success', label: '成功' },
  { value: 'fail', label: '失败' },
  { value: 'failed', label: '失败' },
  { value: 1, label: '成功' },
  { value: 0, label: '失败' },
]
