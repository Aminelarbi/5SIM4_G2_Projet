pipeline {

    agent any

    stages {

        stage('GIT') {
            steps {
                echo 'Pulling from Git...'
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

    }

}
