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
        SONARQUBE_ENV = 'sonarqube'  // SonarQube Server name (as configured in Jenkins)
    }

    stages {

        /* === STAGE 1: CHECKOUT CODE === */
        stage('Checkout Git') {
            steps {
                echo '🚀 Starting DevOps CI/CD Pipeline...'
                checkout scm
            }
        }

        /* === STAGE 2: SONARQUBE SCAN (Local CLI Version) === */
stage('SonarQube Code Analysis') {
    steps {
        echo '🔎 Running SonarQube static code analysis...'
        script {
            withSonarQubeEnv("${SONARQUBE_ENV}") {
                sh '''
                    echo "🔍 Starting SonarQube analysis using local scanner..."
                    cd ${APP_DIR}
                    sonar-scanner \
                        -Dsonar.projectKey=${PROJECT_NAME} \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=$SONAR_HOST_URL \
                        -Dsonar.login=$SONAR_AUTH_TOKEN
                '''
            }
        }
    }
}


        /* === STAGE 3: OWASP Dependency Check === */
        stage('OWASP Dependency Check') {
            steps {
                echo '🧠 Running OWASP Dependency Check...'
                dependencyCheck additionalArguments: '--scan ${APP_DIR} --format XML --out .', odcInstallation: 'Default'
                dependencyCheckPublisher pattern: 'dependency-check-report.xml'
            }
        }

        /* === STAGE 4: SETUP AWS === */
        stage('Setup AWS Credentials') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: '843559766730']]) {
                        sh '''
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

        /* === STAGE 5: TERRAFORM INIT & PLAN === */
        stage('Terraform Init & Plan') {
            steps {
                echo '🏗️ Initializing and Planning Infrastructure...'
                dir("${INFRA_DIR}") {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: '843559766730']]) {
                        sh '''
                            export AWS_REGION=${AWS_REGION}
                            terraform init -input=false
                            terraform plan -input=false -out=tfplan
                        '''
                    }
                }
            }
        }

        /* === STAGE 6: TERRAFORM APPLY === */
        stage('Terraform Apply') {
            steps {
                echo '🚀 Applying Infrastructure Changes...'
                dir("${INFRA_DIR}") {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: '843559766730']]) {
                        sh '''
                            terraform apply -auto-approve tfplan
                        '''
                    }
                }
            }
        }

        /* === STAGE 7: BUILD & PUSH DOCKER IMAGE === */
        stage('Build & Push Docker Image') {
            steps {
                echo '🐳 Building and pushing Docker image...'
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: '843559766730']]) {
                        sh '''
                            AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
                            IMAGE_TAG=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${BUILD_NUMBER}

                            echo "🔑 Logging in to ECR..."
                            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

                            echo "🏗️ Building Docker image..."
                            docker build -t ${IMAGE_TAG} ${APP_DIR}

                            echo "📦 Pushing Docker image to ECR..."
                            docker push ${IMAGE_TAG}
                        '''
                    }
                }
            }
        }

        /* === STAGE 8: TRIVY IMAGE SCAN === */
        stage('Trivy Image Scan') {
            steps {
                echo '🔍 Running Trivy vulnerability scan...'
                script {
                    sh '''
                        AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
                        IMAGE_TAG=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${BUILD_NUMBER}

                        echo "🔎 Scanning Docker image for HIGH and CRITICAL vulnerabilities..."
                        trivy image --exit-code 0 --severity HIGH,CRITICAL ${IMAGE_TAG} > trivy-report.txt

                        echo "✅ Trivy scan completed. Report saved to trivy-report.txt"
                        cat trivy-report.txt
                    '''
                }
            }
        }

        /* === STAGE 9: DEPLOY TO EKS === */
        stage('Deploy to EKS') {
            steps {
                echo '🚀 Deploying application to Amazon EKS...'
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: '843559766730']]) {
                    sh '''
                        aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}
                        kubectl apply -f ${K8S_DIR}/deployment.yaml
                        kubectl apply -f ${K8S_DIR}/service.yaml
                        kubectl rollout status deployment/${APP_NAME} -n default
                    '''
                }
            }
        }
    }

    /* === POST-STEPS === */
    post {
        always {
            echo '🧹 Cleaning up workspace...'
            cleanWs()
        }
        success {
            echo '✅ Pipeline succeeded successfully 🎉'
        }
        failure {
            echo '❌ Pipeline failed. Check logs above for details.'
        }
    }
}

