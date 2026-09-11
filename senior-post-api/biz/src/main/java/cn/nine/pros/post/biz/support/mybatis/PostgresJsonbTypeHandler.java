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
 * Bind via {@link Types#OTHER}.
 * <ul>
 *   <li>JSON object/array text is passed through</li>
 *   <li>plain text is encoded as a JSON string scalar (valid jsonb)</li>
 *   <li>objects/maps go through {@link #toJson(Object)}</li>
 * </ul>
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
            String trimmed = s.trim();
            if (looksLikeJsonStructure(trimmed)) {
                ps.setObject(i, s, Types.OTHER);
                return;
            }
            // plain text e.g. status=1 -> "\"status=1\"" jsonb string
            ps.setObject(i, toJson(s), Types.OTHER);
            return;
        }
        ps.setObject(i, toJson(parameter), Types.OTHER);
    }

    private static boolean looksLikeJsonStructure(String s) {
        return (s.startsWith("{") && s.endsWith("}"))
                || (s.startsWith("[") && s.endsWith("]"));
    }
}
