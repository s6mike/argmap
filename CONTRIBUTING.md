# Contributing to Argmap

<details open>
<summary>
<em>Collapsible Section: <strong>Table of Contents</strong></em>
</summary>
<br />
<!-- TOC -->

- [Contributing to Argmap](#contributing-to-argmap)
  - [Suggestions and Improvements](#suggestions-and-improvements)
    - [Reporting bugs](#reporting-bugs)
    - [How to suggest a feature or enhancement](#how-to-suggest-a-feature-or-enhancement)
  - [How to Contribute Code](#how-to-contribute-code)
    - [Any contributions you make will be under the MIT Software License](#any-contributions-you-make-will-be-under-the-mit-software-license)
    - [This repo uses Github Flow: all code changes happen through pull requests](#this-repo-uses-github-flow-all-code-changes-happen-through-pull-requests)
  - [Running Tests](#running-tests)
  - [Additional Resources](#additional-resources)

<!-- /TOC -->
---------------------------
</details>

Hello!

As I write this, I tried out [`dsanson/argmap`](https://github.com/dsanson/argmap) only 10 days ago and that was my first time using Lua. I made my first ever pull request 4 days later.

So I'm still very much learning how to do this, and I could use all the help I can get! :)

There are many ways to contribute, from writing tutorials, improving the documentation, submitting bug reports and feature requests, commenting on issues, or writing code which can be incorporated into Argmap itself.

## Suggestions and Improvements

Anyone can submit an issue to [Issues · s6mike/argmap](https://github.com/s6mike/argmap/issues) or comment on an existing thread. Common reasons are to:

- Suggest features.
- Report bugs.
- Request help with difficult use cases.
- Ask questions.

### Reporting bugs

Think you found a bug? Please check [the list of open issues](https://github.com/s6mike/argmap/issues) to see if your bug has already been reported. If it hasn't please [submit a new issue](https://github.com/s6mike/argmap/issues/new).

Here are a few tips for writing *great* bug reports:

- Only include one bug per issue. If you have discovered two bugs, please file two issues.
- Describe the specific problem as clearly and concisely as possible. (e.g. do say "argmap2mup breaks with error X when I try and convert this file: Y", don't say "getting an error").
- Include the steps to reproduce the bug, what you expected to happen, and what happened instead.
- If you can, please install the latest GitHub version and its dependencies, and verify that the issue still persists.
- Include what version of the project you're using, as well as any relevant dependencies: Use `luarocks list > luarocks_list.txt` to get a list of lua modules and versions.
- Even if you don't know how to fix the bug, including a failing test may help others track it down.

### How to suggest a feature or enhancement

If you find yourself wishing for a feature that doesn't exist in Argmap, you are probably not alone. There are bound to be others out there with similar needs. Many of the features that Argmap has today have been added because our users saw the need.

Feature requests are welcome. Please take a moment to find out whether your idea fits with the scope and goals of the project. It's up to you to make a strong case to convince the project's developers of the merits of this feature.

Please provide as much context as possible, including describing the problem you're trying to solve.

[Open an issue](https://github.com/s6mike/argmap/issues/new) which describes the feature you would like to see, why you want it, how it should work, etc.

## How to Contribute Code

### Any contributions you make will be under the MIT Software License

In short, when you submit code changes, your submissions are understood to be under the same [MIT License](LICENSE) that covers the project. Feel free to contact the maintainers if that's a concern.

### This repo uses [Github Flow](https://guides.github.com/introduction/flow/index.html): all code changes happen through pull requests

Pull requests are the best way to propose changes to the codebase (we use [Github Flow](https://guides.github.com/introduction/flow/index.html)). We actively welcome your pull requests:

1. [Open an issue](https://github.com/s6mike/argmap/issues/new) for the change if there isn't one already. If you are making visual changes, include a screenshot of what the affected element looks like before the change. And if possible a mockup of what is planned after.
2. [Fork](https://github.com/s6mike/argmap/fork) and clone the project.
3. Create a new branch: `git checkout -b [my-branch-name]`. Note that most of my fixes and improvements are currently on the `bugfixes` branch, while the changes on the master are much more conservative. So it's worth discussing in the issue which branch to base yours on.
4. Make your change, add tests, and make sure the tests still pass.
5. Push to your fork and [submit a pull request](https://github.com/s6mike/argmap/pulls).
6. Pat your self on the back and wait for your pull request to be reviewed and merged.

**Interesting in submitting your first Pull Request?** It's easy! You can learn how from this *free* series [Course - How to Contribute to an Open Source Project on GitHub from @kentcdodds on @eggheadio](https://app.egghead.io/playlists/how-to-contribute-to-an-open-source-project-on-github)

Here are a few general guidelines for proposing changes:

- Each pull request should implement **one** feature or bug fix. If you want to add or fix more than one thing, submit more than one pull request.
- Please keep your coding style consistent with what's already there:
  - For Lua formatting etc, I've been using [sumneko's Lua VSCode Extension](https://marketplace.visualstudio.com/items?itemName=sumneko.lua).
  - For Markdown formatting, I've been using [markdownlint - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint).
- Do not commit changes to files that are irrelevant to your feature or bug fix.
- If you are changing any user-facing functionality, please be sure to update the documentation.
- Write [a good commit message](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html).

## Running Tests

Some simple tests are executed here: [`test/test_scripts/tests.sh`](test/test_scripts/tests.sh).

I have also set these up to be called from a pre-commit hook.

## Additional Resources

- [Finding ways to contribute to open source on GitHub - GitHub Docs](https://docs.github.com/en/get-started/exploring-projects-on-github/finding-ways-to-contribute-to-open-source-on-github)
- [Using Pull Requests](https://help.github.com/articles/using-pull-requests/)
- [GitHub Documentation](https://docs.github.com/en)

---------------------------

This file was adapted from: [minimal/CONTRIBUTING.md at master · pages-themes/minimal](https://github.com/pages-themes/minimal/blob/master/docs/CONTRIBUTING.md) :)

Copyright 2022 Michael Hayes and the argmap contributors
SPDX-License-Identifier: MIT
