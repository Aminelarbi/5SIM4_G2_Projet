pipeline {
    agent any
    stages {
        stage("Cloning") {
            steps {
                echo "======== Cloning with Git ========"
                git url: "git@github.com:Anas-REBAI/5SIM4_G2_Projet.git",
                    branch: "MohamedAmineLarbi-5Sim4-G2",
                    credentialsId: "github"
            }
        }
        stage("Compiling") {
            steps {
                echo "======== Compiling with Maven ========"
                sh "mvn clean compile"
            }
        }
        stage("Testing (JUnit & Mockito)") {
            steps {
                echo "======== Running Unit Tests with Maven ========"
                sh "mvn clean test"
            }
        }
        stage("Packaging") {
            steps {
                echo "======== Packaging with Maven ========"
                sh "mvn clean package"
            }
        }
        stage("SonarQube Scan") {
            steps {
                echo "======== Analyzing with SonarQube ========"
                withSonarQubeEnv(installationName: 'sonarqube-server') {
                    sh 'mvn sonar:sonar'
                }
            }
        }
        stage('Deploy to Nexus') {
            steps {
                script {
                    nexusArtifactUploader(
                        nexusVersion: 'nexus3',
                        protocol: 'http',
                        nexusUrl: '192.168.33.10:8081',
                        groupId: 'tn.esprit.spring',
                        artifactId: 'gestion-station-ski',
                        version: '1.0.0',
                        repository: 'mohamedaminelarbi',
                        credentialsId: 'NEXUS',
                        artifacts: [
                            [
                                artifactId: 'gestion-station-ski',
                                classifier: '',
                                file: 'target/gestion-station-ski-1.0.0.jar',
                                type: 'jar'
                            ]
                        ]
                    )
                }
            }
        }
        stage("Building Docker Image") {
            steps {
                sh "docker build -t mohamedaminelarbi/mohamedaminelarbi_stationski ."
            }
        }
        /* Uncomment if you want to push the image to DockerHub
        stage("Pushing to DockerHub") {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                    sh "docker push mohamedaminelarbi/mohamedaminelarbi_stationski"
                }
            }
        } */
        stage("Stopping Containers") {
            steps {
                sh "docker-compose down"
            }
        }
        stage("Running Containers") {
            steps {
                sh "docker-compose up -d"
            }
        }
    }
    post {
        success {
            script {
                def successMessage = """
                    <html>
                        <body>
                            <h2 style="color: green;">BUILD SUCCESSFUL</h2>
                            <p>The build <b>${env.BUILD_NUMBER}</b> for Job <b>${env.JOB_NAME}</b> was successful.</p>
                            <p><strong>Build URL:</strong> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                            <p><strong>Duration:</strong> ${currentBuild.durationString}</p>
                            <br/>
                            <p>Regards,<br/>Jenkins</p>
                        </body>
                    </html>
                """
                emailext (
                    subject: "Build Success: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                    body: successMessage,
                    to: "mohamedamine.larbi@esprit.tn",
                    mimeType: 'text/html'
                )
                slackSend(channel: '#devops', message: "Build Succeeded: ${env.BUILD_URL}", color: 'good')
            }
        }
        failure {
            script {
                def failureMessage = """
                    <html>
                        <body>
                            <h2 style="color: red;">BUILD FAILED</h2>
                            <p>The build <b>${env.BUILD_NUMBER}</b> for Job <b>${env.JOB_NAME}</b> failed.</p>
                            <p><strong>Build URL:</strong> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                            <p><strong>Duration:</strong> ${currentBuild.durationString}</p>
                            <br/>
                            <p>Regards,<br/>Jenkins</p>
                        </body>
                    </html>
                """
                emailext (
                    subject: "Build Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                    body: failureMessage,
                    to: "mohamedamine.larbi@esprit.tn",
                    mimeType: 'text/html'
                )
                slackSend(channel: '#devops', message: "Build Failed: ${env.BUILD_URL}", color: 'danger')
            }
        }
    }
}
