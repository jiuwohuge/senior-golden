import { Button, Card, Col, Form, Row, Space, Table } from 'antd'
import type { FormInstance, TableProps } from 'antd'
import type { ReactNode } from 'react'

type Props<T> = {
  filterForm?: FormInstance
  filterItems?: ReactNode
  onSearch?: () => void
  toolbar?: ReactNode
  rowKey?: string
  columns: TableProps<T>['columns']
  dataSource: T[]
  loading?: boolean
  total: number
  page: number
  pageSize: number
  onPageChange: (page: number, pageSize: number) => void
  rowSelection?: TableProps<T>['rowSelection']
  scrollX?: number | true
}

/** 短筛选字段默认栅格（Select / Enum / 数字 / 短文本）。 */
export const FILTER_COL_SHORT = { xs: 24, sm: 12, md: 8, lg: 6, xl: 4 } as const

/** 文本模糊搜索略宽。 */
export const FILTER_COL_TEXT = { xs: 24, sm: 12, md: 8, lg: 6, xl: 5 } as const

/** 日期区间需要更宽。 */
export const FILTER_COL_RANGE = { xs: 24, sm: 24, md: 12, lg: 8, xl: 6 } as const

/** 管理端统一列表壳：筛选区 + 工具栏 + 服务端分页表格。 */
export default function AdminProTable<T extends object>({
  filterForm,
  filterItems,
  onSearch,
  toolbar,
  rowKey = 'id',
  columns,
  dataSource,
  loading,
  total,
  page,
  pageSize,
  onPageChange,
  rowSelection,
  scrollX = 1100,
}: Props<T>) {
  return (
    <Space direction="vertical" size={16} style={{ width: '100%' }}>
      {(filterItems || toolbar) && (
        <Card size="small" styles={{ body: { paddingBlock: 12 } }}>
          {filterItems && filterForm && (
            <Form
              className="admin-filter-form"
              form={filterForm}
              layout="horizontal"
              size="small"
              colon={false}
              labelCol={{ flex: '0 0 auto' }}
              wrapperCol={{ flex: 1 }}
              labelAlign="right"
              onFinish={() => onSearch?.()}
              style={{ marginBottom: toolbar ? 12 : 0 }}
            >
              <Row gutter={[12, 8]} align="middle">
                {filterItems}
                <Col {...FILTER_COL_SHORT} style={{ display: 'flex', alignItems: 'center' }}>
                  <Form.Item className="admin-filter-actions" style={{ marginBottom: 0 }}>
                    <Space size={8}>
                      <Button type="primary" htmlType="submit" size="small">
                        查询
                      </Button>
                      <Button
                        size="small"
                        onClick={() => {
                          filterForm.resetFields()
                          onSearch?.()
                        }}
                      >
                        重置
                      </Button>
                    </Space>
                  </Form.Item>
                </Col>
              </Row>
            </Form>
          )}
          {toolbar}
        </Card>
      )}
      <Table<T>
        rowKey={rowKey}
        columns={columns}
        dataSource={dataSource}
        loading={loading}
        rowSelection={rowSelection}
        scroll={{ x: scrollX }}
        pagination={{
          current: page,
          pageSize,
          total,
          showSizeChanger: true,
          showTotal: (t) => `共 ${t} 条`,
          onChange: onPageChange,
        }}
      />
    </Space>
  )
}
