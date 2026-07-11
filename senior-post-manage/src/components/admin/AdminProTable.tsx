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
        <Card size="small">
          {filterItems && filterForm && (
            <Form
              form={filterForm}
              layout="vertical"
              onFinish={() => onSearch?.()}
              style={{ marginBottom: toolbar ? 12 : 0 }}
            >
              <Row gutter={[12, 0]}>
                {filterItems}
                <Col xs={24} sm={12} md={8} lg={6} xl={4} style={{ display: 'flex', alignItems: 'flex-end' }}>
                  <Form.Item>
                    <Space>
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
