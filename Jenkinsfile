pipeline {
    agent { label 'linux' }
    options {
        buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '3', daysToKeepStr: '', numToKeepStr: '3')
    }
    tools {
        jdk 'JDK'
        nodejs 'NodeJS'
        maven 'Maven'
    }
    
    environment {
        SCANNER_HOME = tool 'SonarScanner'
    }
    
    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Git Checkout') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], 
                    extensions: [], 
                    userRemoteConfigs: [[url: 'https://github.com/ankitkumar596/getting-started-app.git']]
                )
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv(installationName: 'SonarQube') {
                    echo "SonarScanner Path: $SCANNER_HOME"
                    sh '''
                    ${SCANNER_HOME}/bin/sonar-scanner \
                    -Dsonar.projectKey=getting-started-app \
                    -Dsonar.projectName=getting-started-app \
                    -Dsonar.projectVersion=1.0 \
                    -Dsonar.sources=. 
                    '''
                }
            }
        }

        stage('NodeJS Install Dependencies') {
            steps {
                script {
                    sh 'npm install --production'
                }
                
            }
        }

        stage('OSWAP Dependencies Scan') {
            steps {
                echo 'Running Dependency-Check'
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'Dependency-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }

        stage('Trivy FileSystem Scan') {
            steps {
                script {
                    sh 'trivy fs --exit-code 0 --severity HIGH,CRITICAL --no-progress . --format table --output trivy-report.txt || true'
                }
            }
        }

        stage('Docker build & push') {
            steps {
                script {
                    sh 'docker build -t getting-started-todo .'
                    sh 'docker tag getting-started-todo ankitkumar0987/getting-started-todo:latest'
                    withDockerRegistry(credentialsId: 'docker-jenkins-credentials', toolName: 'Docker') {
                        sh '''
                        docker push ankitkumar0987/getting-started-todo:latest
                        '''
                    }
                }
            }
        }

        stage('Trivy Docker Image Scan') {
            steps {
                script {
                    sh 'trivy image ankitkumar0987/getting-started-todo:latest --exit-code 0 --severity HIGH,CRITICAL --no-progress --format table --output trivy-image-report.txt || true'
                }
            }
        }

        stage('Deploy to Docker container') {
            steps {
                echo 'Deploying the application'
                sh 'docker run -d -p 3000:3000 ankitkumar0987/getting-started-todo:latest'
            }
        }

    }
}

