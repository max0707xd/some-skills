# Ted search is a project that required us to create full CI/CD pipeline with basic email alerting in jenkins.

Given pom.xml, i have changed it to get the application dockerized (dockerfile maven plugin by spotify)
I've created lightweight dockerfile that would be used to run jar application in container

Then full CI/CD multibranch pipeline triggered automatically whenever commit is made on any of the master, feature, or release branches (gitlab webhook).
After building docker image, it's being published to amazon ECR.
Then my pipeline builds aws infrastructure using terraform, so we can make full e2e tests.
Finally it deploys app on that infrastructure (only release branch)

After that cycle, email is being send to notify of success or failure.
