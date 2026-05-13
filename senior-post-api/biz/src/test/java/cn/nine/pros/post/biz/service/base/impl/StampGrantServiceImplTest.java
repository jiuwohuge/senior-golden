package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.config.StampGrantProperties;
import cn.nine.pros.post.biz.mapper.StampDailyGrantMapper;
import cn.nine.pros.post.biz.mapper.StampTransactionMapper;
import cn.nine.pros.post.biz.model.domain.StampDailyGrantDomain;
import cn.nine.pros.post.biz.model.domain.StampTransactionDomain;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.service.base.StampAccountService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.model.db.UserDTO;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.ArgumentMatchers;
import org.springframework.dao.DataIntegrityViolationException;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class StampGrantServiceImplTest {

    private StampGrantProperties props;
    private StampDailyGrantMapper dailyGrantMapper;
    private StampAccountService stampAccountService;
    private UserService userService;
    private StampTransactionMapper stampTransactionMapper;
    private AppMessages appMessages;
    private StampGrantServiceImpl svc;

    @BeforeEach
    void setup() {
        props = new StampGrantProperties();
        dailyGrantMapper = org.mockito.Mockito.mock(StampDailyGrantMapper.class);
        stampAccountService = org.mockito.Mockito.mock(StampAccountService.class);
        userService = org.mockito.Mockito.mock(UserService.class);
        stampTransactionMapper = org.mockito.Mockito.mock(StampTransactionMapper.class);
        appMessages = org.mockito.Mockito.mock(AppMessages.class);
        svc = new StampGrantServiceImpl(props, dailyGrantMapper, stampAccountService, userService, stampTransactionMapper, appMessages);
    }

    @Test
    void login_grant_adds_balance_when_insert_ok() {
        props.setLoginEnabled(true);
        props.setLoginDailyAmount(2);
        UserDTO u = new UserDTO();
        u.setId(5L);
        u.setStampsBalance(3);
        when(userService.findById(5L)).thenReturn(u);
        when(dailyGrantMapper.insert(ArgumentMatchers.<StampDailyGrantDomain>any())).thenReturn(1);

        svc.afterLogin(5L);

        verify(stampAccountService, times(1)).addBalance(eq(5L), eq(2), any(), eq(5L));
        verify(stampTransactionMapper, times(1)).insert(ArgumentMatchers.<StampTransactionDomain>any());
    }

    @Test
    void login_grant_skipped_on_duplicate() {
        props.setLoginEnabled(true);
        props.setLoginDailyAmount(1);
        org.mockito.Mockito.doThrow(new DataIntegrityViolationException("dup", null))
                .when(dailyGrantMapper).insert(ArgumentMatchers.<StampDailyGrantDomain>any());

        svc.afterLogin(9L);

        verify(stampAccountService, never()).addBalance(anyLong(), anyInt(), any(), anyLong());
        verify(stampTransactionMapper, never()).insert(ArgumentMatchers.<StampTransactionDomain>any());
    }

    @Test
    void postcard_grant_respects_daily_cap() {
        props.setPostcardEnabled(true);
        props.setPostcardRewardPerPost(2);
        props.setPostcardDailyStampCap(3);
        UserDTO u = new UserDTO();
        u.setId(1L);
        u.setStampsBalance(0);
        when(userService.findById(1L)).thenReturn(u);

        StampDailyGrantDomain prior = new StampDailyGrantDomain();
        prior.setAmount(2);
        when(dailyGrantMapper.selectCount(any())).thenReturn(0L);
        when(dailyGrantMapper.selectList(any())).thenReturn(java.util.List.of(prior));

        svc.afterPostcardCreated(1L, 100L);

        verify(stampAccountService, never()).addBalance(anyLong(), anyInt(), any(), anyLong());
    }

    @Test
    void postcard_grant_inserts_and_credits() {
        props.setPostcardEnabled(true);
        props.setPostcardRewardPerPost(1);
        props.setPostcardDailyStampCap(10);
        UserDTO u = new UserDTO();
        u.setId(7L);
        u.setStampsBalance(4);
        when(userService.findById(7L)).thenReturn(u);
        when(dailyGrantMapper.selectCount(any())).thenReturn(0L);
        when(dailyGrantMapper.selectList(any())).thenReturn(java.util.List.of());
        when(dailyGrantMapper.insert(ArgumentMatchers.<StampDailyGrantDomain>any())).thenReturn(1);

        svc.afterPostcardCreated(7L, 200L);

        ArgumentCaptor<StampDailyGrantDomain> cap = ArgumentCaptor.forClass(StampDailyGrantDomain.class);
        verify(dailyGrantMapper, times(1)).insert(cap.capture());
        assertEquals(StampDailyGrantDomain.KIND_POSTCARD, cap.getValue().getGrantKind());
        assertEquals(200L, cap.getValue().getRefId());
        verify(stampAccountService, times(1)).addBalance(eq(7L), eq(1), any(), eq(7L));
    }
}
