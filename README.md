# Automate Repositories Creation with JFrog CLI

<img src="https://i.ibb.co/pd6Fqqq/Blog-post-Go-Center-04.jpg" alt="alt text" width="600" height="200">

# Background
Imagine a world in which liquid software flows to systems and devices for secure and automatic continuous updates. JFrog offers many automation tools that can assist you on achiving this vision like our REST API, User Plugins and the JFrog CLI.

JFrog CLI is a compact and smart client that provides a simple interface that automates access to JFrog products simplifying your automation scripts and making them more readable and easier to maintain.

We'll be focusing on how to automate repository creation on this blog post with the JFrog CLI. For that, we will first discuss the importance of feature branches in the development process.

Feature branches are a popular technique, particularly well-suited to open-source development. They allow all the work done on a feature to kept away from a teams common codebase until completion, which allows all the risk involved in a merge to be deferred until that point.

# The Problem
Many customers wish to manage not only their feature branch code but also the resulted binaries and store them in Artifactory in a dedicated repository.
But do we actually need to create a repository manually for every new feature branch that we work on? How can we maintain that in an easier way?

# The Solution
The JFrog CLI offers a set of commands for managing Artifactory repositories. You can create, update and delete repositories. Let's discuss an example of how to implement such automation on a CI server: GitHub Actions.

<b>Note</b>: we won't discuss about how to perform the integration with Artifactory, this is detailed in the following blog post: https://jfrog.com/blog/jfrog-cli-github-actions-hero/.

We will add an aditional steps to the CI, before building and deploying the project to Artifactory, that performs the follows:

<img src="https://i.ibb.co/QpsFZgJ/Screen-Shot-2020-06-21-at-19-00-24.png" alt="alt text" width="600" height="200">

1. If branch is 'master', do nothing.
2. On branch is 'X', if it does not exist already, open 2 repositories:
   - Local repository for this feature branch artifacts named 'auto-cli-local-X'.
   - Virtual repository for this feature branch named 'auto-cli-virtual-X' and points to 'auto-cli-local-X' & the relevant remote repository that's relevant for the specific package type (in our case we used Maven project, so we choose jcenterl remote repository - an existing one).
3. Update the current repository to be the one used on the current build (to pull & push from).

So, let's say 3 developers worked on 3 different features, X, Y and Z, the repository map will look as follows:


The CI server, for each feature branch, will fetch the 3rd party dependencies from the remote repository and will push the resulted artifacts to the specific local repository that represents that feature branch.

This way, we can achieve the following advantages:
1) Isolation
2) We have "Clean" Dependencies
3) Deploy your application without outside noise
4) You can configure a specific watch on build

# Scaling Concerns
But is this solution scalable? What happens when we grow, and develop hundreds of features? that creates quite a mess in artifactory. Some features might get old and not relevant, pushed way back to master and can be deleted. Well, we have a solution for that as well.

Delete Old Repositoreis Mechanism.

1. Extract all the repositories & Filter the repositories created automatically by the CI process
2. Calculate for which month are we going back to verify who should be deleted
3. Iterate over all the repositories, delete those by the latest file that was modified
  3.1. If the repository is empty / latest modified file is older > NUMBER_OF_DAYS_TO_KEEP days
          3.1.1. DELETE the repository
