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
 * PostgreSQL {@code jsonb} write binder.
 * <p>{@link JacksonTypeHandler} defaults to {@code setString}; PG then errors with
 * {@code column is of type jsonb but expression is of type character varying}.
 * Bind via {@link Types#OTHER}. Plain JSON {@link String} is passed through
 * (no second encode); objects/maps still go through {@link #toJson(Object)}.
 */
@MappedTypes({Object.class, Map.class, String.class})
@MappedJdbcTypes(JdbcType.OTHER)
public class PostgresJsonbTypeHandler extends JacksonTypeHandler {

    public PostgresJsonbTypeHandler(Class<?> type) {
        super(type);
    }

    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, Object parameter, JdbcType jdbcType)
            throws SQLException {
        if (parameter instanceof String s) {
            ps.setObject(i, s, Types.OTHER);
            return;
        }
        ps.setObject(i, toJson(parameter), Types.OTHER);
    }
}
