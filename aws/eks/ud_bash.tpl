#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh ${cluster_name} --kubelet-extra-args '--cluster-dns=${cluster_dns} --node-labels=env=${env},workload=${workload}'
