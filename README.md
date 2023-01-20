# Jenkins meets OKE

## Introduction
Since the first release of Jenkins in 2011, a lot has happened in the
Software Engineering landscape. With the introduction of Kubernetes in 2015,
distributed and shared nothing architectures have gradually become the
norm, enabling developers to write resilient and fault-tolerant applications.

Many CI/CD tools have also adopted to these new architectural styles, and as a result many
recent DevOps frameworks coming into the market are heavily based on Kubernetes (Jenkins-X, Tekton, Spinnaker, ArgoCD..).  
Despite all these new services, Jenkins still remains the go-to choice for many Enterprise companies
due to its simplicity and wide community.

## Scaling Jenkins
Jenkins' architecture is fairly simple being controller/agent:
* The **Jenkins Controller** is the component where user can configure
pipelines and manage the overall platform. Connection to agents is also
configured in the controller.
* A **Jenkins Agent** is a component connected to a controller where
pipelines are executed.

In a typical Jenkins deployment, the controller and agents are in separate servers.  
As the development teams and the number of pipelines grow, more and more agents are added to the system.  
While this seems an easy solution, there are some issues with this whole setup:
* Most of the time resources are wasted, as agents are not always fully utilized.
* The System is often sized incorrectly, as it is difficult for new teams to predict how many build pipelines there will be.
* Someone from the development team might ask for a separate and dedicated agent capable to support particular libraries
for the build, which leads again to a waste of resources.
* Managing many servers for the agents might put a heavy burden on the operation team.

Thankfully, nowadays there are more options when it comes to Jenkins provisioning, one of which is
to use the [Jenkins Kubernetes Plugin](https://plugins.jenkins.io/kubernetes/) to create on-demand Pods for
every pipline run in Kubernetes.




