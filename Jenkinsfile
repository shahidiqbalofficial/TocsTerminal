pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                script {
                    dockerImage = docker.build("shahidiqbal008/distance-converter:${env.BUILD_ID}")
                }
            }
        }

        stage('Push') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
                        dockerImage.push()
                    }
                }
            }
        }

        stage('Test') {
            steps {
                sh 'ls -l index.html'
            }
        }

        stage('Deploy') {
            steps {
                script {
                    sshPublisher(
                        publishers: [
                            sshPublisherDesc(
                                configName: "shahidcs", 
                                transfers: [sshTransfer(
                                    execCommand: """
                                        docker pull shahidiqbal008/distance-converter:${env.BUILD_ID}
                                        docker stop distance-converter-container || true
                                        docker rm distance-converter-container || true
                                        docker run -d --name distance-converter-container -p 80:80 shahidiqbal008/distance-converter:${env.BUILD_ID}
                                    """
                                )]
                            )
                        ]
                    )

                    // Additional delay to allow the Docker container to start
                    sleep time: 10, unit: 'SECONDS'

                    // Check if the deployment is successful
                    boolean isDeploymentSuccessful = sh(script: 'curl -s -o /dev/null -w "%{http_code}" http://102.37.216.229:80', returnStatus: true) == 200

                    if (!isDeploymentSuccessful) {
                        currentBuild.result = 'FAILURE'
                        error 'Deployment failed'
                    }
                }
            }
        }
    }

    post {
        failure {
            mail(
                to: 'shahidiqbalofficial.is@gmail.com',
                subject: "Failed Pipeline: ${env.JOB_NAME} [${env.BUILD_NUMBER}]",
                body: """Something is wrong with the build ${env.BUILD_URL}
                Rolling back to the previous version

                Regards,
                Jenkins
                """
            )
        }
    }
}
