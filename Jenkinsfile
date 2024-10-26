pipeline {
    agent any
    environment {
        SONARQUBE_ENV = 'SonarQube'
        SONAR_TOKEN = credentials('SonarToken')
        IMAGE_NAME = 'mohamedaminelarbi/timesheet-devops'
        IMAGE_TAG = '1.0.0'

    }
    stages {
        stage("Clone Repository") {
            steps {
                git url: 'https://github.com/Anas-REBAI/5SIM4_G2_Projet.git', branch: 'MohamedAmineLarbi-5Sim4-G2'
            }
        }
        stage("Build") {
            steps {
                sh 'mvn clean package'
                sh 'ls -la target/' // Check the target directory for JAR
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
       /* stage('NEXUS') {
            steps {
                script {
                    echo "Deploying to Nexus..."
                    nexusArtifactUploader(
                        nexusVersion: 'nexus3',
                        protocol: 'http',
                        nexusUrl: '192.168.50.4:8081',
                        groupId: 'tn.esprit.spring',
                        artifactId: 'gestion-station-ski',
                        version: '1.0',
                        repository: 'maven-releases',
                        credentialsId: 'NEXUS',
                        artifacts: [
                            [
                                artifactId: 'gestion-station-ski',
                                classifier: '',
                                file: 'target/gestion-station-ski-1.0.jar', // Relative path
                                type: 'jar'
                            ]
                        ]
                    )
                    echo "Deployment to Nexus completed!"
                }
            }
        }*/
        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }
        stage('Run Docker Image') {
            steps {
                script {
                    sh "docker run -d --name app-timesheet -p 8082:8082 ${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }
    }
    post {
        always {
            echo "========always========"
        }
        success {
            echo "========pipeline executed successfully ========"
        }
        failure {
            echo "========pipeline execution failed========"
        }
    }
}
