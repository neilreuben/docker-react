pipeline {
    agent any
    
    environment {
        NODE_VERSION = '18'
        DOCKER_IMAGE = 'your-registry/react-vite-app'
        DOCKER_TAG = "${BUILD_NUMBER}"
        
        // Environment variables for different stages
        CI = 'true'
        NODE_ENV = 'production'
    }
    
    tools {
        nodejs "${NODE_VERSION}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                // Clean workspace and checkout code
                deleteDir()
                checkout scm
                
                // Display build information
                echo "Building branch: ${env.GIT_BRANCH}"
                echo "Build number: ${env.BUILD_NUMBER}"
                echo "Commit: ${env.GIT_COMMIT}"
            }
        }
        
        stage('Install Dependencies') {
            steps {
                script {
                    // Cache node_modules for faster builds
                    echo 'Installing npm dependencies...'
                    sh 'npm ci --prefer-offline --no-audit'
                }
            }
        }
        
        stage('Code Quality') {
            parallel {
                stage('Lint') {
                    steps {
                        echo 'Running ESLint...'
                        sh 'npm run lint'
                    }
                    post {
                        always {
                            // Archive lint results if you have a reporter
                            // publishHTML([
                            //     allowMissing: false,
                            //     alwaysLinkToLastBuild: true,
                            //     keepAll: true,
                            //     reportDir: 'lint-results',
                            //     reportFiles: 'index.html',
                            //     reportName: 'ESLint Report'
                            // ])
                        }
                    }
                }
                
                stage('Security Audit') {
                    steps {
                        echo 'Running npm security audit...'
                        sh 'npm audit --audit-level=high'
                    }
                }
            }
        }
        
        stage('Test') {
            steps {
                echo 'Running tests...'
                sh 'npm run test -- --run --coverage'
            }
            post {
                always {
                    // Publish test results
                    publishTestResults(
                        testResultsPattern: 'test-results.xml',
                        allowEmptyResults: true
                    )
                    
                    // Publish coverage reports
                    publishCoverage(
                        adapters: [
                            istanbulCoberturaAdapter('coverage/cobertura-coverage.xml')
                        ],
                        sourceFileResolver: sourceFiles('STORE_LAST_BUILD')
                    )
                }
            }
        }
        
        stage('Build') {
            steps {
                echo 'Building application...'
                sh 'npm run build'
                
                // Archive build artifacts
                archiveArtifacts artifacts: 'dist/**/*', fingerprint: true
            }
            post {
                success {
                    echo 'Build completed successfully!'
                    // You can add build size analysis here
                    sh 'du -sh dist/'
                }
            }
        }
        
        stage('Docker Build') {
            when {
                anyOf {
                    branch 'main'
                    branch 'develop'
                    branch 'master'
                }
            }
            steps {
                script {
                    echo 'Building Docker image...'
                    
                    // Build the Docker image
                    def image = docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                    
                    // Tag as latest for main branch
                    if (env.GIT_BRANCH == 'origin/main' || env.GIT_BRANCH == 'origin/master') {
                        image.tag('latest')
                    }
                    
                    // Push to registry (uncomment when registry is configured)
                    // docker.withRegistry('https://your-registry.com', 'docker-registry-credentials') {
                    //     image.push()
                    //     image.push('latest')
                    // }
                }
            }
        }
        
        stage('Deploy to Staging') {
            when {
                branch 'develop'
            }
            steps {
                echo 'Deploying to staging environment...'
                
                // Example deployment commands
                // sh 'docker-compose -f docker-compose.staging.yml up -d'
                
                // Or using Docker directly
                // sh """
                //     docker stop react-app-staging || true
                //     docker rm react-app-staging || true
                //     docker run -d --name react-app-staging -p 3001:80 ${DOCKER_IMAGE}:${DOCKER_TAG}
                // """
                
                // Health check
                // sh 'curl -f http://staging-server:3001 || exit 1'
            }
        }
        
        stage('Deploy to Production') {
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                }
            }
            steps {
                // Add manual approval for production deployments
                input message: 'Deploy to production?', ok: 'Deploy'
                
                echo 'Deploying to production environment...'
                
                // Example production deployment
                // sh 'docker-compose -f docker-compose.prod.yml up -d'
                
                // Or blue-green deployment
                // sh """
                //     docker stop react-app-blue || true
                //     docker run -d --name react-app-green -p 80:80 ${DOCKER_IMAGE}:${DOCKER_TAG}
                //     # Health check
                //     curl -f http://production-server || exit 1
                //     # Switch traffic
                //     docker stop react-app-blue || true
                //     docker rename react-app-green react-app-blue
                // """
            }
        }
    }
    
    post {
        always {
            // Clean up
            echo 'Cleaning up...'
            
            // Remove Docker images to save space
            sh 'docker image prune -f --filter until=24h'
            
            // Clean workspace
            cleanWs()
        }
        
        success {
            echo 'Pipeline completed successfully!'
            
            // Send success notifications
            // slackSend(
            //     channel: '#deployments',
            //     color: 'good',
            //     message: "✅ Successfully deployed ${env.JOB_NAME} - ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
            // )
        }
        
        failure {
            echo 'Pipeline failed!'
            
            // Send failure notifications
            // slackSend(
            //     channel: '#deployments',
            //     color: 'danger',
            //     message: "❌ Failed to deploy ${env.JOB_NAME} - ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
            // )
            
            // Email notifications
            // emailext(
            //     subject: "Build Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
            //     body: "Build failed. Check console output at ${env.BUILD_URL}",
            //     to: "${env.CHANGE_AUTHOR_EMAIL}"
            // )
        }
        
        unstable {
            echo 'Pipeline is unstable!'
        }
    }
}
