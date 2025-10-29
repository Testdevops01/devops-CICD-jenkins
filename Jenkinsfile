pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        PROJECT_NAME = 'devops-CICD-jenkins'
        APP_NAME = 'flaskapp'
        CLUSTER_NAME = 'eks-devops-cluster'
        ECR_REPO_NAME = 'my-app'
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
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: '843559766730']]) {
                    script {
                        sh '''
                            export AWS_REGION=us-east-1
                            echo "🔑 Verifying AWS identity..."
                            aws sts get-caller-identity
                        '''
                        AWS_ACCOUNT_ID = sh(
                            script: "aws sts get-caller-identity --query Account --output text",
                            returnStdout: true
                        ).trim()
                        IMAGE_TAG = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${BUILD_NUMBER}"
                        echo "✅ Using AWS Account: ${AWS_ACCOUNT_ID}"
                    }
                }
            }
        }

        stage('Terraform Init & Plan') {
            steps {
                echo '🏗️ Initializing and Planning Infrastructure...'
                dir("${INFRA_DIR}") {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: '843559766730']]) {
                        sh '''
                            export AWS_REGION=us-east-1
                            terraform init -input=false
                            terraform plan -input=false -out=tfplan
                        '''
                    }
                }
            }
        }

        // You can later add stages like:
        // stage('Build & Push Docker Image')
        // stage('Deploy to EKS')
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

