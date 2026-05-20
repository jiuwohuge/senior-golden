package cn.nine.pros.post.client.model.input;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.*;
import lombok.Data;

import java.util.List;

@Data
@Schema(description = "Google 新用户资料补全")
public class AppGoogleCompleteInDto {

    @NotNull
    @Min(1)
    @Max(3)
    @Schema(description = "性别：1男 2女 3其他")
    private Integer gender;

    @NotNull
    @Min(1900)
    @Max(2100)
    private Integer birthYear;

    @NotBlank
    @Size(max = 100)
    private String nickname;

    @Size(max = 10)
    private String countryCode;

    @NotNull
    @Size(min = 3, max = 30)
    private List<@NotNull Integer> interestTagIds;

    @Size(max = 512)
    @Schema(description = "可选头像 objectKey")
    private String avatarUrl;
}
