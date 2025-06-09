pipeline {
    agent any // Указываем, что пайплайн может выполняться на любом доступном агенте (в данном случае, сам Jenkins в контейнере)

    environment {
        // Переменные окружения для Jenkinsfile в синтаксисе Groovy
        DOCKER_IMAGE = 'insurance-app'
        DOCKER_TAG = "${BUILD_NUMBER}" // BUILD_NUMBER - это встроенная переменная Jenkins
        KUBE_NAMESPACE = 'insurance-app'
    }

    stages {
        stage('Test') {
            steps {
                bat '''
                    python -m pip install --upgrade pip
                    pip install -r requirements.txt
                    pip install pytest pytest-cov pytest-xdist
                    pytest --cov=./ --cov-report=xml -v
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                bat '''
                    docker build -t %DOCKER_IMAGE%:%DOCKER_TAG% .
                '''
            }
        }

        stage('Deploy to Minikube') {
            steps {
                bat '''
                    minikube status || minikube start
                    
                    @FOR /f "tokens=*" %%i IN ('minikube docker-env') DO @%%i
                    
                    docker build -t %DOCKER_IMAGE%:%DOCKER_TAG% .
                    
                    kubectl create namespace %KUBE_NAMESPACE% --dry-run=client -o yaml | kubectl apply -f -
                    
                    kubectl apply -f k8s/
                    
                    kubectl set image deployment/%DOCKER_IMAGE% %DOCKER_IMAGE%=%DOCKER_IMAGE%:%DOCKER_TAG% -n %KUBE_NAMESPACE%
                    
                    kubectl rollout status deployment/%DOCKER_IMAGE% -n %KUBE_NAMESPACE%
                '''
            }
        }
    }

    post {
        always {
            bat '''
                docker rmi %DOCKER_IMAGE%:%DOCKER_TAG% || exit 0
            '''
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}