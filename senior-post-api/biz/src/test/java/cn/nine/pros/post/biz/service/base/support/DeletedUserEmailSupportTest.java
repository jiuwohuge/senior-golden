package cn.nine.pros.post.biz.service.base.support;

import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;
import java.time.ZoneOffset;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class DeletedUserEmailSupportTest {

    private static final LocalDateTime AT =
            LocalDateTime.of(2026, 5, 18, 12, 0, 0).atZone(ZoneOffset.UTC).toLocalDateTime();

    @Test
    void archive_appendsTimestampBeforeAtSign() {
        String out = DeletedUserEmailSupport.archive("User@Example.com", AT);
        long expectedTs = AT.atZone(ZoneOffset.systemDefault()).toInstant().toEpochMilli();
        assertEquals("user+deleted." + expectedTs + "@example.com", out);
    }

    @Test
    void archive_idempotentWhenAlreadyArchived() {
        String once = DeletedUserEmailSupport.archive("a@b.com", AT);
        assertEquals(once, DeletedUserEmailSupport.archive(once, AT));
    }

    @Test
    void archive_truncatesWhenExceedsColumnLimit() {
        String local = "x".repeat(240);
        String email = local + "@example.com";
        String out = DeletedUserEmailSupport.archive(email, AT);
        assertEquals(255, out.length());
        assertTrue(out.startsWith("x"));
    }
}
