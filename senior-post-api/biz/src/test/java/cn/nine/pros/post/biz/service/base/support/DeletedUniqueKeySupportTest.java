package cn.nine.pros.post.biz.service.base.support;

import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;
import java.time.ZoneOffset;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class DeletedUniqueKeySupportTest {

    private static final LocalDateTime AT =
            LocalDateTime.of(2026, 5, 18, 12, 0, 0).atZone(ZoneOffset.UTC).toLocalDateTime();

    @Test
    void archiveEmail_appendsTimestampBeforeAtSign() {
        String out = DeletedUniqueKeySupport.archiveEmail("User@Example.com", AT);
        long expectedTs = AT.atZone(ZoneOffset.systemDefault()).toInstant().toEpochMilli();
        assertEquals("user+deleted." + expectedTs + "@example.com", out);
    }

    @Test
    void archiveEmail_idempotentWhenAlreadyArchived() {
        String once = DeletedUniqueKeySupport.archiveEmail("a@b.com", AT);
        assertEquals(once, DeletedUniqueKeySupport.archiveEmail(once, AT));
    }

    @Test
    void archiveProviderUid_appendsTimestampSuffix() {
        String sub = "103547891234567890123";
        String out = DeletedUniqueKeySupport.archiveProviderUid(sub, AT);
        long expectedTs = AT.atZone(ZoneOffset.systemDefault()).toInstant().toEpochMilli();
        assertEquals(sub + "+deleted." + expectedTs, out);
    }

    @Test
    void archiveProviderUid_idempotentWhenAlreadyArchived() {
        String once = DeletedUniqueKeySupport.archiveProviderUid("openid-abc", AT);
        assertEquals(once, DeletedUniqueKeySupport.archiveProviderUid(once, AT));
    }

    @Test
    void archiveEmail_truncatesWhenExceedsColumnLimit() {
        String local = "x".repeat(240);
        String email = local + "@example.com";
        String out = DeletedUniqueKeySupport.archiveEmail(email, AT);
        assertEquals(255, out.length());
        assertTrue(out.startsWith("x"));
    }
}
