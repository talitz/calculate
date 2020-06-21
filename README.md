# Automate Repositories Creation with JFrog CLI

<img src="https://i.ibb.co/pd6Fqqq/Blog-post-Go-Center-04.jpg" alt="alt text" width="600" height="200">

## Table of Contents

- [Background](#background)
- [The Problem](#theproblem)
- [The Solution](#thesolution)
- [Scaling Up](#scalingup)

## Background
Imagine a world in which liquid software flows to systems and devices for secure and automatic continuous updates. JFrog offers many automation tools that can assist you on achiving this vision like our REST API, User Plugins and the JFrog CLI.

JFrog CLI is a compact and smart client that provides a simple interface that automates access to JFrog products simplifying your automation scripts and making them more readable and easier to maintain.

We'll be focusing on how to automate repository creation on this blog post with the JFrog CLI. For that, we will first discuss the importance of feature branches in the development process.

Feature branches are a popular technique, particularly well-suited to open-source development. They allow all the work done on a feature to kept away from a teams common codebase until completion, which allows all the risk involved in a merge to be deferred until that point.

## The Problem
Many customers wish to manage not only their feature branch code but also the resulted binaries and store them in Artifactory in a dedicated repository.
But do we actually need to create a repository manually for every new feature branch that we work on? How can we maintain that in an easier way?

## The Solution
The JFrog CLI offers a set of commands for managing Artifactory repositories. You can create, update and delete repositories. Let's discuss an example of how to implement such automation on a CI server: GitHub Actions.

<b>Note</b>: we won't discuss about how to perform the integration with Artifactory, this is detailed in the following blog post: https://jfrog.com/blog/jfrog-cli-github-actions-hero/.

We will create a CI process that will be triggered for non-master pull requests and we will add steps for automating the repository creation before building and deploying the software to Artifactory:

<img src="https://i.ibb.co/QpsFZgJ/Screen-Shot-2020-06-21-at-19-00-24.png" alt="alt text" width="250" height="90">

1. If branch is X = 'master', do nothing.
2. If branch is X != 'master', create 3 repositories (if they don't exist):
   - 1 Local repository: 'auto-cli-local-X' for the purpose of saving the resulting artifacts.
   - 1 Remote repository: 'auto-cli-jcentral-X', pointing to https://jcenter.bintray.com.
   - 1 Virtual repository: 'auto-cli-virtual-X' pointing to both 'auto-cli-local-X' and to 'auto-cli-jcentral-X', the CI server will use the URL for this repository.
3. Update the build's current repository: 'auto-cli-virtual-X' for fetching 3rd party dependencies and pushing the resulted feature branch artifacts.

<img src="https://i.ibb.co/h8Gxp8L/Screen-Shot-2020-06-21-at-22-32-06.png" alt="alt text" width="380" height="250">

```shell  
    - name: Feature Branch Repository Creation
      run: |
        jfrog rt rc templates/local-repo-template.json --vars key1=$repository
        jfrog rt rc templates/remote-repo-template.json --vars key1=$repository
        jfrog rt rc templates/virtual-repo-template.json --vars key1=$repository


    - if: always()
      name: Feature Branch Repository Update
      run: |
        echo "::set-env name=repository::$(echo ${GITHUB_REF#refs/heads/} | sed 's/\//_/g')"
        jfrog rt mvnc --server-id-resolve=tal-personal-arti --server-id-deploy=tal-personal-arti --repo-resolve-releases=auto-cli-virtual-$repository --repo-resolve-snapshots=auto-cli-virtual-$repository --repo-deploy-releases=auto-cli-virtual-$repository --repo-deploy-snapshots=auto-cli-virtual-$repository    
```

With this following mechanism we are achieving the following advantages:
1) Isolation
2) "Clean" Dependencies per feature - only the needed dependencies will be stored (not twice, Artifactory is a checksum based storage - https://jfrog.com/article/checksum-based-storage/)
3) Deploy your application without "outside noise"
4) Configure a specific watch on the build using Xray

## Scaling Up
But is this solution scalable? What happens when we grow, and develop hundreds of features? that creates quite a mess in artifactory. Some features might get old and not relevant, pushed way back to master and can be deleted. Well, we have a solution for that as well.

Delete Old Repositoreis Mechanism.

1. Extract all the repositories & Filter the repositories created automatically by the CI process
2. Calculate for which month are we going back to verify who should be deleted
3. Iterate over all the repositories, delete those by the latest file that was modified
  3.1. If the repository is empty / latest modified file is older > NUMBER_OF_DAYS_TO_KEEP days
          3.1.1. DELETE the repository
          
          

```shell  
    - if: always()
      name: Feature Branch Repository Deletion
      env:
        NUMBER_OF_DAYS_TO_KEEP: 1
      run: |
        # Extract all the repositories & Filter the repositories created automatically by the CI process
        jfrog rt curl -XGET /api/repositories | jq '[.[] | .key | select(test("auto-cli"))]' > deletion/auto_created_repositories.json

        # Calculate for which month are we going back to verify who should be deleted
        jq -n 'now - 3600 * 24 * '$NUMBER_OF_DAYS_TO_KEEP' | gmtime | todate' > deletion/months_indicator && cat deletion/months_indicator

        # Iterate over all the repositories, delete those by the latest file that was modified
        jq -c '.[]' deletion/auto_created_repositories.json | while read i; do
          echo Iterating repository = $i
          jfrog rt s --spec deletion/repositories-spec.json --spec-vars='key1="$i"' > deletion/search_results && cat deletion/search_results
          
          # If the repository is empty / latest modified file is older > NUMBER_OF_DAYS_TO_KEEP days
          # => DELETE the repository
          if [[ $(cat deletion/search_results) == "[]" || 
                $(cat deletion/search_results | jq --arg month_indicator $(cat deletion/months_indicator) '.[] | .modified | . <= $month_indicator') = "true" ]]; then
             echo "Deleting repository: $i, too old to keep in Artifactory"
             jfrog rt rdel $i --quiet
          else
             echo "Skipping Repository deletion - repository is still relevant"
          fi
        done         
```
The full code for this pipeline is available at: https://github.com/talitz/calculate-with-github-actions/blob/master/.github/workflows/main.yml.


