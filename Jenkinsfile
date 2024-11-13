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
                        withSonarQubeEnv('sonarqube-server') {
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
                        echo "======== Deploying to Nexus ========"
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
                        echo "======== Building Docker Image ========"
                        sh "docker build -t mohamedaminelarbi/mohamedaminelarbi_stationski ."
                        currentBuild.description += "Docker Build: ✅\n"
                    } catch (Exception e) {
                        currentBuild.description += "Docker Build: ❌\n"
                        throw e
                    }
                }
            }
        }
       /* stage("Pushing to DockerHub") {
            steps {
                script {
                    try {
                        echo "======== Pushing to DockerHub ========"
                        withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                            sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                            sh "docker push mohamedaminelarbi/mohamedaminelarbi_stationski"
                        }
                        currentBuild.description += "Push to DockerHub: ✅\n"
                    } catch (Exception e) {
                        currentBuild.description += "Push to DockerHub: ❌\n"
                        throw e
                    }
                }
            }
        }*/
        stage("Stopping Containers") {
            steps {
                script {
                    try {
                        echo "======== Stopping Docker Containers ========"
                        sh "docker-compose down"
                        currentBuild.description += "Stop Containers: ✅\n"
                    } catch (Exception e) {
                        currentBuild.description += "Stop Containers: ❌\n"
                        throw e
                    }
                }
            }
        }
        stage("Running Containers") {
            steps {
                script {
                    try {
                        echo "======== Starting Docker Containers ========"
                        sh "docker-compose up -d"
                        currentBuild.description += "Run Containers: ✅\n"
                    } catch (Exception e) {
                        currentBuild.description += "Run Containers: ❌\n"
                        throw e
                    }
                }
            }
        }
        stage("Mail Notification") {
            steps {
                script {
                    echo "======== Sending Email Notification ========"

                    def successStages = currentBuild.description.readLines().findAll { it.endsWith('✅') }
                    def failedStages = currentBuild.description.readLines().findAll { it.endsWith('❌') }
                    def sonarQubeUrl = 'http://192.168.33.10:9000/dashboard?id=tn.esprit.spring%3Agestion-station-ski'

                    def emailBody = """
                        <html>
                            <body>
                                <h2 style="color: ${currentBuild.currentResult == 'SUCCESS' ? 'green' : 'red'};">
                                    Job ${currentBuild.currentResult == 'SUCCESS' ? 'Succeeded' : 'Failed'}
                                </h2>
                                <table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse; width: 100%;">
                                    <thead>
                                        <tr>
                                            <th style="text-align: left; background-color: #f2f2f2;">Stage</th>
                                            <th style="text-align: left; background-color: #f2f2f2;">Status</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        ${successStages.collect { "<tr><td>${it.replace(': ✅', '')}</td><td style='color: green;'>Success ✔️</td></tr>" }.join('\n')}
                                        ${failedStages.collect { "<tr><td>${it.replace(': ❌', '')}</td><td style='color: red;'>Failed ❌</td></tr>" }.join('\n')}
                                    </tbody>
                                </table>
                                <p><b>Build URL:</b> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                                <p><b>SonarQube Report:</b> <a href="${sonarQubeUrl}">${sonarQubeUrl}</a></p>
                                <br/>
                                <p>Best regards,<br/>Jenkins</p>
                            </body>
                        </html>
                    """

                    emailext (
                        subject: "Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' ${currentBuild.currentResult}",
                        body: emailBody,
                        to: "mohamedamine.larbi@esprit.tn",
                        mimeType: 'text/html'
                    )
                }
            }
        }
    }
    post {
        success {
            script {
                emailext (
                    subject: "Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' Succeeded",
                    body: emailBody,
                    to: "mohamedamine.larbi@esprit.tn",
                    mimeType: 'text/html'
                )
            }
        }
        failure {
            script {
                emailext (
                    subject: "Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' Failed",
                    body: emailBody,
                    to: "mohamedamine.larbi@esprit.tn",
                    mimeType: 'text/html'
                )
            }
        }
    }
}
