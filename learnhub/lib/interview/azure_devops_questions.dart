import 'interview_question.dart';

final List<InterviewQuestion>
azureDevOpsInterviewQuestions = buildInterviewQuestions(
  subject: 'Azure DevOps',
  idPrefix: 'azure-devops',
  basic: [
    questionDraft(
      'What is Azure Pipelines, and what problems does it solve?',
      'Azure Pipelines automates building, testing, and delivery of software from source control. It provides hosted or self-hosted agents, pipeline-as-code, artifact handling, and deployment integrations so teams can make releases repeatable.',
      'A team runs a .NET build and unit tests after each push, then publishes a versioned package.',
      'Use it to shorten feedback cycles and reduce differences between manual releases.',
      'CI validates changes frequently; CD automates delivery; pipeline definitions can be reviewed with code.',
    ),
    questionDraft(
      'How do YAML pipelines differ from classic pipelines?',
      'YAML pipelines define stages, jobs, and steps in a versioned file in the repository. Classic pipelines are configured primarily through the Azure DevOps UI; they can be convenient for legacy workflows, while YAML improves review, reuse, and reproducibility.',
      'A repository stores its build-and-test workflow in azure-pipelines.yml instead of relying on an undocumented UI configuration.',
      'Choose YAML for new workflows that should evolve alongside application code.',
      'YAML is source controlled; classic definitions are UI-managed; both can run pipeline tasks.',
    ),
    questionDraft(
      'What is an agent in Azure Pipelines?',
      'An agent is the worker that executes pipeline jobs. Microsoft-hosted agents provide a fresh managed VM for each job, while self-hosted agents let an organization control installed tools, network access, and machine lifecycle.',
      'A hosted Ubuntu agent runs a Linux build, while a self-hosted agent reaches an internal package feed.',
      'Select an agent based on required operating system, network boundary, and toolchain.',
      'Agents execute jobs; hosted machines are ephemeral; self-hosted machines require patching and cleanup.',
    ),
    questionDraft(
      'Explain stages, jobs, and steps in a pipeline.',
      'Stages are major workflow boundaries, jobs are units scheduled on agents, and steps are tasks or scripts within a job. Stages can express build, test, and release progression; jobs in a stage may run concurrently when dependencies permit.',
      'A pipeline has Build and Deploy stages; Build contains compile and test jobs, each with several steps.',
      'Use this hierarchy to separate responsibilities and make parallelism and approvals explicit.',
      'Stages organize lifecycle; jobs are agent execution units; steps run sequentially inside a job.',
    ),
    questionDraft(
      'What is the purpose of a pipeline trigger?',
      'A trigger determines which repository events start a pipeline. CI triggers commonly select branches or paths, while pull-request validation runs checks for proposed changes; carefully scoped triggers avoid unnecessary runs without skipping required validation.',
      'A main-branch CI trigger builds merges, and a pull-request trigger validates feature branches.',
      'Use triggers to match build cost and feedback speed to the repository workflow.',
      'CI and PR triggers serve different events; branch and path filters scope execution; avoid excluding critical changes.',
    ),
    questionDraft(
      'How are variables used in Azure Pipelines?',
      'Variables provide named values to tasks and scripts, with scopes such as pipeline, stage, or job. They are useful for non-secret configuration; secret values should be stored in a protected variable group or secret store and never printed.',
      'A variable named buildConfiguration selects Release for a dotnet build task.',
      'Use variables to centralize environment-specific settings without duplicating pipeline steps.',
      'Variables can be scoped; secret variables are masked but masking is not a license to log them; use least privilege.',
    ),
    questionDraft(
      'What is a pipeline artifact?',
      'A pipeline artifact is a file or directory published by one job or run for later consumption. Artifacts decouple build outputs from deployment jobs and can be retained or downloaded without rebuilding the same source.',
      'A build publishes a zipped web application, and a later deployment job downloads that exact package.',
      'Use artifacts to promote a tested build through multiple environments.',
      'Publish once and deploy the same bits; distinguish artifacts from source checkout; define retention intentionally.',
    ),
    questionDraft(
      'What is the difference between a task and a script step?',
      'A task is a packaged pipeline operation with typed inputs and Azure DevOps integration, while a script step runs shell or PowerShell commands directly. Tasks often provide standardized behavior; scripts offer flexibility but require explicit error handling and portability.',
      'Use a DotNetCoreCLI task for a standard test command and a short Bash step for custom version stamping.',
      'Prefer tasks for common operations and scripts for project-specific orchestration.',
      'Tasks expose inputs and results; scripts depend on shell and agent tools; fail the step on command errors.',
    ),
    questionDraft(
      'What is a service connection?',
      'A service connection stores an authenticated connection from Azure DevOps to an external service such as Azure, Kubernetes, or a container registry. It centralizes authorization for pipeline tasks and should be restricted to the necessary projects, pipelines, and resource scope.',
      'An Azure Resource Manager service connection allows a deployment job to update one test resource group.',
      'Use service connections instead of embedding credentials in YAML or scripts.',
      'Treat connections as credentials; grant narrow scope; prefer federated identity where supported.',
    ),
    questionDraft(
      'What are environments in Azure Pipelines?',
      'An environment is a logical deployment target that can represent a cluster, VM, or named lifecycle boundary. It records deployment history and can have approvals and checks that protect production resources.',
      'A deployment job targets the production environment and waits for an authorized approval.',
      'Use environments to make release history and production controls visible in one place.',
      'Environments track deployments; approvals and checks guard resources; access permissions are separate controls.',
    ),
    questionDraft(
      'How do you choose a pipeline agent pool?',
      'An agent pool groups agents available to run jobs. The pool must satisfy operating-system and tool requirements, and self-hosted pools should be segmented where workloads have different trust levels or network privileges.',
      'A Windows packaging job uses a Windows pool, while a Linux unit-test job uses a hosted Ubuntu image.',
      'Use suitable pools to meet platform requirements without granting every build access to privileged machines.',
      'Pool selection affects OS and capabilities; minimize self-hosted agent privileges; pin images or tools when reproducibility matters.',
    ),
    questionDraft(
      'What does the checkout step do?',
      'Checkout retrieves repository content onto the agent for a job. Pipeline defaults generally check out the triggering repository, but jobs can customize depth, submodules, persistence of credentials, and which repositories are fetched.',
      'A job checks out the source before invoking its build tool.',
      'Use explicit checkout settings for large repositories or multi-repository builds.',
      'Checkout is per job; shallow fetch can save time but may limit history-dependent tasks; avoid persisting credentials unnecessarily.',
    ),
    questionDraft(
      'Why use YAML templates?',
      'Templates let teams reuse steps, jobs, or stages and apply consistent structure across pipeline files. Parameters allow controlled customization, while centrally managed templates can establish organization-wide conventions.',
      'Several repositories include a shared template that runs static analysis before publishing artifacts.',
      'Use templates to reduce copied pipeline logic and make common changes easier to review.',
      'Templates support reuse; parameters are compile-time inputs; keep interfaces small and document required parameters.',
    ),
    questionDraft(
      'How do conditions control pipeline execution?',
      'A condition determines whether a stage, job, or step runs based on status and expressions. The default behavior depends on preceding success; explicit conditions can select branches or outcomes, but should preserve failure propagation unless intentionally overridden.',
      'A deployment stage runs only after successful tests and only for the main branch.',
      'Use conditions to separate pull-request validation from release-only work.',
      'Default success behavior matters; branch checks use predefined variables; always() and succeededOrFailed() change failure handling.',
    ),
    questionDraft(
      'What is pipeline caching, and when should it be used?',
      'Caching preserves reusable dependency or tool data between runs to reduce setup time. A cache key should include inputs that affect the cached content, such as a lockfile hash, and a cache miss must still allow a correct clean build.',
      'A Node job caches the package-manager download directory using the lockfile as a key input.',
      'Use caching for expensive, reproducible downloads rather than for build outputs that must be validated.',
      'Caches are an optimization, not an artifact; key them by dependency inputs; do not make correctness depend on a hit.',
    ),
    questionDraft(
      'How do you run and publish test results from a pipeline?',
      'A pipeline invokes a test runner and publishes its result files in a supported format so Azure DevOps can display trends and failures. The test command should return a failing exit code when tests fail, and result publication should still run when useful for diagnosis.',
      'A dotnet test step writes TRX results and a publish task attaches them to the run.',
      'Use test reporting to make failures visible to developers and release approvers.',
      'Fail on test failures; publish machine-readable results; retain logs and reports for troubleshooting.',
    ),
    questionDraft(
      'What is the difference between a build and a release?',
      'A build validates source and creates versioned outputs; a release deploys selected outputs to a runtime environment. Modern YAML pipelines can model both in one multi-stage definition while keeping promotion and environment controls explicit.',
      'A CI run compiles and packages an API, and a later stage deploys that package to staging.',
      'Separate artifact creation from environment-specific deployment to avoid rebuilding for each environment.',
      'Build produces immutable outputs; release promotes them; deployment configuration can vary by target.',
    ),
    questionDraft(
      'How can you manually start a pipeline run?',
      'An authorized user can queue a pipeline from the Azure DevOps UI or use the Azure DevOps CLI. Queue-time parameters and variables can customize an approved run, but should not be used to bypass required policy checks.',
      'An operator queues a release pipeline for a selected branch and supplies a non-secret change-ticket value.',
      'Use manual runs for controlled maintenance or validation outside normal triggers.',
      'Check branch and parameter values; require appropriate permissions; never pass secrets as visible queue parameters.',
      code: r'''az pipelines run --name "Web-CI" --branch main''',
      output:
          'The command queues a run and returns its run identifier and state.',
    ),
    questionDraft(
      'What are common deployment strategies?',
      'Common strategies include rolling replacement, blue-green, and canary deployment. Each controls how traffic moves to new software and how quickly operators can detect problems; the right choice depends on infrastructure and rollback capabilities.',
      'A web service sends a small fraction of traffic to a canary version before increasing exposure.',
      'Choose a strategy that limits impact while allowing meaningful validation.',
      'Rolling updates replace instances gradually; blue-green switches environments; canary expands exposure in measured steps.',
    ),
    questionDraft(
      'How should pipeline permissions be managed?',
      'Pipeline permissions determine who can edit, queue, approve, or authorize access to protected resources. Apply least privilege, protect important branches and environments, and periodically review broad group grants and unused service connections.',
      'Only the release group can approve production while contributors can queue pull-request validation.',
      'Use permission boundaries to prevent unreviewed code from reaching privileged deployment credentials.',
      'Separate edit, run, and approval rights; resource authorization is distinct from pipeline permissions; audit access regularly.',
    ),
  ],
  intermediate: [
    questionDraft(
      'How would you design a multi-stage CI/CD pipeline?',
      'A multi-stage pipeline builds and tests once, publishes an immutable artifact, and then promotes it through deployment stages. Environment checks and stage dependencies ensure that later deployment uses validated output and waits at the right control points.',
      'Build and Test publish a package, followed by Staging and Production deployment stages.',
      'Use this design when the same release must progress through progressively controlled environments.',
      'Build once; pass artifacts explicitly; model approvals and dependencies at stage boundaries.',
      code: r'''stages:
- stage: Build
  jobs:
  - job: Package
    steps:
    - script: ./build.sh
    - publish: $(Build.ArtifactStagingDirectory)
      artifact: app
- stage: DeployTest
  dependsOn: Build
  jobs:
  - deployment: Test
    environment: test''',
      output: 'The deploy stage runs after the build stage succeeds and targets the test environment.',
    ),
    questionDraft(
      'How do template parameters differ from pipeline variables?',
      'Template parameters are expanded during pipeline compilation and can shape the generated pipeline structure. Variables are runtime values used by tasks and expressions; using a variable where compile-time structure is required will not provide the same type checking or template expansion.',
      'A boolean template parameter includes an optional security scan job, while a runtime variable supplies a deployment label.',
      'Use parameters for reusable pipeline interfaces and variables for values computed or selected during execution.',
      'Parameters are compile-time and typed; variables are runtime and string-oriented; avoid using untrusted inputs to construct privileged structure.',
    ),
    questionDraft(
      'How do variable groups and Key Vault integration help manage configuration?',
      'Variable groups share values across pipelines and can be linked to Azure Key Vault for retrieving secrets. Access to the group and vault must be limited, and secret values should be consumed without logging or exposing them as artifacts.',
      'A release variable group provides a non-secret service endpoint and resolves an API token from a vault.',
      'Use centralized secret rotation and environment configuration without committing credentials to the repository.',
      'Authorize specific pipelines; vault-backed secrets are still sensitive at runtime; avoid echoing secret variables.',
    ),
    questionDraft(
      'How do stage dependencies and conditions interact?',
      'dependsOn establishes ordering and exposes dependency results, while condition decides whether a dependent stage or job executes. A condition can inspect a dependency result, but replacing the default condition may accidentally allow execution after failure unless success is checked deliberately.',
      'A cleanup stage runs after deployment whether it succeeds or fails, while a production stage requires successful verification.',
      'Use dependencies for orchestration and conditions for precise exception or branch behavior.',
      'Dependencies define graph edges; conditions control eligibility; use explicit result checks when overriding defaults.',
    ),
    questionDraft(
      'How can a job pass a value to a later job?',
      'A producing step can set a pipeline variable with an output-variable logging command, and a dependent job maps that output through dependency syntax. The producer step needs a name, and the consumer must depend on the producing job.',
      'A versioning step computes a package version, and a publish job uses that value in its package metadata.',
      'Use output variables for small computed metadata, not for transferring files or secrets.',
      'Name the producing step; define job dependency; use artifacts for larger payloads and protect sensitive values.',
      code: r'''steps:
- bash: echo "##vso[task.setvariable variable=releaseTag;isOutput=true]v2.4.1"
  name: version
- job: Publish
  dependsOn: Build
  variables:
    tag: $[ dependencies.Build.outputs['version.releaseTag'] ]''',
      output: 'The Publish job receives tag with the value v2.4.1.',
    ),
    questionDraft(
      'When should you use pipeline artifacts instead of build artifacts?',
      'Pipeline artifacts are optimized for transferring files between jobs and runs in Azure Pipelines. Build artifacts remain relevant for some Azure DevOps Server and legacy workflows; choose the mechanism supported by the service and consumers, then use a clear artifact name and retention policy.',
      'A build publishes a pipeline artifact named web-package that a deployment stage downloads.',
      'Use pipeline artifacts for fast handoff in current Azure Pipelines YAML workflows.',
      'Artifact type affects commands and compatibility; name outputs consistently; do not assume agent workspaces persist across jobs.',
    ),
    questionDraft(
      'How can a matrix strategy test multiple configurations?',
      'A matrix strategy expands a job into parallel copies with different variable values. It is useful for independent combinations such as supported runtimes or operating systems; control matrix size to avoid excessive cost and include clear job identifiers.',
      'A test job runs against two supported Node versions and reports each result separately.',
      'Use a matrix to validate compatibility without duplicating job definitions.',
      'Matrix values become job variables; jobs can run in parallel; test meaningful supported combinations.',
      code: r'''jobs:
- job: Test
  strategy:
    matrix:
      Node20:
        nodeVersion: 20
      Node22:
        nodeVersion: 22
  steps:
  - task: UseNode@1
    inputs:
      version: $(nodeVersion)''',
      output: 'Azure Pipelines creates a Test job for each matrix entry.',
    ),
    questionDraft(
      'How do you cache dependencies without creating stale builds?',
      'Use a key derived from the dependency manifest or lockfile and restore cached files to the package manager cache directory. Caches are immutable for a key in many pipeline cache workflows, so key changes should track meaningful input changes and installation must still validate dependencies.',
      'A Python project keys its pip download cache using requirements.lock and the operating system.',
      'Use dependency caching to reduce network wait in frequently repeated builds.',
      'Hash lockfiles; scope keys by platform and tool version when relevant; always allow a clean dependency resolution.',
      code: r'''- task: Cache@2
  inputs:
    key: '"pip" | "$(Agent.OS)" | requirements.lock'
    path: $(Pipeline.Workspace)/.pip
    cacheHitVar: PIP_CACHE_RESTORED''',
      output:
          'The cache task restores matching files when the key is available.',
    ),
    questionDraft(
      'How do environment approvals and checks protect a deployment?',
      'Approvals pause a stage targeting a protected environment until authorized reviewers approve it. Checks can also enforce resource-owner controls such as branch control, business hours, or external policy evaluation; configure them on the protected resource so pipeline edits cannot silently remove them.',
      'A production environment requires a release manager approval and confirms the run comes from the main branch.',
      'Use checks for controlled production promotion and separation of duties.',
      'Attach controls to resources; define approver groups and timeout behavior; keep audit history.',
    ),
    questionDraft(
      'What is a deployment job, and how does it differ from a regular job?',
      'A deployment job is designed for deployment work and targets an environment, which enables deployment history and environment-specific strategies. A regular job is a general execution unit and does not by itself register a deployment against an environment.',
      'A deployment job downloads the build artifact and deploys it to the staging environment.',
      'Use deployment jobs when release traceability and environment strategies are important.',
      'Target an environment; choose an appropriate deployment lifecycle hook; separate package building from deployment.',
    ),
    questionDraft(
      'How can deployment slots support safer application releases?',
      'For supported Azure App Service plans, a deployment slot provides a separate live app endpoint with slot-specific configuration. Deploying to a staging slot permits smoke checks before swapping it with production; validate sticky settings and database compatibility before using a swap.',
      'A web app deploys a release to its staging slot, runs a health check, and then swaps slots.',
      'Use slots to reduce downtime and make application rollback faster.',
      'Slots are service-specific; verify slot settings and warm-up behavior; a swap does not automatically reverse incompatible data migrations.',
      code: r'''az webapp deployment slot swap \
  --resource-group rg-app \
  --name orders-api \
  --slot staging \
  --target-slot production''',
      output: 'The staging and production slot contents are swapped by the Azure CLI.',
    ),
    questionDraft(
      'How should secure files be used in a pipeline?',
      'Secure files are protected files stored in Azure DevOps and downloaded through an authorized task at runtime. Restrict pipeline authorization, use them only when a file-based credential or signing key is necessary, and remove temporary copies after use.',
      'A signing job downloads a certificate to sign a package and deletes the temporary file afterward.',
      'Use secure files for protected configuration material that cannot reasonably be represented as a secret value.',
      'Authorize only required pipelines; secure files are credentials; clean agent storage, especially on self-hosted agents.',
    ),
    questionDraft(
      'How can a pipeline authenticate to Azure without a long-lived client secret?',
      'An Azure Resource Manager service connection can use workload identity federation to exchange a short-lived pipeline identity token for Azure access. Configure the federated credential to trust the intended Azure DevOps organization, project, and service connection, then grant narrowly scoped Azure RBAC permissions.',
      'A deployment job requests a federated token and updates one application resource group without storing a client secret.',
      'Use federation to reduce secret rotation burden and limit exposure of persistent credentials.',
      'Federation still requires trust configuration and RBAC; scope the identity narrowly; avoid logging tokens.',
    ),
    questionDraft(
      'How do path filters help in a monorepo?',
      'Path filters restrict a pipeline to changes in relevant repository paths, reducing unnecessary builds. Filters must include shared libraries and build definitions that affect a component, and branch policies should ensure required validation cannot be skipped by an overly narrow filter.',
      'A mobile pipeline watches apps/mobile/** and shared/client/** rather than unrelated documentation.',
      'Use path filtering when independent components share one repository but have distinct validation costs.',
      'Include transitive shared inputs; test include and exclude patterns; retain broad validation for shared infrastructure.',
    ),
    questionDraft(
      'How can one pipeline consume another pipeline or repository?',
      'Pipeline resources allow a YAML pipeline to declare another pipeline as an input and use its artifacts or completion triggers. Repository resources allow templates or source from another repository; pin or select trusted refs and explicitly manage authorization.',
      'A release pipeline consumes the latest successful artifact from the main branch build pipeline.',
      'Use resource declarations to make cross-pipeline and cross-repository dependencies explicit.',
      'Declare resources and versions; use completion triggers when appropriate; protect referenced repositories and artifacts.',
      code: r'''resources:
  pipelines:
  - pipeline: ci
    source: Web-CI
    trigger:
      branches:
        include: [main]''',
      output: 'The release pipeline can access artifacts from a qualifying Web-CI run.',
    ),
    questionDraft(
      'What are container jobs useful for?',
      'A container job runs its steps in a container image on a compatible agent, giving a more consistent tool environment. The host agent still provides scheduling and container support, and special hardware or privileged host access may not be available inside the container.',
      'A Linux test job uses a pinned SDK image so contributors and CI use the same compiler toolchain.',
      'Use container jobs to standardize dependencies across pipeline runs.',
      'Pin image versions; understand host-agent requirements; do not treat a container as a substitute for security isolation.',
    ),
    questionDraft(
      'How would you make test result publication resilient to test failures?',
      'Let the test step fail the job when tests fail, then publish the generated result files with an always or succeededOrFailed condition. This preserves the correct pipeline outcome while ensuring test diagnostics remain available for investigation.',
      'A test command exits nonzero, but a subsequent result-publication task uploads the TRX files.',
      'Use this pattern when developers need detailed reports from failing CI runs.',
      'Do not mask the test failure; publish results conditionally on files existing; retain diagnostic logs.',
      code: r'''- script: dotnet test --logger "trx;LogFileName=tests.trx"
  displayName: Run tests
- task: PublishTestResults@2
  condition: succeededOrFailed()
  inputs:
    testResultsFormat: VSTest
    testResultsFiles: '**/*.trx'
    failTaskOnFailedTests: true''',
      output: 'The job remains failed for failing tests while the report is attached to the run.',
    ),
    questionDraft(
      'How should teams handle flaky tests in CI?',
      'First capture repeatable evidence and identify whether the cause is test isolation, timing, shared state, or an external dependency. Quarantine only with an owner and expiry, keep the failure visible, and do not let automatic retries conceal persistent product regressions.',
      'A timing-sensitive integration test is stabilized with deterministic fixtures and a bounded wait for a readiness condition.',
      'Use a measured remediation process to restore confidence in required CI checks.',
      'Retries are diagnostic, not a fix; track ownership and frequency; preserve a reliable blocking test suite.',
    ),
    questionDraft(
      'What should a rollback plan include in a delivery pipeline?',
      'A rollback plan identifies a known-good artifact or deployment slot, the trigger for rollback, the authorized operator, and validation steps. It must account for irreversible data changes and backward compatibility rather than assuming that redeploying old binaries always restores service.',
      'A failed health check after a slot swap triggers a swap back to the previous slot and a post-rollback smoke test.',
      'Use rollback plans to limit the duration and impact of a faulty release.',
      'Keep prior immutable artifacts; define health criteria; coordinate schema and configuration compatibility.',
    ),
    questionDraft(
      'How do branch policies fit with pipeline validation?',
      'Branch policies can require successful pipeline validation and reviewer approval before a pull request is completed. They make validation a repository gate rather than a convention, and policies should be configured for protected branches with clear exemptions and ownership.',
      'The main branch requires a successful CI build and one reviewer before merge.',
      'Use branch policies to prevent unvalidated changes from entering release branches.',
      'Require the correct pipeline; protect policy administration; manage bypass permissions carefully.',
    ),
  ],
  advanced: [
    questionDraft(
      'How would you enforce organization-wide pipeline security without blocking all team customization?',
      'Use required template or centrally governed pipeline patterns to define mandatory stages, task restrictions, and trusted resources, while exposing a small documented parameter surface for teams. Protect template repositories and service connections independently, and test policy changes against representative pipelines before rollout.',
      'A required template injects credential scanning and artifact signing while application teams supply build commands.',
      'Use centralized guardrails in a large organization with many independently maintained repositories.',
      'Separate policy from allowed customization; version and review templates; audit bypass paths and resource grants.',
    ),
    questionDraft(
      'How would you design federated identity and RBAC for production deployment?',
      'Create a workload identity trust limited to the intended service connection context, then grant that identity only the resource actions required for deployment. Separate production from non-production identities, constrain who may authorize the connection, and validate the trust subject and audience to prevent unintended token exchange.',
      'The production pipeline identity can update a specific app service but cannot create role assignments or access unrelated subscriptions.',
      'Use least-privilege federated identities for secretless deployment from Azure DevOps.',
      'Trust configuration is an authentication boundary; RBAC is the authorization boundary; separate environments and audit role assignments.',
    ),
    questionDraft(
      'How would you build a progressive delivery pipeline with measurable gates?',
      'Deploy a candidate to a limited audience, verify health and business indicators over a defined observation period, and increase traffic only when automated gates pass. Specify abort thresholds and a rollback mechanism before deployment; pipeline success should reflect telemetry, not merely a successful task exit.',
      'A canary receives 5 percent of traffic, and error rate and latency are checked before advancing to 25 percent.',
      'Use progressive delivery for services where full exposure creates significant operational risk.',
      'Define baseline and thresholds; evaluate representative telemetry; stop or roll back automatically when gates fail.',
    ),
    questionDraft(
      'How can you make a pipeline reproducible and supply-chain verifiable?',
      'Pin toolchain and dependency inputs, build from a known commit, generate an artifact digest, and retain provenance linking the artifact to its source and pipeline run. Sign or attest outputs using a protected identity and verify that evidence before deployment; provenance does not replace vulnerability review.',
      'A release records the container image digest and source commit, signs the image, and deploys that exact digest.',
      'Use provenance to establish what source and build process produced a production artifact.',
      'Prefer immutable digests; preserve build metadata; protect signing identity and verify attestations at promotion.',
    ),
    questionDraft(
      'How would you scale CI for a monorepo with many independent components?',
      'Combine reliable change-impact detection with component-specific test jobs and a shared validation path for common tooling. Cache safe dependencies, parallelize independent work, and periodically run broader integration coverage so dependency mapping errors do not silently omit affected components.',
      'A change to services/billing runs billing tests and shared library checks, while nightly validation covers all services.',
      'Use this approach when full monorepo validation on every small change is too expensive.',
      'Model shared dependency edges; retain full-sweep confidence; measure queue and execution time before optimizing.',
    ),
    questionDraft(
      'How do compile-time and runtime expressions affect safe pipeline design?',
      'Compile-time template expressions determine the pipeline graph before jobs run, while runtime expressions and macros evaluate values during execution. Understanding the evaluation phase prevents missing-variable errors and unsafe assumptions when values come from queue-time input or job outputs.',
      'A template parameter selects whether a stage exists, while a runtime output variable carries a computed package version.',
      'Use the right expression phase when designing reusable pipelines with conditional structure and computed values.',
      'Compile-time expressions shape YAML; runtime values arrive later; constrain untrusted parameters and test expanded behavior.',
    ),
    questionDraft(
      'How would you coordinate deployment locks across pipelines?',
      'Use a shared protected environment or external lock keyed by the actual deployment target, not a lock scoped only to one pipeline definition. Decide how cancellation and stale queued releases are handled, and ensure the deployment can recover if the lock holder fails after partially changing resources.',
      'Two independent application pipelines targeting the same shared cluster use a common environment-level exclusive check.',
      'Use shared locking when separate teams or pipelines mutate a common environment.',
      'Lock scope must match resource scope; define timeout and cancellation behavior; combine with idempotent deployment steps.',
    ),
    questionDraft(
      'How do you handle secret rotation without interrupting releases?',
      'Use a managed secret store or federated identity where possible, and design consumers to reload or tolerate overlapping credential versions during rotation. Update the source of truth, validate access with a non-production deployment, and revoke the old credential only after dependent workloads have switched.',
      'A service accepts old and new database credentials during a controlled overlap while the pipeline updates the secret reference.',
      'Use staged rotation to prevent credential expiry from causing a production deployment outage.',
      'Prefer short-lived identity; plan overlap and revocation; never emit secret values in logs or artifacts.',
    ),
    questionDraft(
      'How would you make infrastructure deployments safe to retry?',
      'Use declarative infrastructure tooling and idempotent operations so rerunning a job converges toward the intended state. Separate planning from application where appropriate, protect state with locking and access controls, and report partial failure clearly before retrying.',
      'A pipeline validates an infrastructure plan, requires review for production, then applies the reviewed configuration.',
      'Use safe retries to recover from transient agent or network failures without duplicating resources.',
      'Idempotence limits duplicate effects; protect state and plan integrity; use approvals for high-impact changes.',
      code: r'''terraform init
terraform plan -out=release.tfplan
terraform apply release.tfplan''',
      output: 'The saved plan is applied, rather than recalculating a different plan at apply time.',
    ),
    questionDraft(
      'How would you design release governance for regulated production systems?',
      'Establish traceability from approved source change to tested artifact, deployment approval, and production outcome. Enforce separation of duties and immutable records through protected branches, environment checks, signed artifacts, and retained run evidence while keeping emergency access auditable.',
      'A release record links a reviewed pull request, artifact digest, test reports, change approval, and deployment run.',
      'Use this model when auditors or business controls require evidence of authorization and provenance.',
      'Preserve end-to-end traceability; constrain and audit exceptions; retain evidence according to policy.',
    ),
  ],
);
