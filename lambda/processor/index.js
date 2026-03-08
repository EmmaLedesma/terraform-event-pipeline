// lambda/processor/index.js
// ─────────────────────────────────────────────────────────────
// Lambda handler: procesa eventos S3, envía a SQS y SNS
// Runtime: Node.js 20.x
// ─────────────────────────────────────────────────────────────

const { SQSClient, SendMessageCommand } = require("@aws-sdk/client-sqs");
const { SNSClient, PublishCommand } = require("@aws-sdk/client-sns");

const sqs = new SQSClient({ region: process.env.AWS_REGION });
const sns = new SNSClient({ region: process.env.AWS_REGION });

exports.handler = async (event) => {
  console.log("Event received:", JSON.stringify(event, null, 2));

  const results = [];

  for (const record of event.Records) {
    const bucket = record.s3.bucket.name;
    const key    = decodeURIComponent(record.s3.object.key.replace(/\+/g, " "));
    const size   = record.s3.object.size;

    console.log(`Processing: s3://${bucket}/${key} (${size} bytes)`);

    // ── 1. Enviar mensaje a SQS ──────────────────────────────
    const sqsPayload = {
      bucket,
      key,
      size,
      timestamp: new Date().toISOString(),
      environment: process.env.ENVIRONMENT,
    };

    await sqs.send(new SendMessageCommand({
      QueueUrl:    process.env.SQS_QUEUE_URL,
      MessageBody: JSON.stringify(sqsPayload),
    }));

    console.log(`SQS message sent for: ${key}`);

    // ── 2. Publicar notificación en SNS ──────────────────────
    await sns.send(new PublishCommand({
      TopicArn: process.env.SNS_TOPIC_ARN,
      Subject:  `[${process.env.ENVIRONMENT}] New file processed`,
      Message:  `File uploaded to pipeline:\n\nBucket: ${bucket}\nKey: ${key}\nSize: ${size} bytes\nTime: ${new Date().toISOString()}`,
    }));

    console.log(`SNS notification sent for: ${key}`);

    results.push({ bucket, key, status: "processed" });
  }

  return {
    statusCode: 200,
    body: JSON.stringify({ processed: results.length, results }),
  };
};