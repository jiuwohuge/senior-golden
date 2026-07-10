package cn.nine.pros.post.biz.service.biz.support;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.context.MessageSource;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class OssReadableKeyValidatorTest {

    private static final String PREFIX = "app/uploads";

    private AppMessages appMessages;

    @BeforeEach
    void setUp() {
        MessageSource ms = mock(MessageSource.class);
        when(ms.getMessage(anyString(), any(), any())).thenAnswer(i -> i.getArgument(0));
        appMessages = new AppMessages(ms);
    }

    @Test
    void acceptsLetterKey() {
        String key = "app/uploads/letter/42/a1b2c3d4-e5f6-7890-abcd-ef1234567890.jpg";
        assertEquals(key, OssReadableKeyValidator.normalizeAndValidate(PREFIX, key, appMessages));
    }

    @Test
    void stripsLeadingSlashes() {
        String key = "/app/uploads/avatar/1/550e8400-e29b-41d4-a716-446655440000.png";
        assertEquals(
                "app/uploads/avatar/1/550e8400-e29b-41d4-a716-446655440000.png",
                OssReadableKeyValidator.normalizeAndValidate(PREFIX, key, appMessages));
    }

    @Test
    void sceneCaseInsensitive() {
        String key = "app/uploads/Letter/9/a1b2c3d4-e5f6-7890-abcd-ef1234567890.webp";
        assertEquals(key, OssReadableKeyValidator.normalizeAndValidate(PREFIX, key, appMessages));
    }

    @Test
    void rejectsWrongPrefix() {
        assertThrows(
                BadRequestException.class,
                () -> OssReadableKeyValidator.normalizeAndValidate(PREFIX, "other/letter/1/x.jpg", appMessages));
    }

    @Test
    void rejectsParentSegments() {
        assertThrows(
                BadRequestException.class,
                () -> OssReadableKeyValidator.normalizeAndValidate(
                        PREFIX, "app/uploads/letter/1/../2/x.jpg", appMessages));
    }

    @Test
    void rejectsBadScene() {
        assertThrows(
                BadRequestException.class,
                () -> OssReadableKeyValidator.normalizeAndValidate(PREFIX, "app/uploads/other/1/x.jpg", appMessages));
    }

    @Test
    void rejectsRemovedPostcardScene() {
        assertThrows(
                BadRequestException.class,
                () -> OssReadableKeyValidator.normalizeAndValidate(PREFIX,
                        "app/uploads/postcard/1/a1b2c3d4-e5f6-7890-abcd-ef1234567890.jpg", appMessages));
    }

    @Test
    void rejectsDeepPath() {
        assertThrows(
                BadRequestException.class,
                () -> OssReadableKeyValidator.normalizeAndValidate(PREFIX, "app/uploads/letter/1/extra/x.jpg",
                        appMessages));
    }
}
