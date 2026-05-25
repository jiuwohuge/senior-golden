package cn.nine.pros.post.biz.moderation.baidu;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.List;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class BaiduImageCensorResponse {

    /** 1 合规 2 不合规 3 疑似 4 审核失败 */
    @JsonProperty("conclusionType")
    private Integer conclusionType;

    @JsonProperty("error_code")
    private Integer errorCode;

    @JsonProperty("error_msg")
    private String errorMsg;

    private List<DataItem> data;

    @Data
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class DataItem {
        /** 1 色情 */
        private Integer type;
        private String msg;
    }
}
