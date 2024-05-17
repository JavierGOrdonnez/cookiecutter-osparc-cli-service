# {{ cookiecutter.project_slug }}

{{ cookiecutter.project_short_description }}

## Requirements
- GNU Make
- Python3
- [``Docker``](https://docs.docker.com/get-docker/) (if you wish to build and test the service locally)

## Workflow
### Create the Service
1. The [Dockerfile]({{cookiecutter.project_slug}}/docker/Dockerfile) shall be modified to install the command-line tool you'd like to execute and additional dependencies

All the rest is optional:
1. The [.osparc](.osparc) is the configuration folder and source of truth for metadata: describes service info and expected inputs/outputs of the service. If you need to change the inputs/outputs of the service, description, thumbnail, etc... check the [`metadata.yml`](./.osparc/metadata.yml) file
2. If you need to change the start-up behavior of the service, modify the [`service.cli/execute.sh`](./service.cli/execute.sh) file


Testing: 
1. The service docker image may be built with ``make build`` (see "Useful Commands" below)
2. The service docker image may be run locally with ``make run-local``. You'll need to edit the [input.json](./validation/input/inputs.json) to execute your command.

### Publish the Service on o²S²PARC
Once you're happy with your code:
1. Push it to a public repository.
2. An automated pipeline (GitHub Actions) will build the Docker image for you
3. Wait for the GitHub pipeline to run successfully
4. Check that the automated pipeline executes successfully
5. Once the pipeline has run successfully, get in touch with [o²S²PARC Support](mailto:support@osparc.io), we will take care of the final steps!

### Change the Service (after it has been published on o²S²PARC )
If you wish to change your Service (e.g. add additional libraries), after it has been published on o²S²PARC, you have to **create a new version**:
1. Go back to your repository
2. Apply the desired changes and commit them
3. Increase ("bump") the Service version: in your console execute: ``make version-patch``, or ``make version-minor``, or  ``make version-major``
4. Commit and push the changes to your repository
5. Wait for the GitHub/GitLab pipelines to run successfully
5. Once the pipeline has run successfully, get in touch with [o²S²PARC Support](mailto:support@osparc.io), we will take care of publishing the new version!


### Useful commands
```console
$ make help
$ make build # This will build an o²S²PARC-compatible image (similar to `Docker build` command)
$ make run-local # This will start a new Docker container on your computer and run the command.