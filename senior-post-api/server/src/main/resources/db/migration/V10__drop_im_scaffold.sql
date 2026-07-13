-- Drop unused IM scaffold tables (chat was Tencent TIM SDK, never persisted here).
DROP TABLE IF EXISTS bu_im_message;
DROP TABLE IF EXISTS bu_im_conversation;
