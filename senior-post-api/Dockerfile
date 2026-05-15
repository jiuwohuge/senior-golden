FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

ARG JAR_FILE=server/target/senior-post-server-*.jar
COPY ${JAR_FILE} app.jar

EXPOSE 9011

ENV SPRING_PROFILES_ACTIVE=local
ENV JAVA_OPTS=""

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar --spring.profiles.active=${SPRING_PROFILES_ACTIVE}"]
