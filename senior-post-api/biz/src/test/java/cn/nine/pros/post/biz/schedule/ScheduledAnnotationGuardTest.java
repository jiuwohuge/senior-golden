package cn.nine.pros.post.biz.schedule;

import org.junit.jupiter.api.Test;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.core.type.classreading.CachingMetadataReaderFactory;
import org.springframework.core.type.classreading.MetadataReader;
import org.springframework.core.type.classreading.MetadataReaderFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.util.ClassUtils;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * 架构护栏：biz 包内仅 {@link ScheduledTaskEntrypoints} 可声明 {@link Scheduled}。
 */
class ScheduledAnnotationGuardTest {

    private static final String BASE_PACKAGE = "cn.nine.pros.post.biz";
    private static final String PATTERN = "classpath*:" + BASE_PACKAGE.replace('.', '/') + "/**/*.class";

    @Test
    void onlyScheduledTaskEntrypointsMayDeclareScheduled() throws Exception {
        PathMatchingResourcePatternResolver resolver = new PathMatchingResourcePatternResolver();
        MetadataReaderFactory metadataFactory = new CachingMetadataReaderFactory(resolver);
        Resource[] resources = resolver.getResources(PATTERN);

        List<String> offenders = new ArrayList<>();
        boolean entrypointsSeen = false;

        for (Resource resource : resources) {
            if (!resource.isReadable()) {
                continue;
            }
            MetadataReader reader = metadataFactory.getMetadataReader(resource);
            String className = reader.getClassMetadata().getClassName();
            if (className.contains("$")) {
                continue;
            }
            Class<?> clazz = ClassUtils.forName(className, getClass().getClassLoader());
            boolean hasScheduled = false;
            for (Method method : clazz.getDeclaredMethods()) {
                if (method.isAnnotationPresent(Scheduled.class)) {
                    hasScheduled = true;
                    break;
                }
            }
            if (!hasScheduled) {
                continue;
            }
            if (ScheduledTaskEntrypoints.class.equals(clazz)) {
                entrypointsSeen = true;
                continue;
            }
            offenders.add(className);
        }

        assertTrue(entrypointsSeen, "ScheduledTaskEntrypoints must declare @Scheduled methods");
        assertTrue(offenders.isEmpty(),
                "Only ScheduledTaskEntrypoints may use @Scheduled, found: " + offenders);
        assertFalse(offenders.contains(ScheduledTaskEntrypoints.class.getName()));
    }
}
