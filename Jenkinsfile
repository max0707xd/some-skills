pipeline {
    agent any
        
    options {
        timestamps()
        timeout(time:15, unit:'MINUTES')
        buildDiscarder(logRotator(
          numToKeepStr: '4',
          daysToKeepStr: '7',
          artifactNumToKeepStr: '30'))
    }
    tools {
    maven 'maven-3.6.2'
    terraform 'terraform-1.3.2'
    }
    stages {
        
        stage('Checkout') {
            
            steps {
                deleteDir()
                checkout([
                $class: 'GitSCM',
                branches: [[name: "*/master", name: "*/feature/*", name: "*/release**"]],
                extensions: [],
                userRemoteConfigs: [[credentialsId: 'max-gitlab',
                url: 'git@gitlab:jenkins/ted-search.git']]])
            }
        }
        stage('Build'){
            steps{
                echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
                echo "@@@@@@@@@@ B U I L D I N G @@@@@@@@@@"
                echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
                sh "mvn -T 4C clean package -DskipTests"
            }
        }
        
        stage('Test'){
            steps{
                echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
                echo "@@@@@@@@@@@ T E S T I N G @@@@@@@@@@@"
                echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
                sh "mvn clean test"
            }
        }
        
        stage('Publish') {
            when {
                changelog ".*#test.*"
            }
            steps {
                    sh """
                    apt install awscli -y || true
                    echo AWSCLI INSTALLED
                    aws configure set aws_access_key_id AWS_ACCESS_KEY_ID
                    aws configure set aws_secret_access_key AWS_SECRET_ACCESS_KEY
                    aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin 644435390668.dkr.ecr.eu-north-1.amazonaws.com
                    aws ecr create-repository \
                        --repository-name max-ted-search \
                        --image-scanning-configuration scanOnPush=true \
                        --region eu-north-1 || true
                    docker tag embedash:latest 644435390668.dkr.ecr.eu-north-1.amazonaws.com/max-ted-search:latest
                    docker push 644435390668.dkr.ecr.eu-north-1.amazonaws.com/max-ted-search:latest
                    
                    """
            }
        }

        stage('Prepare DEVELOPMENT infrastructure') {
            when {
                changelog ".*#test.*"
            }
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'maxnorth.pem', keyFileVariable: 'maxnorth.pem')]) {
                    sh """
                    terraform workspace select development
                    terraform init
                    terraform plan -var-file ttdev.tfvars
                    terraform apply --auto-approve -var-file ttdev.tfvars
                    """
                }
            }
        }
        
        stage('Relax') {
            when {
                changelog ".*#test.*"
            }
            steps {
                sh "echo RELAXING"
                sh "echo On the serious note, need to wait for docker to install on newly created ec2"
                sh "sleep 45"
            }
        }

        stage('Deploy on prepared DEVELOPMENT ec2') {
            when {
                changelog ".*#test.*"
            }
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'maxnorth.pem', keyFileVariable: 'MAXKEY')]) {

                    sh """ssh -i \"${MAXKEY}" -o \"StrictHostKeyChecking=no\" ubuntu@ec2-16-170-96-8.eu-north-1.compute.amazonaws.com \
                    "sleep 1; \
                    date >> creation.log"
                    """
                    
                    sh """ssh -i \"${MAXKEY}" -o \"StrictHostKeyChecking=no\" ubuntu@ec2-16-170-96-8.eu-north-1.compute.amazonaws.com \
                    "sudo apt-get update; \
                    sudo apt-get install awscli -y; aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID; \
                    aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY; \
                    aws ecr get-login-password --region eu-north-1 | sudo docker login --username AWS --password-stdin 644435390668.dkr.ecr.eu-north-1.amazonaws.com"
                    """
                    
                    sh """ssh -i \"${MAXKEY}" -o \"StrictHostKeyChecking=no\" ubuntu@ec2-16-170-96-8.eu-north-1.compute.amazonaws.com \
                    "sudo docker rm -f \$(docker ps -aq) || true; \
                    sudo docker pull 644435390668.dkr.ecr.eu-north-1.amazonaws.com/max-ted-search:latest; \
                    sudo docker tag 644435390668.dkr.ecr.eu-north-1.amazonaws.com/max-ted-search:latest embedash:latest; \
                    sudo docker network prune -f; \
                    sudo docker-compose down; \
                    sudo docker-compose up -d"
                    
                    """
                }
            }
        }

        stage('E2E Tests'){
            when {
                changelog ".*#test.*"
            }
            steps{
                    sh """
                    
                    sleep 10
                    
                    curl -X HEAD -I http://16.170.96.8:81
                    curl -X HEAD -I http://16.170.96.8:81/api/search?q=idan
                    curl            http://16.170.96.8:81/api/search?q=idan
                    
                    """
            }
        }

        stage('Prepare PRODUCTION infrastructure') {
            when {
                branch "/*release**"
            }
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'maxkey.pem', keyFileVariable: 'maxkey.pem')]) {
                    sh """
                    terraform workspace select production
                    terraform init
                    terraform plan -var-file ttprod.tfvars
                    terraform apply --auto-approve -var-file ttprod.tfvars
                    """
                }
            }
        }
        
        stage('Relaxig for production docker') {
            when {
                branch "/*release**"
            }
            steps {
                sh "echo RELAXING"
                sh "echo On the serious note, need to wait for docker to install on newly created ec2"
                sh "sleep 45"
            }
        }

        stage('Deploy on prepared PRODUCTION ec2') {
            when {
                branch "/*release**"
            }
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'maxkey.pem', keyFileVariable: 'MAXKEY')]) {

                    sh """ssh -i \"${MAXKEY}" -o \"StrictHostKeyChecking=no\" ubuntu@ec2-52-57-2-114.eu-central-1.compute.amazonaws.com \
                    "sleep 1; \
                    date >> creation.log"
                    """
                    
                    sh """ssh -i \"${MAXKEY}" -o \"StrictHostKeyChecking=no\" ubuntu@ec2-52-57-2-114.eu-central-1.compute.amazonaws.com \
                    "sudo apt-get update; \
                    sudo apt-get install awscli -y; aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID; \
                    aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY; \
                    aws ecr get-login-password --region eu-north-1 | sudo docker login --username AWS --password-stdin 644435390668.dkr.ecr.eu-north-1.amazonaws.com"
                    """
                    
                    sh """ssh -i \"${MAXKEY}" -o \"StrictHostKeyChecking=no\" ubuntu@ec2-52-57-2-114.eu-central-1.compute.amazonaws.com \
                    "sudo docker rm -f \$(docker ps -aq) || true; \
                    sudo docker pull 644435390668.dkr.ecr.eu-north-1.amazonaws.com/max-ted-search:latest; \
                    sudo docker tag 644435390668.dkr.ecr.eu-north-1.amazonaws.com/max-ted-search:latest embedash:latest; \
                    sudo docker network prune -f; \
                    sudo docker-compose down; \
                    sudo docker-compose up -d"
                    
                    """
                }
            }
        }
    }
    post { 
        always { 
        echo 'Post stage'
        }

        success {
            emailext attachLog: true, body: 'build successful', subject: 'Jenkins email SUCCESS ', to: 'maxmjw@gmail.com'
        }

        failure {
            emailext attachLog: true, body: 'feature build failed, check the log', subject: 'Jenkins email FAIL ', to: 'maxmjw@gmail.com'
        }
    }
}
