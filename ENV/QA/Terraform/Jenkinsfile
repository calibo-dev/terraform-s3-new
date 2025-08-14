pipeline {
    agent any
    parameters {
            string(defaultValue: '0.15.0', description: '', name: 'TF_VERSION')
            string(defaultValue: 'test', description: 'Name of the Bucket', name: 'BUCKET_NAME')
            string(defaultValue: 'test', description: 'Name of the Bucket', name: 'ACCESS_KEY')
            string(defaultValue: '****', description: 'Name of the Bucket', name: 'SECRET_KEY')
            string(defaultValue: 'terraform-global-state-techstack-acc', description: 'Name of Backend Bucket', name: 'BACKEND_BUCKET')
            string(defaultValue: 'true', description: 'To Destroy , change value to false', name: 'CREATE')
    }
    environment {
            BACKEND = 'backend.tf'
            TFSTATE = '.terraform/terraform.tfstate'
            TFDIR = './.terraform'
            TFLOCK = '.terraform.lock.hcl'
            AWS_REGION = "us-east-1"
    }
    stages {
        stage('AWS Get Credentials') {
            steps {
               sh '''
                    set +x
                    echo ${ACCESS_KEY} > access_key
                    echo ${SECRET_KEY} > secret_key

               '''
            }
        }
        stage('Perform Checks') {
            steps {
               sh '''
                  set +x
                  if [ ! -f "./${BACKEND}" ]; then
                    echo "${BACKEND} file does not exists. Cannot Proceed, please create the file first."
                    exit 1;
                  fi
                  echo "Backend file present."
               '''
            }
        }
        stage('Configure Backend') {
            steps {
               sh '''
                  set +x

                  sed -i "s/BACKEND_BUCKET/${BACKEND_BUCKET}/g" ./${BACKEND}
                  sed -i "s/BUILD_NUM/${BUILD_NUMBER}/g" ./${BACKEND}
                  cat ${BACKEND}
               '''
            }
        }
        stage('Terraform Validate') {
            steps {
               sh '''
                   docker run  -v $PWD:/app -w /app -e AWS_ACCESS_KEY_ID=$(cat access_key)  -e AWS_SECRET_ACCESS_KEY=$(cat secret_key) -e AWS_DEFAULT_REGION=${AWS_REGION}  hashicorp/terraform:${TF_VERSION} init
                   docker run  -v $PWD:/app -w /app -e AWS_ACCESS_KEY_ID=$(cat access_key)  -e AWS_SECRET_ACCESS_KEY=$(cat secret_key) -e AWS_DEFAULT_REGION=${AWS_REGION}  hashicorp/terraform:${TF_VERSION} validate
               '''
            }
        }
        stage('Terraform Apply') {
            when {
                expression { params.CREATE == 'true' }
            }
            steps {
               sh '''
                   docker run  -v $PWD:/app -w /app -e AWS_ACCESS_KEY_ID=$(cat access_key)  -e AWS_SECRET_ACCESS_KEY=$(cat secret_key) -e AWS_DEFAULT_REGION=${AWS_REGION}   hashicorp/terraform:${TF_VERSION} plan -var "s3_bucket_name=${BUCKET_NAME}"  -out "output"
                   docker run  -v $PWD:/app -w /app -e AWS_ACCESS_KEY_ID=$(cat access_key)  -e AWS_SECRET_ACCESS_KEY=$(cat secret_key) -e AWS_DEFAULT_REGION=${AWS_REGION}   hashicorp/terraform:${TF_VERSION} apply "output"
               '''
            }
        }
        stage('Terraform Delete') {
            when {
                expression { params.CREATE == 'false' }
            }
            steps {
               sh '''
                   FILE=./tenants/${TENANT_NAME}.tfvars
                   docker run  -v $PWD:/app -w /app -e AWS_ACCESS_KEY_ID=$(cat access_key)  -e AWS_SECRET_ACCESS_KEY=$(cat secret_key) -e AWS_DEFAULT_REGION=${AWS_REGION}   hashicorp/terraform:${TF_VERSION} apply -destroy -auto-approve -var "s3_bucket_name=${BUCKET_NAME}"
               '''
            }
        }
    }
    post {
            always {
                cleanWs()
                echo 'Running Cleanup Step'
                sh 'docker rmi -f $(docker image ls -q)'
                sh 'docker rm -f $(docker ps -a -q)'
            }
        }
}