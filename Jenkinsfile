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
        stage("Pushing to DockerHub") {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                    sh "docker push mohamedaminelarbi/mohamedaminelarbi_stationski"
                }
            }
        }
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
        stage("Mail Notification") {
            steps {
                script {
                    echo "======== Sending Email Notification ========"
                    def sonarQubeUrl = 'http://192.168.33.10:9000/dashboard?id=tn.esprit.spring%3Agestion-station-ski'
                    mail to: 'mohamedamine.larbi@esprit.tn',
                         subject: "Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' Finished",
                         body: """
                            Job Name: ${env.JOB_NAME}
                            Build Number: ${env.BUILD_NUMBER}
                            Status: ${currentBuild.currentResult}
                            Build URL: ${env.BUILD_URL}
                            SonarQube Report: ${sonarQubeUrl}
                         """
                }
            }
        }
    }
    post {
        success {
            mail to: 'mohamedamine.larbi@esprit.tn',
                 subject: "Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' Succeeded",
                 body: """
                    Job Name: ${env.JOB_NAME}
                    Build Number: ${env.BUILD_NUMBER}
                    Status: SUCCESS
                    Build URL: ${env.BUILD_URL}
                 """
        }
        failure {
            mail to: 'mohamedamine.larbi@esprit.tn',
                 subject: "Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' Failed",
                 body: """
                    Job Name: ${env.JOB_NAME}
                    Build Number: ${env.BUILD_NUMBER}
                    Status: FAILURE
                    Build URL: ${env.BUILD_URL}
                 """
        }
    }
}
