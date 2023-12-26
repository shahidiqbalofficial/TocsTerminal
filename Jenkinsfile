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
                    set -x
                    docker pull shahidiqbal008/distance-converter:${env.BUILD_ID}
                    docker stop distance-converter-container || true
                    docker rm distance-converter-container || true
                    docker run -d --name distance-converter-container -p 80:80 shahidiqbal008/distance-converter:${env.BUILD_ID}
                    set +x
                """
            )]
        )
    ]
)
                  
                    boolean isDeploymentSuccessful = sh(script: 'curl -s -o /dev/null -w "%{http_code}" http://102.37.216.229:80', returnStdout: true).trim() == '200'

                    if (!isDeploymentSuccessful) {
                       
                        def previousSuccessfulTag = readFile('previous_successful_tag.txt').trim()
                        sshPublisher(
                            publishers: [
                                sshPublisherDesc(
                                    configName: "shahidcs",
                                    transfers: [sshTransfer(
                                        execCommand: """
                                            docker pull shahidiqbal008/distance-converter:${previousSuccessfulTag}
                                            docker stop distance-converter-container || true
                                            docker rm distance-converter-container || true
                                            docker run -d --name distance-converter-container -p 80:80 shahidiqbal008/distance-converter:${previousSuccessfulTag}
                                        """
                                    )]
                                )
                            ]
                        )
                    } else {
                       
                        writeFile file: 'previous_successful_tag.txt', text: "${env.BUILD_ID}"
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
