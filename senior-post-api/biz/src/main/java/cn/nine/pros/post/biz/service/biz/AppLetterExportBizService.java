package cn.nine.pros.post.biz.service.biz;

import cn.nine.pros.post.client.model.input.app.LetterExportInDto;
import cn.nine.pros.post.client.model.out.LetterExportResultVO;

public interface AppLetterExportBizService {

    LetterExportResultVO export(long userId, LetterExportInDto body);
}
