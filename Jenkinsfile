pipeline {
    agent any

    environment {
        SONARQUBE_ENV = 'SonarQube'
        SONAR_TOKEN = credentials('SonarToken')
        NEXUS_URL = 'http://192.168.50.5:8081/repository/maven-releases/tn/esprit/spring/gestion-station-ski/1.0/gestion-station-ski-1.0.jar'
        DOCKER_HUB_CREDENTIALS = credentials('DockerHubCredentials')
        IMAGE_TAG = 'v2' // Nouveau tag pour l'image Docker
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
                    echo 'Building Docker image with Nexus credentials...'
                    withCredentials([usernamePassword(credentialsId: 'NEXUS', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                        sh """
                            docker build \
                                --build-arg NEXUS_USER=$NEXUS_USER \
                                --build-arg NEXUS_PASS=$NEXUS_PASS \
                                --build-arg NEXUS_URL=$NEXUS_URL \
                                -t gestion-station-ski:${IMAGE_TAG} .
                        """
                    }
                }
            }
        }

        stage('Push Image to DockerHub') {
            agent { label 'agent01' }
            steps {
                script {
                    echo 'Logging into Docker Hub...'
                    sh 'docker login -u $DOCKER_HUB_CREDENTIALS_USR -p $DOCKER_HUB_CREDENTIALS_PSW'

                    echo 'Tagging Docker image...'
                    sh "docker tag gestion-station-ski:${IMAGE_TAG} rab3oon/gestion-station-ski:${IMAGE_TAG}"

                    echo 'Pushing Docker image to Docker Hub...'
                    sh "docker push rab3oon/gestion-station-ski:${IMAGE_TAG}"
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
        always {
            echo 'Pipeline execution completed!'
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}