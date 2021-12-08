#!/bin/bash
###########

echo "Populating js/config.js ... hold on tight ..."

UserPoolId=`aws cloudformation list-exports | grep -A 1 UserPoolId | tail -1 | awk '{ print $2 }' | tr '"' "'"`

UserPoolClientId=`aws cloudformation list-exports | grep -A 1 UserPoolClientId | tail -1 | awk '{ print $2 }' | tr '"' "'"`

ApiInvokeUrl=`aws cloudformation list-exports | grep -A 1 ApiInvokeUrl | tail -1 | awk '{ print $2 }' | tr '"' "'"`

echo $UserPoolId

echo $UserPoolClientId

echo $ApiInvokeUrl

cat << EOF > ../js/config.js
window._config = {
    cognito: {
        userPoolId: ${UserPoolId},
        userPoolClientId: ${UserPoolClientId},
        region: 'eu-west-2'
    },
    api: {
        invokeUrl: ${ApiInvokeUrl} // e.g. https://rc7nyt4tql.execute-api.us-west-2.amazonaws.com/prod',
    }
};
EOF

aws s3 cp ../js/config.js s3://iverve-wildrydes/js/

