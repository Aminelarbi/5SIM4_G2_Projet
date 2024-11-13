pipeline {
    agent any

    environment {
        SONARQUBE_ENV = 'SonarQube'
        SONAR_TOKEN = credentials('SonarToken')
        DOCKER_HUB_CREDENTIALS = credentials('DockerHubCredentials')
        IMAGE_TAG = 'v4'
        DOCKER_IMAGE='anas_rebai_5sim4_g2_back_ski'
    }

    stages {

        stage('Checkout GIT') {
            agent { label 'master' }
            steps {
                echo 'Pulling from Git repository...'
                git branch: 'AnasRebai_G2_StationSKI',
                    url: 'https://github.com/Anas-REBAI/5SIM4_G2_Projet.git'
            }
        }

        stage('Clean Build && Unit Tests') {
            agent { label 'master' }
            steps {
                script {
                    echo 'Compiling the project...'
                    sh 'mvn clean install -DskipTests=false'
                }
            }
        }

        stage('SONARQUBE Analysis') {
            agent { label 'master' }
            steps {
                script {
                    echo 'Running SonarQube analysis...'
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

        stage('Deploy to NEXUS') {
            agent { label 'agent01' }
            steps {
                script {
                    echo "Deploying artifact to Nexus..."
                    withCredentials([usernamePassword(credentialsId: 'NEXUS', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                        sh 'mvn -X deploy -DskipTests=true -Dnexus.username=$NEXUS_USER -Dnexus.password=$NEXUS_PASS'
                    }
                }
            }
        }

        stage('Build Docker Image') {
            agent { label 'agent01' }
            steps {
                script {
                    def nexusUrl = "http://192.168.50.5:8081"
                    def groupId = "tn.esprit.spring"
                    def artifactId = "gestion-station-ski"
                    def version = "1.4"

                    sh """
                        docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} \
                            --build-arg NEXUS_URL=${nexusUrl} \
                            --build-arg GROUP_ID=${groupId} \
                            --build-arg ARTIFACT_ID=${artifactId} \
                            --build-arg VERSION=${version} .
                    """
                }
            }
        }

        /*stage('Trivy Security Scan') {
            agent { label 'agent01' }
            steps {
                script {
                    sh "trivy image  rab3oon/${DOCKER_IMAGE}:${IMAGE_TAG} >scanImage.txt"
                }
            }
        }*/

        stage('Push Image to DockerHub') {
            agent { label 'agent01' }
            steps {
                script {
                    echo 'Logging into Docker Hub...'
                    sh 'docker login -u $DOCKER_HUB_CREDENTIALS_USR -p $DOCKER_HUB_CREDENTIALS_PSW'

                    echo 'Tagging Docker image...'
                    sh "docker tag ${DOCKER_IMAGE}:${IMAGE_TAG} rab3oon/${DOCKER_IMAGE}:${IMAGE_TAG}"

                    echo 'Pushing Docker image to Docker Hub...'
                    sh "docker push rab3oon/${DOCKER_IMAGE}:${IMAGE_TAG}"
                }
            }
        }

        stage('Deploy to AKS') {
            agent { label 'agent01' }
            steps {
                script {
                    def clusterExists = sh(script: 'kubectl get nodes', returnStatus: true) == 0

                    if (clusterExists) {
                        echo "The AKS cluster exists and is accessible."
                        sh 'kubectl apply -f deploy.yml'
                    } else {
                        echo "The AKS cluster does not exist. Creating the cluster with Terraform."
                        sh '''
                            terraform init
                            terraform apply -auto-approve
                        '''
                        sleep 60
                        sh 'az aks get-credentials --resource-group myResourceGroup --name myAKSCluster --overwrite-existing'
                        sh 'kubectl apply -f deploy.yml'
                    }
                }
            }
        }
    }

    post {
        success {
            script {
                slackSend(
                    channel: '#jenkins',
                    message: "Le build de pipeline Backend a réussi : ${env.JOB_NAME} #${env.BUILD_NUMBER} ! Image pushed: ${DOCKER_IMAGE}:${IMAGE_TAG} successfully"
                )
            }
        }
        failure {
            script {
                slackSend(
                    channel: '#jenkins',
                    message: "Le build de pipeline Backend a échoué : ${env.JOB_NAME} #${env.BUILD_NUMBER}."
                )
            }
        }
        always {
            echo 'Pipeline has finished execution'
        }
    }
}