# Use OpenJDK 17 as the base image
FROM openjdk:17-jdk-alpine

# Expose port 9005
EXPOSE 9005

# Set environment variables for Nexus credentials and URL
ARG NEXUS_USER
ARG NEXUS_PASS
ARG NEXUS_URL

# Update mirror and install curl, then download the JAR from Nexus
RUN sed -i 's|dl-cdn.alpinelinux.org|mirror.sjtu.edu.cn|g' /etc/apk/repositories && \
    apk update && \
    apk add --no-cache curl && \
    curl -u "$NEXUS_USER:$NEXUS_PASS" -o gestion-station-ski-1.2.jar "$NEXUS_URL"

# Set the entry point to run the application
ENTRYPOINT ["java", "-jar", "/gestion-station-ski-1.2.jar"]
