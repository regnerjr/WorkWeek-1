# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > 500

# Warn for TODO's, we don't need to fix them all just don't let them get out of control
todoist.warn_for_todos
todoist.print_todos_table

swiftlint.lint_files
swiftlint.lint_files inline_mode: true