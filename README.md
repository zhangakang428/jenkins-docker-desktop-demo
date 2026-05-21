# Jenkins Docker Desktop CI/CD Demo

This repository contains a local Jenkins CI/CD demo for Windows Docker Desktop.
It uses Jenkins, a local Docker registry, and a Spring Boot 3 application.

The pipeline flow is:

1. Jenkins polls this GitHub repository every minute.
2. Jenkins runs `./mvnw clean package`.
3. Jenkins builds `localhost:5000/jenkins-demo-app:${BUILD_NUMBER}`.
4. Jenkins pushes the image to the local registry.
5. Jenkins pulls the image back from the local registry.
6. Jenkins replaces the `jenkins-demo-app` container.
7. Jenkins waits for `http://jenkins-demo-app:8080/hello`.

## Important Safety Notes

Docker socket mounting and insecure registries are used only for this local teaching demo.
Do not use this setup as-is for production.

The image tag must stay on `localhost:5000`.
The Docker commands in Jenkins run through the mounted Docker socket, so `docker push` and `docker pull` are executed by the Docker Desktop daemon.
The pipeline uses `docker buildx build --provenance=false --load` so the local `registry:2` container receives a manifest it accepts.
Inside Jenkins, `registry:5000` is only for container-to-container curl checks such as:

```bash
curl http://registry:5000/v2/
```

## Prerequisites

- Windows Docker Desktop running in Linux container mode.
- Git.
- GitHub CLI if you want to create and push the public demo repository from the command line.
- Docker Desktop insecure registry configured for:
  - `localhost:5000`
  - `127.0.0.1:5000`

After changing Docker Desktop insecure registry settings, restart Docker Desktop and confirm with:

```powershell
docker info
```

## Seed Maven Cache

Your Windows Maven repository is used only once as a seed source:

```text
F:\apache-maven-3.9.4\mvn_repo
```

Run:

```powershell
.\scripts\seed-maven-cache.ps1
```

This step must run before `docker compose up` because `maven_repo` is declared as an external named volume in `docker-compose.yml`.

The script uses:

```bash
cp -a /source/. /target/
```

That copies the contents of `mvn_repo`, not the `mvn_repo` folder itself.

To inspect the volume layout:

```powershell
docker run --rm -v maven_repo:/target alpine sh -c "ls -la /target | head && test ! -d /target/mvn_repo"
```

The volume root should contain directories such as `org`, `com`, `net`, or similar, not a nested `/target/mvn_repo/...`.

## Start The Lab

Validate Compose syntax:

```powershell
docker compose config
```

Start Jenkins and the registry:

```powershell
docker compose up -d --build
```

Open Jenkins:

```text
http://localhost:8080
```

Get the initial Jenkins password:

```powershell
docker compose exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Check the local registry from Windows PowerShell:

```powershell
curl.exe http://localhost:5000/v2/
```

## Jenkins Job Setup

Create a Pipeline job manually in the Jenkins UI:

- Definition: `Pipeline script from SCM`
- SCM: `Git`
- Repository URL: your public GitHub HTTPS repository URL
- Branch Specifier: `*/main` or `*/master`, matching the GitHub default branch
- Script Path: `Jenkinsfile`
- Poll SCM: enabled
- Schedule:

```text
* * * * *
```

## GitHub Repository

Initialize this workspace as a Git repository and fix the Maven wrapper executable bit:

```powershell
git init
git branch -M main
git add .
git update-index --chmod=+x mvnw
git commit -m "Add Jenkins Docker Desktop CI/CD demo"
```

Create and push a public GitHub repository with GitHub CLI:

```powershell
gh repo create jenkins-docker-desktop-demo --public --source=. --remote=origin --push
```

If you do not use GitHub CLI, create a public repository in GitHub, add it as `origin`, and push `main`.

## Useful Checks

Check Docker network and volumes:

```powershell
docker network ls
docker volume ls
```

The network and volumes must use these real names:

```text
jenkins-demo-net
jenkins_home
maven_repo
```

Check Jenkins container access to Docker and registry:

```powershell
docker compose exec jenkins docker ps
docker compose exec jenkins curl http://registry:5000/v2/
docker compose exec jenkins java -version
```

After a successful build, check the registry catalog:

```powershell
curl.exe http://localhost:5000/v2/_catalog
```

Expected response:

```json
{"repositories":["jenkins-demo-app"]}
```

Check the deployed app from Windows:

```powershell
curl.exe http://localhost:8081/hello
```
