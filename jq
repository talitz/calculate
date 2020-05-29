
Name:
  jfrog rt search - Search files.

Usage:
  jfrog rt s [command options] <search pattern>
  jfrog rt s --spec=<File Spec path> [command options]

Arguments:
  search pattern
    Specifies the search path in Artifactory, in the following format: <repository name>/<repository path>.
    You can use wildcards to specify multiple artifacts.

Options:
  --url                     [Optional] Artifactory URL.
  --dist-url                [Optional] Distribution URL.
  --user                    [Optional] Artifactory username.
  --password                [Optional] Artifactory password.
  --apikey                  [Optional] Artifactory API key.
  --access-token            [Optional] Artifactory access token.
  --ssh-passphrase          [Optional] SSH key passphrase.
  --ssh-key-path            [Optional] SSH key file path.
  --server-id               [Optional] Artifactory server ID configured using the config command.
  --client-cert-path        [Optional] Client certificate file in PEM format.
  --client-cert-key-path    [Optional] Private key file for the client certificate in PEM format.
  --sort-by                 [Optional] A list of semicolon-separated fields to sort by. The fields must be part of the 'items' AQL domain. For more information, see https://www.jfrog.com/confluence/display/RTF/Artifactory+Query+Language#ArtifactoryQueryLanguage-EntitiesandFields
  --sort-order              [Default: asc] The order by which fields in the 'sort-by' option should be sorted. Accepts 'asc' or 'desc'.
  --limit                   [Optional] The maximum number of items to fetch. Usually used with the 'sort-by' option.
  --offset                  [Optional] The offset from which to fetch items (i.e. how many items should be skipped). Usually used with the 'sort-by' option.
  --spec                    [Optional] Path to a File Spec.
  --spec-vars               [Optional] List of variables in the form of "key1=value1;key2=value2;..." to be replaced in the File Spec. In the File Spec, the variables should be used as follows: ${key1}.
  --exclusions              [Optional] Semicolon-separated list of exclusions. Exclusions can include the * and the ? wildcards.
  --recursive               [Default: true] Set to false if you do not wish to search artifacts inside sub-folders in Artifactory.
  --build                   [Optional] If specified, only artifacts of the specified build are matched. The property format is build-name/build-number. If you do not specify the build number, the artifacts are filtered by the latest build number.
  --count                   [Optional] Set to true to display only the total of files or folders found.
  --bundle                  [Optional] If specified, only artifacts of the specified bundle are matched. The value format is bundle-name/bundle-version.
  --include-dirs            [Default: false] Set to true if you'd like to also apply the source path pattern for directories and not just for files.
  --props                   [Optional] List of properties in the form of "key1=value1;key2=value2,...". Only artifacts with these properties will be returned.
  --exclude-props           [Optional] List of properties in the form of "key1=value1;key2=value2,...". Only artifacts without the specified properties will be returned
  --fail-no-op              [Default: false] Set to true if you'd like the command to return exit code 2 in case of no files are affected.
  --archive-entries         [Optional] If specified, only archive artifacts containing entries matching this pattern are matched. You can use wildcards to specify multiple artifacts.
  --insecure-tls            [Default: false] Set to true to skip TLS certificates verification.
  
Environment Variables:
  JFROG_CLI_LOG_LEVEL
    [Default: INFO]
    This variable determines the log level of the JFrog CLI.
    Possible values are: INFO, ERROR, and DEBUG.
    If set to ERROR, JFrog CLI logs error messages only.
    It is useful when you wish to read or parse the JFrog CLI output and do not want any other information logged.

  JFROG_CLI_OFFER_CONFIG
    [Default: true]
    If true, JFrog CLI prompts for product server details and saves them in its config file.
    To avoid having automation scripts interrupted, set this value to false, and instead,
    provide product server details using the config command.

  JFROG_CLI_HOME_DIR
    [Default: ~/.jfrog]
    Defines the JFrog CLI home directory path.

  JFROG_CLI_TEMP_DIR
    [Default: The operating system's temp directory]
    Defines the temp directory used by JFrog CLI.

  JFROG_CLI_BUILD_NAME
    Build name to be used by commands which expect a build name, unless sent as a command argument or option.
  
  JFROG_CLI_BUILD_NUMBER
    Build number to be used by commands which expect a build number, unless sent as a command argument or option.

  JFROG_CLI_BUILD_URL
    Sets the CI server build URL in the build-info. The "jfrog rt build-publish" command uses the value of this environment variable, unless the --build-url command option is sent.
  
  JFROG_CLI_ENV_EXCLUDE
    [Default: *password*;*secret*;*key*;*token*] 
    List of case insensitive patterns in the form of "value1;value2;...". Environment variables match those patterns will be excluded. This environment variable is used by the "jfrog rt build-publish" command, in case the --env-exclude command option is not sent.

  CI
    [Default: false]
    If true, disables interactive prompts and progress bar.
    

