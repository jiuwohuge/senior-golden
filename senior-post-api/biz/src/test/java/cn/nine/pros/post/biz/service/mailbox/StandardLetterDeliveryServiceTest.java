package cn.nine.pros.post.biz.service.mailbox;

import cn.nine.pros.post.biz.mapper.LetterMapper;
import cn.nine.pros.post.biz.model.domain.LetterDomain;
import cn.nine.pros.post.biz.service.base.LetterService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentMatchers;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class StandardLetterDeliveryServiceTest {

    @Mock
    private LetterMapper letterMapper;

    @Mock
    private LetterService letterService;

    @InjectMocks
    private StandardLetterDeliveryService service;

    @Test
    void deliverDue_countsSuccessfulUpdates() {
        LocalDateTime now = LocalDateTime.of(2026, 5, 7, 12, 0);
        LetterDomain a = new LetterDomain();
        a.setId(10L);
        LetterDomain b = new LetterDomain();
        b.setId(20L);
        when(letterMapper.selectList(ArgumentMatchers.any())).thenReturn(List.of(a, b));
        when(letterService.update(any())).thenReturn(true, false);

        int n = service.deliverDueStandardLetters(now, 200);

        assertThat(n).isEqualTo(1);
        verify(letterService, times(2)).update(any());
    }

    @Test
    void deliverDue_emptyList_zeroUpdates() {
        when(letterMapper.selectList(ArgumentMatchers.any())).thenReturn(List.of());

        int n = service.deliverDueStandardLetters(LocalDateTime.now(), 50);

        assertThat(n).isZero();
        verify(letterService, times(0)).update(any());
    }
}
