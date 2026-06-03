package cn.nine.pros.post.biz.service.timeletter;

import cn.nine.pros.post.biz.config.TimeLetterProperties;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.mapper.TimeLetterMapper;
import cn.nine.pros.post.biz.model.domain.TimeLetterDomain;
import cn.nine.pros.post.biz.service.base.StampAccountService;
import cn.nine.pros.post.biz.service.base.StampTransactionService;
import cn.nine.pros.post.biz.service.base.TimeLetterService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.common.enums.TimeLetterStatus;
import cn.nine.pros.post.client.model.db.UserDTO;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentMatchers;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class TimeLetterDeliveryServiceTest {

    @Mock
    private TimeLetterMapper timeLetterMapper;
    @Mock
    private TimeLetterService timeLetterService;
    @Mock
    private UserService userService;
    @Mock
    private StampAccountService stampAccountService;
    @Mock
    private StampTransactionService stampTransactionService;
    @Mock
    private TimeLetterProperties properties;
    @Mock
    private AppMessages appMessages;

    @InjectMocks
    private TimeLetterDeliveryService service;

    @Test
    void deliverDue_deliversWhenLocalDateReached() {
        TimeLetterDomain row = new TimeLetterDomain();
        row.setId(1L);
        row.setSenderId(10L);
        row.setRecipientId(20L);
        row.setDeliveryDate(LocalDate.now(ZoneId.of("Asia/Shanghai")));
        row.setDeliveryTz("Asia/Shanghai");
        row.setStatus(TimeLetterStatus.PENDING.getCode());
        row.setStampCost(1);

        UserDTO recipient = new UserDTO();
        recipient.setId(20L);
        recipient.setStatus(1);
        UserDTO sender = new UserDTO();
        sender.setId(10L);
        sender.setStatus(1);

        when(timeLetterMapper.selectList(ArgumentMatchers.any())).thenReturn(List.of(row));
        when(userService.findById(20L)).thenReturn(recipient);
        when(userService.findById(10L)).thenReturn(sender);
        when(timeLetterService.update(any())).thenReturn(true);

        int n = service.deliverDueLetters(50);

        assertThat(n).isEqualTo(1);
        verify(stampAccountService, never()).addBalance(any(Long.class), any(Integer.class), any(), any(Long.class));
    }

    @Test
    void deliverDue_refundsWhenRecipientUnavailable() {
        TimeLetterDomain row = new TimeLetterDomain();
        row.setId(2L);
        row.setSenderId(10L);
        row.setRecipientId(99L);
        row.setDeliveryDate(LocalDate.now(ZoneId.of("UTC")));
        row.setDeliveryTz("UTC");
        row.setStatus(TimeLetterStatus.PENDING.getCode());
        row.setStampCost(1);

        UserDTO sender = new UserDTO();
        sender.setId(10L);
        sender.setStatus(1);
        sender.setStampsBalance(5);

        when(timeLetterMapper.selectList(ArgumentMatchers.any())).thenReturn(List.of(row));
        when(userService.findById(99L)).thenReturn(null);
        when(userService.findById(10L)).thenReturn(sender);
        when(appMessages.get("app.timeLetter.fail.recipientUnavailable")).thenReturn("bad recipient");
        when(timeLetterService.update(any())).thenReturn(true);

        int n = service.deliverDueLetters(50);

        assertThat(n).isZero();
        verify(stampAccountService, times(1)).addBalance(eq(10L), eq(1), any(), any(Long.class));
    }
}
