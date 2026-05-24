package cn.nine.pros.post.biz.integration.tencent;

import cn.nine.pros.post.biz.config.TencentImProperties;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class TencentImPostalPeerSyncServiceTest {

    private TencentImProperties props;
    private TencentImRestApiClient client;
    private TencentImPostalPeerSyncService service;

    @BeforeEach
    void setup() {
        props = new TencentImProperties();
        props.setSdkAppId(1400000001L);
        props.setSecretKey("dummy-secret");
        props.setFriendshipSyncEnabled(true);
        props.setRestApiIdentifier("administrator");
        client = Mockito.mock(TencentImRestApiClient.class);
        when(client.isRestConfigured()).thenReturn(true);
        when(client.accountImport(anyString())).thenReturn(true);
        when(client.friendAdd(anyString(), anyString())).thenReturn(true);
        service = new TencentImPostalPeerSyncService(props, client);
    }

    @Test
    void sync_imports_both_and_friend_add_bidirectional() {
        service.syncPair(5L, 12L);
        verify(client, times(1)).accountImport("5");
        verify(client, times(1)).accountImport("12");
        verify(client, times(1)).friendAdd("5", "12");
        verify(client, times(1)).friendAdd("12", "5");
    }

    @Test
    void sync_skips_when_rest_not_configured() {
        when(client.isRestConfigured()).thenReturn(false);
        service.syncPair(5L, 12L);
        verify(client, times(0)).accountImport(anyString());
    }
}
