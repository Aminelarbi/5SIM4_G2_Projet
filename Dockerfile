# Utiliser une image OpenJDK comme base
FROM openjdk:17-jdk-alpine

# Mise à jour des dépôts Alpine et installation de curl
RUN apk update && apk add --no-cache curl

# Définir les arguments pour Nexus
ARG NEXUS_URL
ARG GROUP_ID
ARG ARTIFACT_ID
ARG VERSION

# Construire l'URL et télécharger l'artefact depuis Nexus
RUN curl -f -o app.jar "$NEXUS_URL/repository/maven-releases/$(echo $GROUP_ID | tr . /)/$ARTIFACT_ID/$VERSION/$ARTIFACT_ID-$VERSION.jar"

# Exposer le port de l'application
EXPOSE 9005

# Lancer l'application
ENTRYPOINT ["java", "-jar", "app.jar"]

#FROM openjdk:17-jdk-alpine
#WORKDIR /app
#COPY target/*.jar app.jar
#EXPOSE 9000
#ENTRYPOINT ["java", "-jar", "app.jar"]
