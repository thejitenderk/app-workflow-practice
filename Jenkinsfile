node {
    // SCM Checkout
    stage('SCM') {
        checkout scm
    }

    // SonarQube Analysis
    stage('SonarQube Analysis') {
        // Make sure this name matches your Jenkins SonarQube Scanner tool name
        def scannerHome = tool 'SonarScanner'  
        
        // If you have only one SonarQube installation, no name is needed
        withSonarQubeEnv() {
            sh "${scannerHome}/bin/sonar-scanner"
        }
    }

    // Install npm dependencies
    stage('Install Dependencies') {
        sh 'npm install'
    }

    // Build the project
    stage('Build Project') {
        sh 'npm run build'
    }

    // Ping JFrog Artifactory
    stage('Ping JFrog Artifactory') {
        sh 'jfrog rt ping --server-id=jfrogserv'
    }

    // Upload to JFrog Artifactory
    stage('Upload to JFrog Artifactory') {
        sh '''
            jfrog rt u "inventory_frontend/dist/*" \
            webinar-npm-dev-local/drop-${BUILD_NUMBER}/ \
            --recursive=true \
            --server-id=jfrogserv
        '''
    }
}
