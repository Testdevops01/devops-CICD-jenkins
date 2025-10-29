pipeline {
    agent any
    
    environment {
        // AWS Configuration
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = sh(script: 'aws sts get-caller-identity --query Account --output text', returnStdout: true).trim()
        
        // Project Configuration
        PROJECT_NAME = 'devops-CICD-jenkins'
        APP_NAME = 'flaskapp'
        CLUSTER_NAME = 'eks-devops-cluster'
        
        // Image Configuration
        ECR_REPO_NAME = 'my-app'
        IMAGE_TAG = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${BUILD_NUMBER}"
        
        // Paths
        INFRA_DIR = 'infrastructure'
        APP_DIR = 'app'
        K8S_DIR = 'app/k8s'
    }
    
    stages {
        stage('Checkout Git') {
            steps {
                echo '🚀 Starting DevOps Pipeline'
                checkout scm
            }
        }
        
        stage('Setup AWS') {
            steps {
                script {
                    withAWS(credentials: '843559766730', region: "${AWS_REGION}") {
                        sh 'aws sts get-caller-identity'
                    }
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                echo '🏗️ Planning Infrastructure...'
                dir("${INFRA_DIR}") {
                    script {
                        withAWS(credentials: '843559766730', region: "${AWS_REGION}") {
                            sh '''
                            terraform init
                            terraform plan
                            '''
                        }
                    }
                }
            }
        }
        
        // Add other stages as needed...
    }
    
    post {
        always {
            echo '🧹 Cleaning up workspace...'
        }
        success {
            echo '✅ Pipeline Succeeded! 🎉'
        }
        failure {
            echo '❌ Pipeline Failed!'
        }
    }
}
