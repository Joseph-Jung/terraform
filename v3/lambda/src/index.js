/**
 * AWS Lambda Function - Hello World Service
 * Runtime: Node.js 18.x
 */

exports.handler = async (event) => {
    console.log('Event received:', JSON.stringify(event, null, 2));

    try {
        const response = {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'GET,POST,OPTIONS'
            },
            body: JSON.stringify({
                message: 'Hello World',
                timestamp: new Date().toISOString(),
                requestId: event.requestContext?.requestId || 'N/A'
            })
        };

        console.log('Response:', JSON.stringify(response, null, 2));
        return response;

    } catch (error) {
        console.error('Error:', error);

        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                message: 'Internal Server Error',
                error: error.message
            })
        };
    }
};
