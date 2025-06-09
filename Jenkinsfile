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
                // Используем 'sh' для выполнения команд в Linux
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
                    # Используем 'sh' и синтаксис переменных Bash
                    docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                '''
            }
        }

        stage('Deploy to Minikube') {
            steps {
                sh '''
                    # Используем 'sh' для выполнения команд в Linux
                    # REM - это комментарий для Windows, в Linux используются '#'
                    # Убедимся, что minikube запущен
                    minikube status || minikube start

                    # Настроим Docker для работы с minikube
                    # Эта команда экспортирует переменные окружения, которые нужны Docker для работы с Minikube
                    eval $(minikube docker-env)

                    # Пересоберем образ внутри minikube
                    # Это важно, чтобы образ был доступен для Minikube без пуша в публичный реестр
                    docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .

                    # Создадим namespace если его нет
                    # --dry-run=client -o yaml | kubectl apply -f - это стандартный способ создать ресурс, только если его нет
                    kubectl create namespace ${KUBE_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

                    # Применим конфигурацию Kubernetes
                    # Убедись, что твои манифесты лежат в папке 'k8s/'
                    kubectl apply -f k8s/

                    # Обновим deployment с новым образом
                    # kubectl set image - предпочтительный способ обновить образ в существующем деплойменте.
                    # Если деплоймента нет, он его создаст (но обычно мы создаем его через kubectl apply -f k8s/ ранее)
                    kubectl set image deployment/${DOCKER_IMAGE} ${DOCKER_IMAGE}=${DOCKER_IMAGE}:${DOCKER_TAG} -n ${KUBE_NAMESPACE}

                    # Дождемся завершения rollout
                    kubectl rollout status deployment/${DOCKER_IMAGE} -n ${KUBE_NAMESPACE}
                '''
            }
        }
    }

    post {
        always {
            sh '''
                # Очистка: удаляем локальный Docker-образ после завершения пайплайна
                # '|| true' вместо '|| exit 0' используется, чтобы команда не привела к падению post-секций, если образа нет
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