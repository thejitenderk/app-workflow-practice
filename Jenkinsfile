pipeline {
    agent any

    environment {
        ARTIFACTORY_SERVER = 'jfrogserv'
        BUILD_DIR = "${WORKSPACE}/inventory_frontend/dist"
        TARGET_REPO = "webinar-npm-dev-local/drop-${BUILD_NUMBER}/"
    }

    stages {
        stage('SCM Checkout') {
            steps {
                checkout scm
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarScanner'
                    withSonarQubeEnv('SonarQube') {
                        sh "${scannerHome}/bin/sonar-scanner"
                    }
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Build Project') {
            steps {
                sh 'npm run build'
            }
        }

        stage('Ping JFrog Artifactory') {
            steps {
                sh "jfrog rt ping --server-id=${ARTIFACTORY_SERVER}"
            }
        }

        stage('Upload to JFrog Artifactory') {
            steps {
                sh """
                    jfrog rt u "${BUILD_DIR}/*" ${TARGET_REPO} --recursive=true --server-id=${ARTIFACTORY_SERVER}
                """
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}
