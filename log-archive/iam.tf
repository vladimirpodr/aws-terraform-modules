resource "aws_iam_role" "firehose" {
  name = "${var.name}-firehose-s3-role"

  # Allow EC2 instances and users to assume the role
  assume_role_policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "sts:AssumeRole",
          "Principal": {"Service": "firehose.amazonaws.com"}
        }
      ]
    }
    POLICY
}

resource "aws_iam_policy" "firehose" {
  name = "${var.name}-firehose-s3-policy"

  policy = <<-POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [ 
            "s3:AbortMultipartUpload", 
            "s3:GetBucketLocation", 
            "s3:GetObject", 
            "s3:ListBucket", 
            "s3:ListBucketMultipartUploads", 
            "s3:PutObject",
            "s3:PutObjectAcl" 
        ],
        "Resource": [ 
            "arn:aws:s3:::${var.log_archive_bucket}", 
            "arn:aws:s3:::${var.log_archive_bucket}/*" 
        ]
      }
    ]
  }
  POLICY
}

resource "aws_iam_role_policy_attachment" "firehose" {
  role       = aws_iam_role.firehose.name
  policy_arn = aws_iam_policy.firehose.arn
}

resource "aws_iam_role" "cw_subscription" {
  name = "${var.name}-cw-firehose-role"

  # Allow EC2 instances and users to assume the role
  assume_role_policy = <<-POLICY
  {
    "Version": "2012-10-17",
    "Statement": {
      "Effect": "Allow",
      "Principal": { "Service": "logs.${data.aws_region.current.name}.amazonaws.com" },
      "Action": "sts:AssumeRole",
      "Condition": { 
          "StringLike": { 
              "aws:SourceArn": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
          } 
      }
    }
  }
  POLICY
}

resource "aws_iam_policy" "cw_subscription" {
  name = "${var.name}-cw-firehose-policy"

  policy = <<-POLICY
  {
      "Version": "2012-10-17",
      "Statement":[
        {
          "Effect":"Allow",
          "Action":["firehose:*"],
          "Resource":["arn:aws:firehose:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
        }
      ]
  }
  POLICY
}

resource "aws_iam_role_policy_attachment" "cw_subscription" {
  role       = aws_iam_role.cw_subscription.name
  policy_arn = aws_iam_policy.cw_subscription.arn
}
