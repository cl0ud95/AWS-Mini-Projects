import boto3
import json

## Packages to be installed in the python root directory using py -m pip install --target ./python
from aws_error_utils import errors

def lambda_handler(event, context):
    '''Provide an event that contains the following keys:

      - operation: one of the operations in the operations dict below
      - tableName: required for operations that interact with DynamoDB
      - payload: a parameter to pass to the operation being performed
    '''
    body = json.loads(event['body'])

    if 'tableName' in body:
        tablename = body['tableName']
        dynamo = boto3.resource('dynamodb').Table(tablename)
    else:
        raise NameError('No DynamoDB table provided')
    
    operations = {
        'create': lambda x: dynamo.put_item(**x),
        'read': lambda x: dynamo.get_item(**x),
        'update': lambda x: dynamo.update_item(**x),
        'delete': lambda x: dynamo.delete_item(**x),
        'list': lambda x: dynamo.scan(**x),
        'echo': lambda x: x,
        'ping': lambda x: 'pong'
    }

    operation = body['operation']
    if operation in operations:
        try:
            operations[operation](body.get('payload'))
            return response(200, 'success', f'Operation "{operation}" completed')
        except errors.ALL as e:
            return response(502, 'error', f'{e.code}: {e.message}, operation: {e.operation_name}')
    else:
        return response(502, 'error', f'Operation "{operation}" not recognised by function')
    
def response(code: int, status: str, msg: str):
    ''' Returns a dictionary containing the proper response
        for the lambda code execution

    '''

    return {
    "isBase64Encoded": False,
    "statusCode": code,
    "headers": {"Content-Type": "application/json"},
    "body": json.dumps({
            status: msg
        })
    }
