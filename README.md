Cytoscape Cloud
===============

[![Generic badge](https://img.shields.io/badge/production-ok-green.svg)](https://shields.io/)
[![Generic badge](https://img.shields.io/badge/staging-ok-green.svg)](https://shields.io/)

<img align="right" height="300" src="http://www.cytoscape.org/images/logo/cy3logoOrange.svg">

---

The Cytoscape cloud exists as a collection of Google Cloud Projects running in Google Cloud Platform (GCP).  The Cytoscape Cloud provides a backend for the Cytoscape Cyberinfastructure. This document describes the logical organization of the Cytoscape Cloud in GCP, the rules that must be followed to use and develop for and against the Cytoscape Cloud, and Cytoscape Cloud best practices.

The Cytoscape Cloud runs on Google Cloud Platform (GCP). GCP is analogous to Amazon Web Services (AWS) or Microsoft Azure (Azure). GCP uses a cloud console or command line tool (cloud) to access and manipulate cloud resources like virtual machines, container registries, clusters, and block storage. Resources are completely separated by projects. Identity Access Management (IAM) is controlled at the project level.

The most important resources in the Cytoscape Cloud are the Kubernetes clusters. Kubernetes is a container scheduling and clustering technology developed by Google, based on in house technologies used to run all Google infastructure. The Cytoscape cloud is primarily concerned with the deployment of services, which provide programmable APIs on the publicly routable internet. Many GCP resources, including composed services, may be used to support these primary services. Other GCP resources may be used to provide other useful features to the Cytoscape team, such as StackDriver logging and monitoring, or Google object storage.

---

_cxMate is an official [Cytoscape](http://www.cytoscape.org) project written by the Cytoscape team._

Production and Testing projects
-------------------------------

The Cytoscape cloud team uses GCP projects to manage access and air gap production and staging deployments from our test environment. Therefore, two projects names exist that all Cytoscape developers must be intimately familiar with, `cytoscape-cloud` and` cytoscape-cloud-test`. `cytoscape-cloud` contains both the production and staging resources, while the `cytoscape-cloud-test` contains testing resources.  

Before digging into the differences between the two projects, we must cover some definitions common to both projects.

### Project Definitions

**Project** - A completely separate account that is billed as a unit, has separate IAM to control project access, and can contain any GCP resource or service. Currently only two project exist, `cytoscape-cloud` and `cytoscape-cloud-test`.

**Project Administrator** - (AKA Cluster Admin, Cloud Admin) - A person tasked with managing a Cytoscape cloud project. Project Admins answer questions, run through checklists, and manage access to the cluster resources. A Project Admin must understand the use of both GCP, Kubernetes, and the rules laid out in this guide. Only Project Administrators can access and deploy services to the cytoscape-cloud project.

**Project Developer** - (AKA Cloud Dev, Service Author) - A person creating or using Cytoscape Cloud resources

**Project Cluster** - (AKA Cluster, Kubernetes) - A Kubernetes cluster running in a project. Currently only three clusters exists. Staging and Production in the `cytoscape-cloud` project and Testing in the `cytoscape-cloud-test` project.

**Deployment Repository** - (AKA Cluster Repo) - A git repo that contains Kubernetes YAML files to be run on a cluster. When the administrator decides to change the state of a non-test cluster, the repo must be tagged and the tagged source configuration is then applied to the cluster.

## cytoscape-cloud-test
cytoscape-cloud-test exists for internal use only. Access to project resources may be liberally given to team members who have been trained with the cloud console and command line tools. All development applications and services must first run on the test cluster before being promoted to any other cluster.

##### Example uses of the test project include:

- Test clusters used to experiment with new Kubernetes functionality
- Test images pushed to the gcr.io/cytoscape-cloud-test registry for test deployments
- Test  Kubernetes deployments for testing new services and service versions
- Test logs for new applications and services
- Preparing services for cytoscape-cloud using standard testing methodologies

Use cytoscape-cloud-test to test and prepare ideas for cytoscape-cloud. Do not use cytoscape-cloud-test for production deployments or external testing without the approval of a test project administrator.

##### Rules for using the test cluster

1. Never give out access to the cluster to anyone else
2. Any expensive resources spun up in the project must be approved by a cluster administrator
3. NO EXTERNAL SERVICES. NO PRODUCTION DEPLOYMENTS.

**Failure to follow these rules may result in suspension from the project**

## cytoscape-cloud
`cytoscape-cloud` exists for external use, including alpha and beta testing of new service deployments on the staging cluster, and production deployments on the production cluster. No one may access the production cluster accept for project administrators or the project manager.

The `cytoscape-cloud` contains two clusters that are both managed via source control repositories. The state of the cluster must match the configuration defined in a tagged commit of one of these source control repositories. A project developer may have their services run in a production or staging cluster by having an administrator commit there configuration files to the source control repository.

Access to the deployment repositories is governed by checklists that must be followed before resources may be created.

### Deployment Checklists

Anyone who wants to deploy a service to a cytoscape-cloud project must read and follow the following checklists.

#### Staging Checklist

A service eligible for promotion to staging must adhere to the following checklist items:

1. The service must exist on the test cluster and must be testable before promotion to staging.

2. A *servicename*-*serviceversion*.yaml file must exist with all service resources defined in the file.  Comments should exist that give a high level overview of the pieces involved in the service.

3. A cluster administrator must be assigned to this deployment to verify the checklist items and commit the service to staging.  The name of the service author and the cluster admin must appear in a comment header in the YAML file for the service. The admin and author may not be the same person.

4. All container images must exist in the gcr.io/cytoscape-cloud registry, and must be built and tagged using build rules that match against tags in the source repository. If the image is third party, it must use a tag and be approved by the cluster administrator.

5.  All container images and Kubernetes resources must be versioned. Images should use tags matches their source control version tags, and Kubernetes resources should use major version suffixes on resource names.

6. Resource limits must exist in the pod specification unless a case can be made that the service is bounded in some other way that would keep it from negatively impacting other services on the cluster.

7. A DNS name annotation must be made on the Kubernetes service resource definition using a DNS name approved by the cluster administrator.

8. The cluster administrator and service author must agree to the number of replicas and node requirements for the service deployment.

9. The service author and cluster administrator must sign off on the service as ready for staging, and agree upon a contingency should the service fail.

After all of the conditions of the checklist have been met, the cluster administrator may commit the YAML file to the staging deployment repository.

#### Production Checklist

A service eligible for promotion to production must adhere to the following checklist items in addition to the Staging checklist items.

1. The service must run on the production cluster for at least a week without any degradations.

2. The staging checklist must be rechecked.

After all of the conditions of the checklist have been met, the cluster administrator may commit the YAML file to the production deployment repository.

#### Redeployment Checklist

If the service is a version bump or redeployment of an existing service on staging or production, then it must adhere to the following checklist items:

1. If the service has broken API compatibility with the existing version in any way, it must bump versions.

2. If API compatibility is broken, the old API should be maintained unless approval is given by a cluster administrator to perform a rolling upgrade.

