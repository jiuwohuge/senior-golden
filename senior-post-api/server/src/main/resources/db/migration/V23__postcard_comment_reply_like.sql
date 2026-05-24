-- 明信片评论：楼中楼回复 + 点赞

ALTER TABLE bu_postcard_comment
    ADD COLUMN IF NOT EXISTS parent_id BIGINT;
ALTER TABLE bu_postcard_comment
    ADD COLUMN IF NOT EXISTS root_id BIGINT;
ALTER TABLE bu_postcard_comment
    ADD COLUMN IF NOT EXISTS reply_to_user_id BIGINT;
ALTER TABLE bu_postcard_comment
    ADD COLUMN IF NOT EXISTS like_count INT NOT NULL DEFAULT 0;

COMMENT ON COLUMN bu_postcard_comment.parent_id IS '父评论ID，顶级为 NULL';
COMMENT ON COLUMN bu_postcard_comment.root_id IS '所属顶级评论ID，顶级评论等于自身 id';
COMMENT ON COLUMN bu_postcard_comment.reply_to_user_id IS '被回复用户ID';
COMMENT ON COLUMN bu_postcard_comment.like_count IS '点赞数';

UPDATE bu_postcard_comment
SET root_id = id
WHERE parent_id IS NULL
  AND (root_id IS NULL OR root_id = 0);

CREATE INDEX IF NOT EXISTS idx_bu_postcard_comment_postcard_root
    ON bu_postcard_comment (postcard_id, root_id)
    WHERE del_flag = FALSE;

CREATE TABLE IF NOT EXISTS bu_postcard_comment_like (
    id              BIGSERIAL PRIMARY KEY,
    comment_id      BIGINT NOT NULL,
    user_id         BIGINT NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by      BIGINT,
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by      BIGINT,
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_bu_postcard_comment_like_pair
    ON bu_postcard_comment_like (comment_id, user_id)
    WHERE del_flag = FALSE;

CREATE INDEX IF NOT EXISTS idx_bu_postcard_comment_like_user
    ON bu_postcard_comment_like (user_id)
    WHERE del_flag = FALSE;

COMMENT ON TABLE bu_postcard_comment_like IS '明信片评论点赞';
COMMENT ON COLUMN bu_postcard_comment_like.comment_id IS '评论ID';
COMMENT ON COLUMN bu_postcard_comment_like.user_id IS '点赞用户ID';
