pipeline {

    agent any

    environment {
        SONARQUBE_ENV = 'SonarQube'
        SONAR_TOKEN = credentials('SonartDevops')
        DOCKER_CREDENTIALS_ID = 'DOCKER'
    }

    stages {

        stage('GIT') {
            steps {
                echo 'Pulling from Git...'
                git branch: 'WalidMarzouk-5Sim4-G2',
                    url: 'https://github.com/Anas-REBAI/5SIM4_G2_Projet.git'
            }
        }

        stage('COMPILING') {
            steps {
                script {
                    // Clean and install dependencies
                    sh 'mvn clean install'
                }
            }
        }

        stage('SONARQUBE') {
                    steps {
                        script {
                            withSonarQubeEnv("${SONARQUBE_ENV}") {
                                sh """
                                    mvn sonar:sonar \
                                    -Dsonar.login=${SONAR_TOKEN} \
                                    -Dsonar.coverage.jacoco.xmlReportPaths=/target/site/jacoco/jacoco.xml
                                """
                            }
                        }
                    }
        }
    }
}
