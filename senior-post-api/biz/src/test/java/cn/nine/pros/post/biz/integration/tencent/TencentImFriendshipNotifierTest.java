package cn.nine.pros.post.biz.integration.tencent;

import cn.nine.pros.post.biz.config.TencentImProperties;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class TencentImFriendshipNotifierTest {

    private TencentImPostalPeerSyncService peerSyncService;
    private TencentImRestApiClient client;
    private TencentImProperties props;
    private TencentImFriendshipNotifier notifier;

    @BeforeEach
    void setup() {
        props = new TencentImProperties();
        props.setSdkAppId(1400000001L);
        props.setSecretKey("dummy-secret-for-test-only");
        props.setFriendshipSyncEnabled(true);
        props.setRestApiIdentifier("administrator");
        peerSyncService = Mockito.mock(TencentImPostalPeerSyncService.class);
        client = Mockito.mock(TencentImRestApiClient.class);
        when(client.isRestConfigured()).thenReturn(true);
        when(client.friendDeleteBoth(anyString(), anyString())).thenReturn(true);
        notifier = new TencentImFriendshipNotifier(peerSyncService, client, props);
    }

    @Test
    void active_delegates_to_peer_sync() {
        notifier.afterFriendshipActive(10L, 20L);
        verify(peerSyncService, times(1)).syncPair(10L, 20L);
    }

    @Test
    void remove_calls_friend_delete_both() {
        notifier.afterFriendshipRemoved(10L, 20L);
        verify(client, times(1)).friendDeleteBoth("10", "20");
        verify(peerSyncService, never()).syncPair(anyLong(), anyLong());
    }
}
