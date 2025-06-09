pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'insurance-app'
        DOCKER_TAG = "${BUILD_NUMBER}"
        KUBE_NAMESPACE = 'insurance-app'
    }
    
    stages {
        stage('Test') {
            steps {
                sh '''
                    python -m pip install --upgrade pip
                    pip install -r requirements.txt
                    pip install pytest pytest-cov pytest-xdist
                    pytest --cov=./ --cov-report=xml -v
                '''
            }
        }
        
        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                '''
            }
        }
        
        stage('Deploy to Minikube') {
            steps {
                sh '''
                    # Убедимся, что minikube запущен
                    minikube status || minikube start
                    
                    # Настроим Docker для работы с minikube
                    eval $(minikube docker-env)
                    
                    # Пересоберем образ внутри minikube
                    docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                    
                    # Создадим namespace если его нет
                    kubectl create namespace ${KUBE_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
                    
                    # Применим конфигурацию Kubernetes
                    kubectl apply -f k8s/
                    
                    # Обновим deployment с новым образом
                    kubectl set image deployment/insurance-app insurance-app=${DOCKER_IMAGE}:${DOCKER_TAG} -n ${KUBE_NAMESPACE} || \
                    kubectl create deployment insurance-app --image=${DOCKER_IMAGE}:${DOCKER_TAG} -n ${KUBE_NAMESPACE}
                    
                    # Дождемся завершения rollout
                    kubectl rollout status deployment/insurance-app -n ${KUBE_NAMESPACE}
                '''
            }
        }
    }
    
    post {
        always {
            sh '''
                # Очистка
                docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG} || true
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