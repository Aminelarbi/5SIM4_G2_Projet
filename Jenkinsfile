pipeline {
    agent any
    stages {
        stage("Cloning") {
            steps {
                script {
                    try {
                        echo "======== Cloning with Git ========"
                        git url: "git@github.com:Anas-REBAI/5SIM4_G2_Projet.git",
                            branch: "MohamedAmineLarbi-5Sim4-G2",
                            credentialsId: "github"
                        currentBuild.description += "Cloning: ✅\n"
                    } catch (Exception e) {
                        currentBuild.description += "Cloning: ❌\n"
                        throw e
                    }
                }
            }
        }
        stage("Compiling") {
            steps {
                script {
                    try {
                        echo "======== Compiling with Maven ========"
                        sh "mvn clean compile"
                        currentBuild.description += "Compiling: ✅\n"
                    } catch (Exception e) {
                        currentBuild.description += "Compiling: ❌\n"
                        throw e
                    }
                }
            }
        }
        stage("Testing (JUnit & Mockito)") {
            steps {
                script {
                    try {
                        echo "======== Running Unit Tests with Maven ========"
                        sh "mvn clean test"
                        currentBuild.description += "Testing: ✅\n"
                    } catch (Exception e) {
                        currentBuild.description += "Testing: ❌\n"
                        throw e
                    }
                }
            }
        }
        stage("Packaging") {
            steps {
                script {
                    try {
                        echo "======== Packaging with Maven ========"
                        sh "mvn clean package"
                        currentBuild.description += "Packaging: ✅\n"
                    } catch (Exception e) {
                        currentBuild.description += "Packaging: ❌\n"
                        throw e
                    }
                }
            }
        }
        stage("SonarQube Scan") {
            steps {
                script {
                    try {
                        echo "======== Analyzing with SonarQube ========"
                        withSonarQubeEnv(installationName: 'sonarqube-server') {
                            sh 'mvn sonar:sonar'
                        }
                        currentBuild.description += "SonarQube Scan: ✅\n"
                    } catch (Exception e) {
                        currentBuild.description += "SonarQube Scan: ❌\n"
                        throw e
                    }
                }
            }
        }
        stage("Deploy to Nexus") {
            steps {
                script {
                    try {
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
                        currentBuild.description += "Deploy to Nexus: ✅\n"
                    } catch (Exception e) {
                        currentBuild.description += "Deploy to Nexus: ❌\n"
                        throw e
                    }
                }
            }
        }
        stage("Building Docker Image") {
            steps {
                script {
                    try {
                        sh "docker build -t mohamedaminelarbi/mohamedaminelarbi_stationski ."
                        currentBuild.description += "Building Docker Image: ✅\n"
                    } catch (Exception e) {
                        currentBuild.description += "Building Docker Image: ❌\n"
                        throw e
                    }
                }
            }
        }

       stage("Pushing to DockerHub") {
           steps {
               script {
                   try {
                       withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                           echo "======== Pushing to DockerHub ========"
                           sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                           sh "docker push mohamedaminelarbi/mohamedaminelarbi_stationski"
                       }
                       currentBuild.description += "Pushing to DockerHub: ✅\n"
                   } catch (Exception e) {
                       currentBuild.description += "Pushing to DockerHub: ❌\n"
                       throw e
                   }
               }
           }
       }

        stage("Stopping Containers") {
            steps {
                script {
                    try {
                        sh "docker-compose down"
                        currentBuild.description += "Stopping Containers: ✅\n"
                    } catch (Exception e) {
                        currentBuild.description += "Stopping Containers: ❌\n"
                        throw e
                    }
                }
            }
        }
        stage("Running Containers") {
            steps {
                script {
                    try {
                        sh "docker-compose up -d"
                        currentBuild.description += "Running Containers: ✅\n"
                    } catch (Exception e) {
                        currentBuild.description += "Running Containers: ❌\n"
                        throw e
                    }
                }
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
                            <p>Stages Status:</p>
                            <pre>${currentBuild.description}</pre>
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
                slackSend(channel: '#devops', message: "Build Succeeded: ${env.BUILD_URL}\nStages:\n${currentBuild.description}", color: 'good')
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
                            <p>Stages Status:</p>
                            <pre>${currentBuild.description}</pre>
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
                slackSend(channel: '#devops', message: "Build Failed: ${env.BUILD_URL}\nStages:\n${currentBuild.description}", color: 'danger')
            }
        }
    }
}
