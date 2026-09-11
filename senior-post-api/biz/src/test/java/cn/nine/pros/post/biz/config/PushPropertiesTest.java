package cn.nine.pros.post.biz.config;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.core.env.Environment;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;

/**
 * {@link PushProperties#isMockAllowed} 守卫单元测试（对齐 BillingPropertiesTest）。
 */
@ExtendWith(MockitoExtension.class)
class PushPropertiesTest {

    @Mock
    private Environment environment;

    @Test
    void allowedWhenEnabledAndLocal() {
        PushProperties props = new PushProperties();
        props.setMockEnabled(true);
        when(environment.getActiveProfiles()).thenReturn(new String[]{"local"});
        assertTrue(props.isMockAllowed(environment));
    }

    @Test
    void rejectedWhenDisabled() {
        PushProperties props = new PushProperties();
        props.setMockEnabled(false);
        assertFalse(props.isMockAllowed(environment));
    }

    @Test
    void rejectedOnProdProfileEvenIfEnabled() {
        PushProperties props = new PushProperties();
        props.setMockEnabled(true);
        when(environment.getActiveProfiles()).thenReturn(new String[]{"prod"});
        assertFalse(props.isMockAllowed(environment));
    }

    @Test
    void rejectedOnProductionProfile() {
        PushProperties props = new PushProperties();
        props.setMockEnabled(true);
        when(environment.getActiveProfiles()).thenReturn(new String[]{"production"});
        assertFalse(props.isMockAllowed(environment));
    }
}
