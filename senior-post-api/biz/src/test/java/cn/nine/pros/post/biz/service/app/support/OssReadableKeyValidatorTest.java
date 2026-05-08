package cn.nine.pros.post.biz.service.app.support;

import cn.nine.commons.basic.exception.BadRequestException;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class OssReadableKeyValidatorTest {

    private static final String PREFIX = "app/uploads";

    @Test
    void acceptsPutStyleKey() {
        String key = "app/uploads/postcard/42/a1b2c3d4-e5f6-7890-abcd-ef1234567890.jpg";
        assertEquals(key, OssReadableKeyValidator.normalizeAndValidate(PREFIX, key));
    }

    @Test
    void stripsLeadingSlashes() {
        String key = "/app/uploads/avatar/1/550e8400-e29b-41d4-a716-446655440000.png";
        assertEquals(
                "app/uploads/avatar/1/550e8400-e29b-41d4-a716-446655440000.png",
                OssReadableKeyValidator.normalizeAndValidate(PREFIX, key));
    }

    @Test
    void sceneCaseInsensitive() {
        String key = "app/uploads/Postcard/9/a1b2c3d4-e5f6-7890-abcd-ef1234567890.webp";
        assertEquals(key, OssReadableKeyValidator.normalizeAndValidate(PREFIX, key));
    }

    @Test
    void rejectsWrongPrefix() {
        assertThrows(
                BadRequestException.class,
                () -> OssReadableKeyValidator.normalizeAndValidate(PREFIX, "other/postcard/1/x.jpg"));
    }

    @Test
    void rejectsParentSegments() {
        assertThrows(
                BadRequestException.class,
                () -> OssReadableKeyValidator.normalizeAndValidate(PREFIX, "app/uploads/postcard/1/../2/x.jpg"));
    }

    @Test
    void rejectsBadScene() {
        assertThrows(
                BadRequestException.class,
                () -> OssReadableKeyValidator.normalizeAndValidate(PREFIX, "app/uploads/other/1/x.jpg"));
    }

    @Test
    void rejectsDeepPath() {
        assertThrows(
                BadRequestException.class,
                () -> OssReadableKeyValidator.normalizeAndValidate(PREFIX, "app/uploads/postcard/1/extra/x.jpg"));
    }
}
