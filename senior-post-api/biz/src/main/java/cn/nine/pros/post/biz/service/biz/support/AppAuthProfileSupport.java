package cn.nine.pros.post.biz.service.biz.support;

import cn.nine.pros.post.client.common.constant.UserGender;
import cn.nine.pros.post.client.model.db.UserDTO;

import java.time.Year;
import java.util.List;

public final class AppAuthProfileSupport {

    private static final int MIN_AGE = 45;

    private AppAuthProfileSupport() {
    }

    public static boolean isProfileComplete(UserDTO dto, List<Integer> interestTagIds) {
        if (dto == null || dto.getId() == null) {
            return false;
        }
        Integer gender = dto.getGender();
        if (gender == null || !UserGender.isValidForProfile(gender)) {
            return false;
        }
        Integer birthYear = dto.getBirthYear();
        if (birthYear == null) {
            return false;
        }
        int age = Year.now().getValue() - birthYear;
        if (age < MIN_AGE) {
            return false;
        }
        return interestTagIds != null && interestTagIds.size() >= 3;
    }
}
