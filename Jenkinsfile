pipeline {
    agent any
    
    environment {
        // AWS Configuration
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = sh(script: 'aws sts get-caller-identity --query Account --output text', returnStdout: true).trim()
        
        // Project Configuration
        PROJECT_NAME = 'devops-pipeline-task6'
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
        // Stage 1: Checkout Code
        stage('Checkout Git') {
            steps {
                echo '🚀 Starting DevOps Pipeline - Task 6'
                echo "📦 Build Number: ${BUILD_NUMBER}"
                
                checkout scm
                
                script {
                    withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                        echo '✅ AWS credentials configured'
                    }
                }
            }
        }
        
        // Stage 2: Terraform Plan
        stage('Terraform Plan') {
            steps {
                echo '🏗️ Planning Infrastructure with Terraform...'
                dir("${INFRA_DIR}") {
                    script {
                        withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                            sh '''
                            terraform init
                            terraform validate
                            terraform plan -out=tfplan
                            '''
                        }
                    }
                }
            }
        }
        
        // Stage 3: Manual Approval
        stage('Approve Infrastructure') {
            steps {
                echo '⏳ Waiting for manual approval...'
                timeout(time: 15, unit: 'MINUTES') {
                    input(
                        message: 'Apply Terraform infrastructure?',
                        ok: 'Apply Infrastructure'
                    )
                }
            }
        }
        
        // Stage 4: Terraform Apply
        stage('Terraform Apply') {
            steps {
                echo '🚀 Applying Infrastructure...'
                dir("${INFRA_DIR}") {
                    script {
                        withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                            sh 'terraform apply -auto-approve tfplan'
                        }
                    }
                }
            }
        }
        
        // Stage 5: Build Docker Image
        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker Image...'
                dir("${APP_DIR}") {
                    script {
                        sh """
                        docker build \
                            -t ${IMAGE_TAG} \
                            -t ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:latest \
                            .
                        """
                    }
                }
            }
        }
        
        // Stage 6: Security Scan - Trivy
        stage('Security Scan - Trivy') {
            steps {
                echo '🔒 Scanning Docker Image with Trivy...'
                script {
                    sh """
                    # Install Trivy if not present
                    if ! command -v trivy &> /dev/null; then
                        curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
                    fi
                    
                    # Scan the Docker image
                    trivy image \
                        --severity HIGH,CRITICAL \
                        --exit-code 0 \
                        --format table \
                        ${IMAGE_TAG}
                    
                    echo "✅ Trivy security scan completed"
                    """
                }
            }
        }
        
        // Stage 7: OWASP Dependency Check
        stage('OWASP Dependency Check') {
            steps {
                echo '🛡️ Running OWASP Dependency Check...'
                dir("${APP_DIR}") {
                    script {
                        sh '''
                        # Install OWASP Dependency Check
                        wget -q https://github.com/jeremylong/DependencyCheck/releases/download/v8.2.1/dependency-check-8.2.1-release.zip
                        unzip -q dependency-check-8.2.1-release.zip
                        
                        # Run dependency check
                        ./dependency-check/bin/dependency-check.sh \
                            --project "${PROJECT_NAME}" \
                            --scan "." \
                            --out "owasp-report.html" \
                            --format HTML
                        
                        echo "✅ OWASP Dependency Check completed"
                        '''
                    }
                }
            }
        }
        
        // Stage 8: Push to ECR
        stage('Push to ECR') {
            steps {
                echo '📦 Pushing Docker Image to ECR...'
                script {
                    withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                        sh """
                        # Login to ECR
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                        
                        # Push image with build number tag
                        docker push ${IMAGE_TAG}
                        
                        # Also push latest tag
                        docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:latest
                        """
                    }
                }
            }
        }
        
        // Stage 9: Configure Kubernetes
        stage('Configure Kubernetes') {
            steps {
                echo '⚙️ Configuring Kubernetes Access...'
                script {
                    withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                        sh """
                        # Update kubeconfig for EKS cluster
                        aws eks update-kubeconfig \
                            --region ${AWS_REGION} \
                            --name ${CLUSTER_NAME}
                        
                        # Verify cluster access
                        kubectl cluster-info
                        kubectl get nodes
                        """
                    }
                }
            }
        }
        
        // Stage 10: Deploy to EKS
        stage('Deploy to EKS') {
            steps {
                echo '🎯 Deploying to EKS Cluster...'
                dir("${K8S_DIR}") {
                    script {
                        withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                            sh """
                            # Replace image placeholder in deployment
                            sed -i 's|IMAGE_PLACEHOLDER|${IMAGE_TAG}|g' deployment.yaml
                            
                            # Create namespace if it doesn't exist
                            kubectl create namespace ${PROJECT_NAME} --dry-run=client -o yaml | kubectl apply -f -
                            
                            # Deploy application
                            kubectl apply -f deployment.yaml -n ${PROJECT_NAME}
                            kubectl apply -f service.yaml -n ${PROJECT_NAME}
                            kubectl apply -f hpa.yaml -n ${PROJECT_NAME}
                            
                            # Wait for deployment to complete
                            kubectl rollout status deployment/flaskapp -n ${PROJECT_NAME} --timeout=300s
                            
                            # Verify deployment
                            kubectl get pods,svc,hpa -n ${PROJECT_NAME}
                            """
                        }
                    }
                }
            }
        }
        
        // Stage 11: Integration Tests
        stage('Integration Tests') {
            steps {
                echo '🧪 Running Integration Tests...'
                script {
                    withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                        sh """
                        # Get the service URL
                        SERVICE_URL=\$(kubectl get svc/flaskapp-service -n ${PROJECT_NAME} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
                        
                        # Wait for service to be ready
                        echo "Waiting for service to be ready..."
                        until curl -f http://\${SERVICE_URL}/health; do
                            sleep 10
                        done
                        
                        # Run tests
                        echo "✅ Service is ready!"
                        echo "Testing health endpoint..."
                        curl -f http://\${SERVICE_URL}/health
                        
                        echo "Testing main endpoint..."
                        curl -f http://\${SERVICE_URL}/
                        
                        echo "✅ All integration tests passed!"
                        """
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo '🧹 Cleaning up workspace...'
            sh 'docker system prune -f || true'
            archiveArtifacts artifacts: '**/*.html'
        }
        success {
            echo '✅ Pipeline Succeeded! 🎉'
        }
        failure {
            echo '❌ Pipeline Failed!'
        }
    }
}
