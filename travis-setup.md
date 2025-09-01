# Travis CI Setup Guide for React/Vite Project

## 🚀 Quick Start

### 1. Enable Travis CI for Your Repository

1. **Visit [Travis CI](https://travis-ci.com)** and sign in with your GitHub account
2. **Authorize Travis CI** to access your repositories
3. **Find your repository** (`neilreuben/docker-react`) in the list
4. **Toggle the switch** to enable Travis CI for this repository

### 2. Configure Environment Variables

Go to your repository settings in Travis CI and add these environment variables:

#### Required Variables:
```bash
# Docker Registry
DOCKER_USERNAME=your-docker-username
DOCKER_PASSWORD=your-docker-password-or-token
DOCKER_IMAGE=your-registry/react-vite-app

# Deployment Servers
STAGING_SERVER=staging.your-domain.com
PRODUCTION_SERVER=your-domain.com
DEPLOY_USER=deploy-user
```

#### Optional Variables:
```bash
# Notifications
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...
NOTIFICATION_EMAIL=your-team@example.com

# Cloud Providers (choose one)
# AWS
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_DEFAULT_REGION=us-west-2

# Heroku
HEROKU_API_KEY=your-heroku-api-key

# Google Cloud
GOOGLE_APPLICATION_CREDENTIALS=base64-encoded-service-account
```

### 3. Encrypt Sensitive Variables

Use Travis CLI to encrypt sensitive data:

```bash
# Install Travis CLI
gem install travis

# Login to Travis
travis login --github

# Encrypt variables
travis encrypt DOCKER_PASSWORD=your-password --add
travis encrypt SLACK_WEBHOOK_URL=your-webhook --add
travis encrypt DEPLOY_KEY="$(cat ~/.ssh/deploy_key)" --add
```

## 📋 Build Pipeline Overview

### Build Stages:

1. **Validate** - Lint code and run security audit
2. **Test** - Run unit tests with coverage on multiple Node.js versions
3. **Build & Package** - Create production build and Docker image
4. **Deploy Staging** - Deploy to staging environment (develop branch)
5. **Deploy Production** - Deploy to production (main/master branch)

### Branch Strategy:

- **`main/master`** → Production deployment
- **`develop`** → Staging deployment  
- **`feature/*`** → Testing only
- **`release/*`** → Full build pipeline
- **`hotfix/*`** → Full build pipeline

## 🐳 Docker Configuration

### Registry Options:

#### Docker Hub:
```yaml
env:
  - DOCKER_IMAGE=username/react-vite-app
```

#### AWS ECR:
```yaml
env:
  - DOCKER_IMAGE=123456789.dkr.ecr.us-west-2.amazonaws.com/react-app
  - AWS_DEFAULT_REGION=us-west-2
```

#### Google Container Registry:
```yaml
env:
  - DOCKER_IMAGE=gcr.io/project-id/react-app
  - GOOGLE_APPLICATION_CREDENTIALS=service-account.json
```

## 🚀 Deployment Options

### Option 1: Docker Direct Deployment
```bash
# In deploy scripts, uncomment Docker deployment section
ssh user@server 'docker run -d --name app -p 80:80 image:tag'
```

### Option 2: Docker Compose
```bash
# Use the provided docker-compose files
docker-compose -f docker-compose.prod.yml up -d
```

### Option 3: Cloud Platforms

#### Heroku:
```yaml
deploy:
  provider: heroku
  api_key: $HEROKU_API_KEY
  app: your-app-name
```

#### AWS ECS:
```bash
aws ecs update-service --cluster production --service react-app
```

#### Google Cloud Run:
```bash
gcloud run deploy react-app --image $DOCKER_IMAGE:$TRAVIS_BUILD_NUMBER
```

## 📊 Monitoring & Notifications

### Slack Integration:
1. Create a Slack webhook in your workspace
2. Add `SLACK_WEBHOOK_URL` to Travis environment variables
3. Uncomment Slack notifications in `.travis.yml`

### Email Notifications:
```yaml
notifications:
  email:
    recipients:
      - team@example.com
    on_success: change
    on_failure: always
```

### Coverage Reporting:
```bash
# Add Codecov integration
after_success:
  - bash <(curl -s https://codecov.io/bash)
```

## 🔧 Customization

### Modify Build Matrix:
```yaml
matrix:
  include:
    - node_js: "16"
      env: BUILD_TYPE=legacy
    - node_js: "18"
      env: BUILD_TYPE=current
    - node_js: "20"
      env: BUILD_TYPE=latest
```

### Add Custom Scripts:
```yaml
before_script:
  - npm run pre-build-checks
  
after_success:
  - npm run post-build-analysis
```

### Configure Caching:
```yaml
cache:
  directories:
    - node_modules
    - ~/.npm
    - ~/.cache
  timeout: 1000
```

## 🛠️ Troubleshooting

### Common Issues:

1. **Build Timeout**: Increase timeout or optimize build
2. **Docker Permission Denied**: Enable Docker service in `.travis.yml`
3. **SSH Connection Failed**: Check deployment server configuration
4. **Environment Variables Not Set**: Verify in Travis repository settings

### Debug Mode:
```yaml
env:
  - TRAVIS_DEBUG_MODE=true
```

### Build Logs:
- View detailed logs in Travis CI dashboard
- Check each stage individually
- Use `echo` statements for debugging

## 📝 Next Steps

1. **Commit all Travis configuration files**:
   ```bash
   git add .travis.yml deploy-*.sh Dockerfile.travis env.travis.template
   git commit -m "Add Travis CI configuration"
   git push origin main
   ```

2. **Monitor your first build** in the Travis CI dashboard

3. **Customize deployment scripts** for your infrastructure

4. **Set up monitoring and alerting** for production deployments

5. **Configure branch protection rules** in GitHub to require Travis builds

## 🔗 Useful Links

- [Travis CI Documentation](https://docs.travis-ci.com/)
- [Travis CI Environment Variables](https://docs.travis-ci.com/user/environment-variables/)
- [Travis CI Docker Integration](https://docs.travis-ci.com/user/docker/)
- [Travis CI Deployment](https://docs.travis-ci.com/user/deployment/)
