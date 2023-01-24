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

Thankfully, there are more options when it comes to Jenkins provisioning, one of which is
to use the [Jenkins Kubernetes Plugin](https://plugins.jenkins.io/kubernetes/) to create on-demand pods for
every pipline run in Kubernetes.

## OKE and Resource Manager

Oracle Container Engine for Kubernetes (OKE) is a managed Kubernetes service provided by Oracle and will act as the
base where to deploy Jenkins.

This repository contains the Terraform configurations necessary to instantiate a new OKE cluster and deploy Jenkins on it.

Although it could be possible to execute these Terraform configurations in your local PC, the recommendation is to use
OCI Resource Manager and create a Stack using the code in this repository.

## Prerequisites

* Having an Oracle Cloud account.
* Owning at least one [Auth Token](https://docs.oracle.com/en-us/iaas/Content/Registry/Tasks/registrygettingauthtoken.htm).
* Being an admin or part of a group with these minimum policies:
```
Allow group <GROUP> to manage cluster-family in compartment <COMPARTMENT>
Allow group <GROUP> to manage instance-family in compartment <COMPARTMENT>
Allow group <GROUP> to use subnets in compartment <COMPARTMENT>
Allow group <GROUP> to read virtual-network-family in compartment <COMPARTMENT>
Allow group <GROUP> to use network-security-groups in compartment <COMPARTMENT>
Allow group <GROUP> to use vnics in compartment <COMPARTMENT>
Allow group <GROUP> to inspect compartments in tenancy
Allow group <GROUP> to use private-ips in compartment <COMPARTMENT>
Allow group <GROUP> to manage public-ips in compartment <COMPARTMENT>
Allow group <GROUP> to manage repos in compartment <COMPARTMENT>
```


## Quickstart

1. Click on the button below to start the guided Stack creation

[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/alcampag/jenkins-oke/raw/main/jenkins-oke.zip)

2. Upon inserting your Oracle Cloud credentials, you will be presented with a license agreement, accept it
and choose a name for the Stack and the compartment where to create it:
3. Next is the variable section, read the variable descriptions before changing them.

**NOTE:**
This Terraform Stack will also create a custom Jenkins image and push it on OCIR, the container registry in Oracle Cloud.
As an option, you can decide the plugins that will be pre-installed by default on this custom image, **removing the default
plugins can BREAK Jenkins installation!!!**

4. As an additional option, you can choose to install Jenkins in an OKE cluster already present in the tenancy. The only
limitation here is that the OKE cluster must be Public.
5. Wait for the Stack to finish, it will take a while if you chose to create the OKE cluster from scratch.
6. Upon success, the Jenkins url will be returned as Terraform output. You can then start the sample pipeline.




