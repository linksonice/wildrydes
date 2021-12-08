#!/bin/bash
###########

# this can't all be done at the same time ..... each step can depend on the previous

aws --region eu-west-2 cloudformation create-stack --stack-name WildRydesStaticWebhost --template-body file://$PWD/1_static_s3_webhost.json --parameters file://$PWD/parameters1.json --capabilities CAPABILITY_IAM

aws cloudformation --region eu-west-2 create-stack --stack-name WildRydesCognitoUserPool --template-body file://$PWD/2_cognito_user_pool.json --parameters file://$PWD/parameters2.json --capabilities CAPABILITY_IAM


echo "Populating js/config.js ... hold on tight ..."

UserPoolId=`aws cloudformation describe-stacks --stack-name WildRydesCognitoUserPool | grep -A 1 UserPoolId | tail -1 | awk '{ print $2 }' | tr '"' "'"`

UserPoolClientId=`aws cloudformation describe-stacks --stack-name WildRydesCognitoUserPool | grep -A 1 UserPoolClientId | tail -1 | awk '{ print $2 }' | tr '"' "'"`

echo $UserPoolId

echo $UserPoolClientId

cat << EOF > ../js/config.js
window._config = {
    cognito: {
        userPoolId: ${UserPoolId},
        userPoolClientId: ${UserPoolClientId},
        region: 'eu-west-2'
    },
    api: {
        invokeUrl: '' // e.g. https://rc7nyt4tql.execute-api.us-west-2.amazonaws.com/prod',
    }
};
EOF

aws s3 cp ../js/config.js s3://iverve-wildrydes/js/

aws cloudformation --region eu-west-2 create-stack --stack-name WildRydesDynamoDBLambdaandRole --template-body file://$PWD/3_dynamodb_and_lambda_and_role.json --capabilities CAPABILITY_NAMED_IAM
