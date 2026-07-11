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
  { value: 1, label: 'POST_OFFICE' },
  { value: 2, label: 'DIRECT' },
  { value: 3, label: 'SELF_TIME' },
]

export const LETTER_AUDIT_OPTIONS: EnumOption[] = [
  { value: 0, label: '待审' },
  { value: 1, label: '通过' },
  { value: 2, label: '拒绝' },
]

export const LETTER_STATUS_OPTIONS: EnumOption[] = [
  { value: 0, label: 'PENDING' },
  { value: 1, label: 'DELIVERING' },
  { value: 2, label: 'DELIVERED' },
  { value: 3, label: 'REGISTERED' },
  { value: 4, label: 'MATCHED' },
  { value: 5, label: 'READ' },
  { value: 6, label: 'REPLIED' },
  { value: 7, label: 'ARCHIVED' },
  { value: 8, label: 'SCHEDULED' },
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
