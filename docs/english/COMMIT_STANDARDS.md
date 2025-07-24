# Commit Standards 📜

According to the **[Conventional Commits](https://www.conventionalcommits.org/en/)** documentation, semantic commits are a simple convention for commit messages. This convention defines a set of rules to create an explicit commit history, which makes it easier to create automated tools.

These commits will help you and your team understand more easily what changes were made in the code that was committed.

This identification occurs through a word and emoji that identifies whether that commit represents a code change, package update, documentation, visual change, test...

## Type and Description 🦄

Semantic commits have the structural elements below (types), which inform the intention of your commit to the user of your code.

- `feat` - Commits of type feat indicate that your code snippet is including a **new feature** (relates to MINOR in semantic versioning).

- `fix` - Commits of type fix indicate that your committed code snippet is **solving a problem** (bug fix), (relates to PATCH in semantic versioning).

- `docs` - Commits of type docs indicate that there were **changes in documentation**, such as in your repository's Readme. (Does not include code changes).

- `test` - Commits of type test are used when **changes in tests** are made, whether creating, changing or deleting unit tests. (Does not include code changes)

- `build` - Commits of type build are used when modifications are made to **build files and dependencies**.

- `perf` - Commits of type perf serve to identify any code changes that are related to **performance**.

- `style` - Commits of type style indicate that there were changes regarding **code formatting**, semicolons, trailing spaces, lint... (Does not include code changes).

- `refactor` - Commits of type refactor refer to changes due to **refactorings that do not change functionality**, such as a change in the format of how a certain part of the screen is processed, but which maintained the same functionality, or performance improvements due to a code review.

- `chore` - Commits of type chore indicate **updates of build tasks**, administrator configurations, packages... such as adding a package to gitignore. (Does not include code changes)

- `ci` - Commits of type ci indicate changes related to **continuous integration**.

- `raw` - Commits of type raw indicate changes related to configuration files, data, features, parameters.

- `cleanup` - Commits of type cleanup are used to remove commented code, unnecessary snippets or any other form of source code cleaning, aiming to improve its readability and maintainability.

- `remove` - Commits of type remove indicate the deletion of obsolete or unused files, directories or functionalities, reducing the project's size and complexity and keeping it more organized.

## 🛠️ How to install the `commit-msg.sh` file to validate commit messages with conventional commits

### Step 1: Make sure Git is installed 🌟

First, check if Git is installed on your machine. Open the terminal and run:

```bash
git --version
```

If you get a Git version as response, you're all set! Otherwise, download and install Git here: [Git Downloads](https://git-scm.com/downloads).

### Step 2: Locate the `commit-msg.sh` file 📂

The `commit-msg.sh` file should be available in your project repository or in a specific directory. Make sure it's accessible. If it's not, download or clone the repository where it's located.

For example:

```bash
git clone https://github.com/your-repository/project.git
cd project
```

### Step 3: Create the `.git/hooks` directory (if it doesn't exist yet) 📁

Git hooks are located in the `.git/hooks` directory. Check if it exists in your project:

```bash
ls -la .git/hooks
```

If the directory doesn't exist, create it:

```bash
mkdir -p .git/hooks
```

### Step 4: Copy the `commit-msg.sh` file to the `.git/hooks` directory 📋

Copy the `commit-msg.sh` file to the `.git/hooks` directory and rename it to `commit-msg` (without extension):

```bash
cp path/to/commit-msg.sh .git/hooks/commit-msg
```

> **Note:** Replace `path/to/commit-msg.sh` with the actual path of the file.

### Step 5: Give execution permission to the script ✅

For Git to be able to execute the script, you need to give execution permission:

```bash
chmod +x .git/hooks/commit-msg
```

### Step 6: Test the commit hook 💻

Now, try making a commit in your project. For example:

```bash
git add .
git commit -m "feat: add xyz functionality"
```

If the commit message follows the **Conventional Commits** pattern, the commit will be accepted. Otherwise, the hook will block the commit and display an error message.

### Step 7: Customize the script (optional) 🎨

If necessary, open the `.git/hooks/commit-msg` file in a text editor and customize the validation rules to meet your project's needs.

## Recommendations 🎉

- Add a consistent type with the content title.
- We recommend that the first line should have a maximum of 4 words.
- To describe in detail, use the commit description.
- Use an emoji at the beginning of the commit message representing the commit.
- Links must be added in their most authentic form, that is: without link shorteners and affiliate links.

## Commit Complements 💻

- **Footer:** information about the reviewer and card number in Trello or Jira. Example: Reviewed-by: John Doe Refs #133

- **Body:** more precise descriptions of what is contained in the commit, presenting impacts and the reasons why changes were employed in the code, as well as essential instructions for future interventions. Example: see the issue for details on typos fixed.

- **Descriptions:** a succinct description of the change. Example: correct minor typos in code

## Emoji Patterns 💈

<table>
  <thead>
    <tr>
      <th>Commit Type</th>
      <th>Emoji</th>
      <th>Keyword</th>
    </tr>
  </thead>
 <tbody>
    <tr>
      <td>Accessibility</td>
      <td>♿ <code>:wheelchair:</code></td>
      <td></td>
    </tr>
    <tr>
      <td>Adding a test</td>
      <td>✅ <code>:white_check_mark:</code></td>
      <td><code>test</code></td>
    </tr>
    <tr>
      <td>Updating submodule version</td>
      <td>⬆️ <code>:arrow_up:</code></td>
      <td></td>
    </tr>
    <tr>
      <td>Downgrading submodule version</td>
      <td>⬇️ <code>:arrow_down:</code></td>
      <td></td>
    </tr>
    <tr>
      <td>Adding a dependency</td>
      <td>➕ <code>:heavy_plus_sign:</code></td>
      <td><code>build</code></td>
    </tr>
    <tr>
      <td>Code review changes</td>
      <td>👌 <code>:ok_hand:</code></td>
      <td><code>style</code></td>
    </tr>
    <tr>
      <td>Animations and transitions</td>
      <td>💫 <code>:dizzy:</code></td>
      <td></td>
    </tr>
    <tr>
      <td>Bugfix</td>
      <td>🐛 <code>:bug:</code></td>
      <td><code>fix</code></td>
    </tr>
    <tr>
      <td>Comments</td>
      <td>💡 <code>:bulb:</code></td>
      <td><code>docs</code></td>
    </tr>
    <tr>
      <td>Initial commit</td>
      <td>🎉 <code>:tada:</code></td>
      <td><code>init</code></td>
    </tr>
    <tr>
      <td>Configuration</td>
      <td>🔧 <code>:wrench:</code></td>
      <td><code>chore</code></td>
    </tr>
    <tr>
      <td>Deploy</td>
      <td>🚀 <code>:rocket:</code></td>
      <td></td>
    </tr>
    <tr>
      <td>Documentation</td>
      <td>📚 <code>:books:</code></td>
      <td><code>docs</code></td>
    </tr>
    <tr>
      <td>Work in progress</td>
      <td>🚧 <code>:construction:</code></td>
      <td></td>
    </tr>
    <tr>
      <td>Interface styling</td>
      <td>💄 <code>:lipstick:</code></td>
      <td><code>feat</code></td>
    </tr>
    <tr>
      <td>Infrastructure</td>
      <td>🧱 <code>:bricks:</code></td>
      <td><code>ci</code></td>
    </tr>
    <tr>
      <td>Ideas list (tasks)</td>
      <td>🔜 <code> :soon: </code></td>
      <td></td>
    </tr>
    <tr>
      <td>Move/Rename</td>
      <td>🚚 <code>:truck:</code></td>
      <td><code>chore</code></td>
    </tr>
    <tr>
      <td>New feature</td>
      <td>✨ <code>:sparkles:</code></td>
      <td><code>feat</code></td>
    </tr>
    <tr>
      <td>Package.json in JS</td>
      <td>📦 <code>:package:</code></td>
      <td><code>build</code></td>
    </tr>
    <tr>
      <td>Performance</td>
      <td>⚡ <code>:zap:</code></td>
      <td><code>perf</code></td>
    </tr>
    <tr>
        <td>Refactoring</td>
        <td>♻️ <code>:recycle:</code></td>
        <td><code>refactor</code></td>
    </tr>
    <tr>
      <td>Code cleanup</td>
      <td>🧹 <code>:broom:</code></td>
      <td><code>cleanup</code></td>
    </tr>
    <tr>
      <td>Removing a file</td>
      <td>🗑️ <code>:wastebasket:</code></td>
      <td><code>remove</code></td>
    </tr>
    <tr>
      <td>Removing a dependency</td>
      <td>➖ <code>:heavy_minus_sign:</code></td>
      <td><code>build</code></td>
    </tr>
    <tr>
      <td>Responsiveness</td>
      <td>📱 <code>:iphone:</code></td>
      <td></td>
    </tr>
    <tr>
      <td>Reverting changes</td>
      <td>💥 <code>:boom:</code></td>
      <td><code>fix</code></td>
    </tr>
    <tr>
      <td>Security</td>
      <td>🔒️ <code>:lock:</code></td>
      <td></td>
    </tr>
    <tr>
      <td>SEO</td>
      <td>🔍️ <code>:mag:</code></td>
      <td></td>
    </tr>
    <tr>
      <td>Version tag</td>
      <td>🔖 <code>:bookmark:</code></td>
      <td></td>
    </tr>
    <tr>
      <td>Passing tests</td>
      <td>✔️ <code>:heavy_check_mark:</code></td>
      <td><code>test</code></td>
    </tr>
    <tr>
      <td>Tests</td>
      <td>🧪 <code>:test_tube:</code></td>
      <td><code>test</code></td>
    </tr>
    <tr>
      <td>Text</td>
      <td>📝 <code>:pencil:</code></td>
      <td></td>
    </tr>
    <tr>
      <td>Typing</td>
      <td>🏷️ <code>:label:</code></td>
      <td></td>
    </tr>
    <tr>
      <td>Error handling</td>
      <td>🥅 <code>:goal_net:</code></td>
      <td></td>
    </tr>
    <tr>
      <td>Data</td>
      <td>🗃️ <code>:card_file_box:</code></td>
      <td><code>raw</code></td>
    </tr>
  </tbody>
</table>

## 💻 Examples

<table>
  <thead>
    <tr>
      <th>Git Command</th>
      <th>GitHub Result</th>
    </tr>
  </thead>
 <tbody>
    <tr>
      <td>
        <code>git commit -m ":tada: Initial commit"</code>
      </td>
      <td>🎉 Initial commit</td>
    </tr>
    <tr>
      <td>
        <code>git commit -m ":books: docs: README update"</code>
      </td>
      <td>📚 docs: README update</td>
    </tr>
    <tr>
      <td>
        <code>git commit -m ":bug: fix: Infinite loop on line 50"</code>
      </td>
      <td>🐛 fix: Infinite loop on line 50</td>
    </tr>
    <tr>
      <td>
        <code>git commit -m ":sparkles: feat: Login page"</code>
      </td>
      <td>✨ feat: Login page</td>
    </tr>
    <tr>
      <td>
        <code>git commit -m ":bricks: ci: Dockerfile modification"</code>
      </td>
      <td>🧱 ci: Dockerfile modification</td>
    </tr>
    <tr>
      <td>
        <code>git commit -m ":recycle: refactor: Converting to arrow functions"</code>
      </td>
      <td>♻️ refactor: Converting to arrow functions</td>
    </tr>
    <tr>
      <td>
        <code>git commit -m ":zap: perf: Response time improvement"</code>
      </td>
      <td>⚡ perf: Response time improvement</td>
    </tr>
    <tr>
      <td>
        <code>git commit -m ":boom: fix: Reverting inefficient changes"</code>
      </td>
      <td>💥 fix: Reverting inefficient changes</td>
    </tr>
    <tr>
      <td>
        <code>git commit -m ":lipstick: feat: Form CSS styling"</code>
      </td>
      <td>💄 feat: Form CSS styling</td>
    </tr>
    <tr>
      <td>
        <code>git commit -m ":test_tube: test: Creating new test"</code>
      </td>
      <td>🧪 test: Creating new test</td>
    </tr>
    <tr>
      <td>
        <code>git commit -m ":bulb: docs: Comments about LoremIpsum() function"</code>
      </td>
      <td>💡 docs: Comments about LoremIpsum() function</td>
    </tr>
    <tr>
      <td>
        <code>git commit -m ":card_file_box: raw: RAW Data from year yyyy"</code>
      </td>
      <td>🗃️ raw: RAW Data from year yyyy</td>
    </tr>
    <tr>
      <td>
        <code>git commit -m ":broom: cleanup: Removing commented code blocks and unused variables in form validation function"</code>
      </td>
      <td>🧹 cleanup: Removing commented code blocks and unused variables in form validation function</td>
    </tr>
    <tr>
      <td>
        <code>git commit -m ":wastebasket: remove: Removing unused project files to maintain organization and continuous updates"</code>
      </td>
      <td>🗑️ remove: Removing unused project files to maintain organization and continuous updates</td>
    </tr>
  </tbody>
</table>

# Main Git Commands 📜

- `git clone repository-url-on-github` - Clones an existing remote repository from GitHub to your local environment.

- `git init` - Initializes a new Git repository in the current directory.

- `git add .` - Adds all files and changes in the current directory to the staging area (preparing them for commit).

- `git commit -m "commit message"` - Records the changes added to the staging area with a descriptive message about what was modified.

- `git branch -M main` - Renames the current branch (master) to main. The -M is used to force the rename, moving the branch if necessary.

- `git remote add origin https://github.com/username/repository-name.git` - Adds a remote repository called origin to the local repository. Use `https://github.com/username` to configure the remote repository with HTTPS or `git@github.com:username` to configure with SSH.

- `git push -u origin main` - Sends commits from the main branch of the local repository to the remote origin repository and sets main as the default branch for future push and pull. The -u (or --set-upstream) configures the upstream branch to facilitate next git push and git pull commands and eliminate the need to specify the branch.

- `git remote add origin git@github.com:username/project.git` `git branch -M main` `git push -u origin main` - When you already have a local repository and want to connect it to a remote repository on GitHub, adds the remote repository, renames the main branch to main and sends the initial commits.

- `git fetch` - Fetches all updates from the remote repository without integrating them into the current branch. This updates remote references.

- `git pull origin main` - Updates the local main branch with changes from the remote origin repository. Combines git fetch and git merge.

- `git push --force-with-lease` - Safer way to force sending local changes to the remote repository. Checks if there have been changes made by other collaborators since your last local update, avoiding accidentally overwriting others' work.

- `git revert commit_id_to_be_reverted` - Creates a new commit that undoes the changes made by the specified commit, preserving history. Useful for safely undoing changes without rewriting history.

- `git reset --hard previous_commit_id_to_commit_to_be_deleted` - Resets the repository to the state of the specified commit, deleting all changes made after that commit. Ideal for local use. To synchronize remotely, use `git push --force-with-lease` afterwards.

- `git commit --amend -m "rewritten_message"` - Changes the message of the last commit. After using this command, synchronize remotely with `git push --force-with-lease`.

- `git cherry-pick COMMIT_HASH` - Used to get a specific commit. Usage example: Imagine you have two branches (main) and (develop) and in the second you have 3 commits but want to get only the first commit from it, with the use of cherry-pick you can.

- `git switch <branch>` - Switches to a different branch in the local repository. Use `git switch -c <branch>` to create and switch to a new branch.

# Glossary 📖

- `fork` - Copy of a repository to your own GitHub account. This creates a new repository in your account that is independent of the original, allowing you to make changes without affecting the original repository.

- `issues` - Tool used to manage tasks, new feature requests and bug fixes in open source projects. Issues should be described and listed, allowing collaborators to discuss and track their progress.

- `pull request` - Mechanism used to submit proposed changes to the original repository. A pull request is a request for project maintainers to review and potentially incorporate the changes. The pull request will go through an evaluation process and can be accepted or rejected.

- `gist` - Tool that allows sharing code snippets without the need to create a complete repository. Gists can be shared publicly or privately.