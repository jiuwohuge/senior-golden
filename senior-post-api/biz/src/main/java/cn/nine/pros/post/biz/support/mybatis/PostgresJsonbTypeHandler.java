package cn.nine.pros.post.biz.support.mybatis;

import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import org.apache.ibatis.type.JdbcType;
import org.apache.ibatis.type.MappedJdbcTypes;
import org.apache.ibatis.type.MappedTypes;

import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Types;
import java.util.Map;

/**
 * PostgreSQL {@code jsonb} 写入适配。
 * <p>{@link JacksonTypeHandler} 默认 {@code setString}，PG 会报
 * {@code column is of type jsonb but expression is of type character varying}。
 * 这里用 {@link Types#OTHER} 让驱动按 jsonb 绑定。
 */
@MappedTypes({Object.class, Map.class})
@MappedJdbcTypes(JdbcType.OTHER)
public class PostgresJsonbTypeHandler extends JacksonTypeHandler {

    public PostgresJsonbTypeHandler(Class<?> type) {
        super(type);
    }

    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, Object parameter, JdbcType jdbcType)
            throws SQLException {
        ps.setObject(i, toJson(parameter), Types.OTHER);
    }
}
