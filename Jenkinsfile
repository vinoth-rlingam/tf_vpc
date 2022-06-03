pipeline {
    agent any
    tools {
       terraform 'terraform'
    }
    parameters {
        string(name: 'BUCKET', defaultValue: 'default', description: 's3 bucket  name to store terraform state')
        string(name: 'REGION', defaultValue: 'us-east-1', description: 'AWS region')
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    }
    
    stages {
        stage('Create Bucket') {  
            steps {  
                echo 'Running create bucket phase'
                withAWS(credentials: 'AWSCredentials') { 
                    script {
                        def status = sh(script: "aws s3api head-bucket --bucket ${params.BUCKET}", returnStatus: true)
                        def create = sh(script: "aws s3api create-bucket --bucket ${params.BUCKET} --region ${params.REGION} --create-bucket-configuration LocationConstraint=${params.REGION}", returnStatus: true)
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
                withAWS(credentials: 'AWSCredentials') {
                sh 'terraform init'
                }
            }
        }
        stage('terraform apply') {
            steps{
                withAWS(credentials: 'AWSCredentials') { 
                sh 'terraform apply --auto-approve'
                }
            }
        }
    
    }
}
