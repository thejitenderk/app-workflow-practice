// node {
//     // SCM Checkout
//     stage('SCM') {
//         checkout scm
//     }

//     // SonarQube Analysis
//     stage('SonarQube Analysis') {
//         // Make sure this name matches your Jenkins SonarQube Scanner tool name
//         def scannerHome = tool 'SonarScanner'  
        
//         // If you have only one SonarQube installation, no name is needed
//         withSonarQubeEnv() {
//             sh "${scannerHome}/bin/sonar-scanner"
//         }
//     }

//     // Install npm dependencies
//     stage('Install Dependencies') {
//         sh 'npm install'
//     }

//     // Build the project
//     stage('Build Project') {
//         sh 'npm run build'
//     }

//     // Ping JFrog Artifactory
//     stage('Ping JFrog Artifactory') {
//         sh 'jfrog rt ping --server-id=jfrogserv'
//     }

//     // Upload to JFrog Artifactory
//     stage('Upload to JFrog Artifactory') {
//         sh '''
//             jfrog rt u "inventory_frontend/dist/*" \
//             webinar-npm-dev-local/drop-${BUILD_NUMBER}/ \
//             --recursive=true \
//             --server-id=jfrogserv
//         '''
//     }
// }



node {
    // 1. Establish Artifactory server and Build Info objects
    // 'jfrogserv' must match the Server ID in Jenkins Manage -> Configure System
    def server = Artifactory.server 'jfrogserv'
    def nodeTool = tool name: 'NodeJS', type: 'jenkins.plugins.nodejs.tools.NodeJSInstallation'
    def buildInfo = Artifactory.newBuildInfo()
    buildInfo.name = "todo"
    buildInfo.number = BUILD_NUMBER

    stage('SCM') {
        checkout scm
    }

    stage('SonarQube Analysis') {
        def scannerHome = tool 'SonarScanner'
        withSonarQubeEnv() {
            sh "${scannerHome}/bin/sonar-scanner"
        }
    }

    stage('Install Dependencies') {
        // 2. Set the npm resolver to your JFrog proxy/virtual repository
        // Replace 'npm-virtual-repo' with your actual JFrog repository key
        rtNpmResolver (
            id: 'npm-resolver-config',
            serverId: 'jfrogserv',
            repo: 'retry-npm'
        )

        // 3. Run npm install through the proxy
        // This automatically collects dependency data for Build Info
        rtNpmInstall (
            resolverId: 'npm-resolver-config',
            buildInfo: buildInfo
        )
    }

    stage('Build Project') {
        sh 'npm run build'
    }

    stage('Upload to Artifactory') {
        // 4. Upload artifacts using a File Spec
        def uploadSpec = """{
            "files": [
                {
                    "pattern": "dist/*",
                    "target": "retry-npm/drop-${BUILD_NUMBER}/",
                    "recursive": "true"
                }
            ]
        }"""
        
        // Use server.upload to link these files to our buildInfo object
        server.upload spec: uploadSpec, buildInfo: buildInfo
    }

    stage('Publish Build Info') {
        // 5. Collect environment variables and send metadata to JFrog
        buildInfo.env.collect()
        server.publishBuildInfo buildInfo
    }
}
