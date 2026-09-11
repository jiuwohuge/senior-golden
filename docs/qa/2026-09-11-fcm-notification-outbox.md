# QA：FCM Notification Outbox（2026-09-11）

**Commit SHA:** *(pending commit — update after push)*

## 范围

信件推送 Outbox：`letter_matched_in_transit` / `letter_arrived`。**禁止**任何支付/订阅/退款类 FCM。

## Mock 端点

- `POST /backend/api/push/mock-enqueue`（需登录 Token）
- 开关：`senior-post.push.mock-enabled` / env `PUSH_MOCK_ENABLED`；`prod`/`production` profile 强制关闭（同计费 mock）

### Body

```json
{
  "eventType": "letter_matched_in_transit",
  "letterId": 123,
  "recipientUserId": null,
  "triggerJob": true
}
```

- `eventType`：仅 `letter_matched_in_transit` | `letter_arrived`
- `recipientUserId`：可选，默认当前用户
- `triggerJob`：默认 `true`，入队后立即跑一轮 `NotificationOutboxJob`

### 响应要点

- `outboxId`、`deliveries[]`（`sendStatus`/`provider`/`fcmMessageId`）

## QA 步骤

1. App 登录后调用 `POST /api/device/push-token`（header `equipmentId`）注册 Token → 写入 `bu_user_device` + `bu_push_endpoint`
2. `POST /api/push/mock-enqueue`（上列 body，`triggerJob=true`）
3. 查库：`bu_notification_outbox` status=`sent`；`bu_notification_delivery` 有 `mock_sent` / provider=`mock`
4. 深链字段：payload 含 `route`=`app://letter/{letterId}`，可选 `screen`=`in_transit`|`arrived`
5. 负向：`eventType=purchase_success`（或 `refund` / `subscription_*`）应业务失败（支付推送禁入）

## 支付推送禁令

入队层对支付类 eventType 抛 `BusinessException`（`app.error.push.paymentForbidden`）；单测 `NotificationEnqueueServiceTest` 覆盖。

## @测试

@测试 信件推送 Outbox 已合入：注册 push-token → mock-enqueue → 查 delivery；确认支付类 eventType 入队被拒。
