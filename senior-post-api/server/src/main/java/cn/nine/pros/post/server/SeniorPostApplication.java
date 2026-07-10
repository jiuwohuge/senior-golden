package cn.nine.pros.post.server;

import cn.nine.commons.security.springboot.annotation.EnableEncrypt;
import lombok.extern.slf4j.Slf4j;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.Environment;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

import java.net.InetAddress;
import java.net.UnknownHostException;

@Slf4j
@MapperScan("cn.nine.pros.post.biz.mapper")
@EnableScheduling
@EnableAsync
@EnableEncrypt
@SpringBootApplication(scanBasePackages = "cn.nine.pros")
public class SeniorPostApplication {

    public static void main(String[] args) throws UnknownHostException {
        ConfigurableApplicationContext application = SpringApplication.run(SeniorPostApplication.class, args);
        Environment env = application.getEnvironment();
        String ip = InetAddress.getLocalHost().getHostAddress();
        String port = env.getProperty("server.port");
        String contextPath = env.getProperty("server.servlet.context-path");
        String prefix = port+ (contextPath != null ? contextPath : "");
        log.info("\n----------------------------------------------------------\n\t" +
                "Application Senior Post API is running! Access URLs:\n\t" +
                "Local: \t\thttp://localhost:" + prefix + "\n\t" +
                "External: \thttp://" + ip + ":" + prefix + "\n\t" +
                "swagger-ui: http://" + ip + ":" + prefix + "/doc.html\n" +
                "----------------------------------------------------------");
    }

}
