{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
%{ for zone in split(",", r53zones) }
%{ if element(split(",", r53zones), length(split(",", r53zones)) - 1) == zone }
        "arn:aws:route53:::hostedzone/${zone}"
%{ else }
        "arn:aws:route53:::hostedzone/${zone}",
%{ endif }
%{ endfor }
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets",
        "route53:ListHostedZonesByName",
        "route53:GetChange"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
