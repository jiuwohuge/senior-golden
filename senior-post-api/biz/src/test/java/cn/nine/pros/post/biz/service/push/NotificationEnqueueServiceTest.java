package cn.nine.pros.post.biz.service.push;

import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.NotificationOutboxDomain;
import cn.nine.pros.post.biz.service.base.NotificationOutboxService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * {@link NotificationEnqueueService}：支付禁入、信件白名单、dedupe 幂等。
 */
@ExtendWith(MockitoExtension.class)
class NotificationEnqueueServiceTest {

    @Mock
    private NotificationOutboxService notificationOutboxService;

    @Mock
    private AppMessages appMessages;

    private NotificationEnqueueServiceImpl enqueueService;

    @BeforeEach
    void setUp() {
        lenient().when(appMessages.get(anyString())).thenAnswer(inv -> inv.getArgument(0));
        enqueueService = new NotificationEnqueueServiceImpl(notificationOutboxService, appMessages);
    }

    @ParameterizedTest
    @ValueSource(strings = {
            "purchase_success",
            "renew",
            "charge_fail",
            "cancel",
            "refund",
            "revoke",
            "subscription_renewed",
            "billing_charge",
            "payment_failed"
    })
    void refusesPaymentLikeEventTypes(String eventType) {
        BusinessException ex = assertThrows(BusinessException.class,
                () -> enqueueService.enqueueLetterEvent(eventType, 1L, 2L));
        assertTrue(ex.getMessage().contains("app.error.push.paymentForbidden"));
        verify(notificationOutboxService, never()).insertPending(any());
    }

    @Test
    void refusesUnknownNonAllowedType() {
        BusinessException ex = assertThrows(BusinessException.class,
                () -> enqueueService.enqueueLetterEvent("penpal_request", 1L, 2L));
        assertTrue(ex.getMessage().contains("app.error.push.eventTypeInvalid"));
        verify(notificationOutboxService, never()).insertPending(any());
    }

    @Test
    void allowsLetterMatchedInTransit() {
        when(notificationOutboxService.findByDedupeKey(anyString())).thenReturn(null);
        when(notificationOutboxService.insertPending(any())).thenAnswer(inv -> {
            NotificationOutboxDomain row = inv.getArgument(0);
            row.setId(101L);
            return row;
        });

        long id = enqueueService.enqueueLetterEvent(
                NotificationEventTypes.LETTER_MATCHED_IN_TRANSIT, 9L, 8L);

        assertEquals(101L, id);
        ArgumentCaptor<NotificationOutboxDomain> cap = ArgumentCaptor.forClass(NotificationOutboxDomain.class);
        verify(notificationOutboxService).insertPending(cap.capture());
        NotificationOutboxDomain saved = cap.getValue();
        assertEquals(NotificationEventTypes.LETTER_MATCHED_IN_TRANSIT, saved.getEventType());
        assertEquals("letter_matched:9:8", saved.getDedupeKey());
        assertEquals(NotificationEventTypes.TITLE_IN_TRANSIT, saved.getTitle());
        assertEquals(NotificationEventTypes.BODY_IN_TRANSIT, saved.getBody());
    }

    @Test
    void allowsLetterArrived() {
        when(notificationOutboxService.findByDedupeKey(anyString())).thenReturn(null);
        when(notificationOutboxService.insertPending(any())).thenAnswer(inv -> {
            NotificationOutboxDomain row = inv.getArgument(0);
            row.setId(202L);
            return row;
        });

        long id = enqueueService.enqueueLetterEvent(
                NotificationEventTypes.LETTER_ARRIVED, 11L, 22L);

        assertEquals(202L, id);
        ArgumentCaptor<NotificationOutboxDomain> cap = ArgumentCaptor.forClass(NotificationOutboxDomain.class);
        verify(notificationOutboxService).insertPending(cap.capture());
        assertEquals("letter_arrived:11:22", cap.getValue().getDedupeKey());
        assertEquals(NotificationEventTypes.TITLE_ARRIVED, cap.getValue().getTitle());
    }

    @Test
    void dedupeReturnsExistingIdWithoutInsert() {
        NotificationOutboxDomain existing = new NotificationOutboxDomain();
        existing.setId(55L);
        existing.setDedupeKey("letter_arrived:1:2");
        when(notificationOutboxService.findByDedupeKey("letter_arrived:1:2")).thenReturn(existing);

        long id = enqueueService.enqueueLetterEvent(
                NotificationEventTypes.LETTER_ARRIVED, 1L, 2L);

        assertEquals(55L, id);
        verify(notificationOutboxService, never()).insertPending(any());
    }
}
