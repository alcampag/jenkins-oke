
output "jenkins_login" {
   value = module.jenkins != null ? "http://${module.jenkins.kube_service.status.0.load_balancer.0.ingress.0.ip}/login" : null
 }