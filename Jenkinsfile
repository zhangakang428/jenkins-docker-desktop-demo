pipeline {
    agent any

    environment {
        IMAGE_TAG = "localhost:5000/jenkins-demo-app:${BUILD_NUMBER}"
        APP_CONTAINER = "jenkins-demo-app"
        APP_NETWORK = "jenkins-demo-net"
    }

    stages {
        stage('Verify Tools') {
            steps {
                sh '''
                    set -eu
                    chmod +x mvnw
                    ./mvnw -version
                    docker version
                    curl -fsS http://registry:5000/v2/
                '''
            }
        }

        stage('Build And Test') {
            steps {
                sh '''
                    set -eu
                    ./mvnw clean package
                    test -f target/app.jar
                '''
            }
        }

        stage('Build Image') {
            steps {
                sh '''
                    set -eu
                    docker build --provenance=false -t "${IMAGE_TAG}" .
                '''
            }
        }

        stage('Push Image') {
            steps {
                sh '''
                    set -eu
                    docker push "${IMAGE_TAG}"
                '''
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    set -eu
                    docker pull "${IMAGE_TAG}"
                    docker rm -f "${APP_CONTAINER}" || true
                    docker run -d \
                        --name "${APP_CONTAINER}" \
                        --network "${APP_NETWORK}" \
                        -p 127.0.0.1:8081:8080 \
                        "${IMAGE_TAG}"
                '''
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                    set +e
                    for i in $(seq 1 30); do
                        if curl -fsS http://jenkins-demo-app:8080/hello; then
                            exit 0
                        fi
                        echo "Waiting for Spring Boot to start (${i}/30)..."
                        sleep 2
                    done

                    docker ps -a
                    docker logs jenkins-demo-app || true
                    exit 1
                '''
            }
        }
    }
}
