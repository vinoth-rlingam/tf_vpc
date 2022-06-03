pipeline {
    agent any
    
    parameters {
        string(name: 'BUCKET', defaultValue: 's3statestore-vpctf', description: 's3 bucket  name to store terraform state')
        string(name: 'REGION', defaultValue: 'us-east-1', description: 'AWS region')
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        string(name: 'environment', defaultValue: 'dev', description: 'Workspace/environment file to use for deployment')
    }
    
    environment {
        TF_IN_AUTOMATION      = '1'
        TF_WORKSPACE =  ${params.environment}
    }

    
    stages {
        stage('Create Bucket') {  
            steps {  
                echo 'Running create bucket phase'
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'AWSCredentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) { 
                    script {
                        def status = sh(script: "aws s3api head-bucket --bucket ${params.BUCKET}", returnStatus: true)
                        def create = sh(script: "aws s3api create-bucket --bucket ${params.BUCKET} --region ${params.REGION}", returnStatus: true)
                        try {
                        if (status == 0) { // Check if the bucket exists
                            echo 'Bucket already exists'
                        } 
                        else create() {  // Create the bucket if it does not exist
                            echo 'Bucket created'
                        }
                        } catch (err) {
                        echo "Caught: ${err}"
                        currentBuild.result = 'SUCCESS'
                        }
                    }
                }  
            }   
        }
        stage('terraform Init') {
            steps{
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'AWSCredentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                sh 'terraform init -input=false'
                }
            }
        }
        stage('Terraform Plan') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'AWSCredentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]  {
                sh 'terraform plan -out=tfplan -input=false'
              }
            }
        }
        stage('terraform apply') {
            steps{
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'AWSCredentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) { 
                sh 'terraform apply --auto-approve -input=false tfplan'
                }
            }
        }
    
    }
}
