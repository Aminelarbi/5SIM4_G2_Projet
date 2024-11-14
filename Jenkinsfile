pipeline {
    agent any
    stages {
        stage("Cloning") {
            steps {
                script {
                    try {
                        echo "======== Cloning with Git ========"
                        git url: "git@github.com:Aminelarbi/5SIM4_G2_Projet.git",
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

      /*stage("Pushing to DockerHub") {
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
       }*/

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
                  def successStages = currentBuild.description.readLines().findAll { it.endsWith('✅') }.join('\n')
                  def failedStages = currentBuild.description.readLines().findAll { it.endsWith('❌') }.join('\n')
                  slackSend(channel: '#devops', message: "*Build succeeded:* ${env.BUILD_URL}\n\nSuccessful Stages:\n${successStages}\n\nFailed Stages:\n${failedStages}", color: 'good')
                  def emailBody = """
                  <html>
                      <body>
                          <h2 style="color: green;">BUILD WAS SUCCESSFUL!</h2>
                          <p>The build <b>${env.BUILD_NUMBER}</b> for Job <b>${env.JOB_NAME}</b> was successful.</p>
                          <p><strong>Build URL:</strong> <a href='${env.BUILD_URL}'>${env.BUILD_URL}</a></p>
                          <p><strong>Build Duration:</strong> ${currentBuild.durationString}</p>

                          <table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse; width: 100%;">
                              <thead>
                                  <tr>
                                      <th style="text-align: left;">Stage</th>
                                      <th style="text-align: left;">Status</th>
                                  </tr>
                              </thead>
                              <tbody>
                                  ${successStages ? successStages.replaceAll(/(.+?): ✅/, '<tr><td>$1</td><td style="color: green;">Success ✔️</td></tr>') : '<tr><td colspan="2">No stages succeeded.</td></tr>'}
                                  ${failedStages ? failedStages.replaceAll(/(.+?): ❌/, '<tr><td>$1</td><td style="color: red;">Failed ❌</td></tr>') : '<tr><td colspan="2"><b>No stages failed.</b></td></tr>'}
                              </tbody>
                          </table>
                          <br/>
                          <p>Best regards,<br/>Jenkins</p>
                      </body>
                  </html>
                  """

                  emailext (
                      subject: "Build Succeeded: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                      body: emailBody,
                      to: "mohamedamine.larbi@esprit.tn",
                      mimeType: 'text/html'
                  )
              }
          }
          failure {
              script {
                  def successStages = currentBuild.description.readLines().findAll { it.endsWith('✅') }.join('\n')
                  def failedStages = currentBuild.description.readLines().findAll { it.endsWith('❌') }.join('\n')
                  slackSend(channel: '#devops', message: "*Build failed:* ${env.BUILD_URL}\n\nSuccessful Stages:\n${successStages}\n\nFailed Stages:\n${failedStages}", color: 'danger')
                  def emailBody = """
                  <html>
                      <body>
                          <h2 style="color: red;">Build Failed!</h2>
                          <p>The build <b>${env.BUILD_NUMBER}</b> for Job <b>${env.JOB_NAME}</b> has failed.</p>
                          <p><strong>Build URL:</strong> <a href='${env.BUILD_URL}'>${env.BUILD_URL}</a></p>
                          <p><strong>Build Duration:</strong> ${currentBuild.durationString}</p>

                          <table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse; width: 100%;">
                              <thead>
                                  <tr>
                                      <th style="text-align: left;">Stage</th>
                                      <th style="text-align: left;">Status</th>
                                  </tr>
                              </thead>
                              <tbody>
                                  ${successStages ? successStages.replaceAll(/(.+?): ✅/, '<tr><td>$1</td><td style="color: green;">Success ✔️</td></tr>') : '<tr><td colspan="2">No stages succeeded.</td></tr>'}
                                  ${failedStages ? failedStages.replaceAll(/(.+?): ❌/, '<tr><td>$1</td><td style="color: red;">Failed ❌</td></tr>') : '<tr><td colspan="2"><b>No stages failed.</b></td></tr>'}
                              </tbody>
                          </table>
                          <br/>
                          <p>Best regards,<br/>Jenkins</p>
                      </body>
                  </html>
                  """

                  emailext (
                      subject: "Build Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                      body: emailBody,
                      to: "mohamedamine.larbi@esprit.tn",
                      mimeType: 'text/html'
                  )
              }
          }
      }
}
