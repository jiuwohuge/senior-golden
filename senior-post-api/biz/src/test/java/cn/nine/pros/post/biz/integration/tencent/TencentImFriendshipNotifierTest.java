package cn.nine.pros.post.biz.integration.tencent;

import cn.nine.pros.post.biz.config.TencentImProperties;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class TencentImFriendshipNotifierTest {

    private TencentImProperties props;
    private TencentImRestApiClient client;
    private TencentImFriendshipNotifier notifier;

    @BeforeEach
    void setup() {
        props = new TencentImProperties();
        props.setSdkAppId(1400000001L);
        props.setSecretKey("dummy-secret-for-test-only");
        props.setFriendshipSyncEnabled(true);
        props.setRestApiIdentifier("administrator");
        props.setAccountImportBeforeFriendAdd(true);
        client = Mockito.mock(TencentImRestApiClient.class);
        when(client.accountImport(anyString())).thenReturn(true);
        when(client.friendAdd(anyString(), anyString())).thenReturn(true);
        notifier = new TencentImFriendshipNotifier(props, client);
    }

    @Test
    void sync_calls_import_and_bidirectional_friend_add() {
        notifier.afterFriendshipActive(10L, 20L);

        verify(client, times(1)).accountImport("10");
        verify(client, times(1)).accountImport("20");
        verify(client, times(1)).friendAdd("10", "20");
        verify(client, times(1)).friendAdd("20", "10");
    }

    @Test
    void skipped_when_sync_disabled() {
        props.setFriendshipSyncEnabled(false);
        notifier.afterFriendshipActive(1L, 2L);
        verify(client, times(0)).friendAdd(anyString(), anyString());
    }

    @Test
    void skipped_when_rest_identifier_blank() {
        props.setRestApiIdentifier("");
        notifier.afterFriendshipActive(1L, 2L);
        verify(client, times(0)).friendAdd(anyString(), anyString());
    }
}
