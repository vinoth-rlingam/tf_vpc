pipeline {
    agent any
    
    parameters {
        string(name: 'BUCKET', defaultValue: 's3statestore-vpctf', description: 's3 bucket  name to store terraform state')
        string(name: 'REGION', defaultValue: 'us-east-1', description: 'AWS region')
        choice(name: 'ENV_TO_CREATE', choices: ['dev', 'prod'], description: 'Select the environment to create')
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Select the terraform action to perform')

    }
    
    environment {
        TF_IN_AUTOMATION      = '1'
        TF_WORKSPACE =  "${params.ENVIRONMENTS}"
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
        stage('terraform plan') {
            steps{
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'AWSCredentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                sh 'terraform init -input=false'
                sh 'terraform plan -no-color -out=tfplan -input=false'
                }
            }
        }
        stage('terraform apply or destroy') {
            steps{
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'AWSCredentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) { 
                    script {  
                        def envrt=params.ENV_TO_CREATE
                        if (params.ACTION == "destroy") {
                            sh ('echo Requested action is ' + params.ACTION)   
                            sh 'terraform destroy -auto-approve'
                        } else {
                            sh (' echo  Requested action is ' + params.ACTION)                
                            sh 'terraform apply -auto-approve -no-color -var environ=envrt'
                        } 
                    }
                }
            }
        }
    
    }
}
