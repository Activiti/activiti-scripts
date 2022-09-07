# Activiti Community Release Process

# How to release
To release the Activiti community project you need to create a `yaml` file containing the following informations:
```

```


The release process is composed by the following phases
- **Prepare**: computes the tagged versions of the code to be released.
- **Tag Docker Images**: tags the docker images already present in `hub.docker.com` with the release tag
- **Update Helm Charts**: update the helm charts with the new tags
- **Update POM files**: checkout the tagged version of the code and update the pom files and commit this version with a new tag
- **Build the code**: build the code with the new version
- **Upload to Nexus**: create a new staging repository in nexus and update the built artifacts, close and release the repo.

## Prepare
Fetches the versions to tag
