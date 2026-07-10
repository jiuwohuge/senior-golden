-- M6：每日额度领取、首封信标志、免费皮肤/模板种子

ALTER TABLE bu_user
    ADD COLUMN IF NOT EXISTS first_letter_done BOOLEAN NOT NULL DEFAULT FALSE;

-- 已发过信的存量用户视为已完成首封信引导
UPDATE bu_user u
SET first_letter_done = TRUE
WHERE EXISTS (
    SELECT 1 FROM bu_letter l
    WHERE l.from_user_id = u.id AND l.del_flag = FALSE
);

CREATE TABLE IF NOT EXISTS bu_daily_quota_claim (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT       NOT NULL,
    claim_date      DATE         NOT NULL,
    quota_amount    INT          NOT NULL DEFAULT 5,
    created_at      TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP    NOT NULL DEFAULT NOW(),
    created_by      BIGINT       NOT NULL DEFAULT 0,
    updated_by      BIGINT       NOT NULL DEFAULT 0,
    del_flag        BOOLEAN      NOT NULL DEFAULT FALSE,
    CONSTRAINT uk_daily_quota_claim_user_date UNIQUE (user_id, claim_date)
);

CREATE INDEX IF NOT EXISTS idx_daily_quota_claim_user ON bu_daily_quota_claim (user_id);

-- 第二免费皮肤 + 两套免费写信模板；vintage 改为免费
UPDATE bu_commerce_product
SET price_cents = 0, updated_at = NOW()
WHERE product_code = 'skin.vintage' AND del_flag = FALSE;

INSERT INTO bu_commerce_product (product_code, product_type, title_key, price_cents, metadata_json, sort_order, status, created_at, updated_at, created_by, updated_by, del_flag)
SELECT 'skin.linen', 'skin', 'commerce.product.skin.linen', 0, '{"skinId":"linen","previewColor":"#F7F1E3"}', 5, 1, NOW(), NOW(), 0, 0, FALSE
WHERE NOT EXISTS (SELECT 1 FROM bu_commerce_product WHERE product_code = 'skin.linen' AND del_flag = FALSE);

INSERT INTO bu_commerce_product (product_code, product_type, title_key, price_cents, metadata_json, sort_order, status, created_at, updated_at, created_by, updated_by, del_flag)
SELECT 'template.emotion', 'template', 'commerce.product.template.emotion', 0,
       '{"templateId":"emotion","paragraphs":["亲爱的朋友：","最近我心里有些话想慢慢说给你听。","愿这封信带去一点温暖。"]}', 0, 1, NOW(), NOW(), 0, 0, FALSE
WHERE NOT EXISTS (SELECT 1 FROM bu_commerce_product WHERE product_code = 'template.emotion' AND del_flag = FALSE);

INSERT INTO bu_commerce_product (product_code, product_type, title_key, price_cents, metadata_json, sort_order, status, created_at, updated_at, created_by, updated_by, del_flag)
SELECT 'template.narrative', 'template', 'commerce.product.template.narrative', 0,
       '{"templateId":"narrative","paragraphs":["今天想跟你讲一件小事。","事情是这样开始的……","写到这里，窗外的光也柔和了些。"]}', 10, 1, NOW(), NOW(), 0, 0, FALSE
WHERE NOT EXISTS (SELECT 1 FROM bu_commerce_product WHERE product_code = 'template.narrative' AND del_flag = FALSE);
