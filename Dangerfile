# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > 500

# Don't let testing shortcuts get into master by accident
raise("fdescribe left in tests") if `grep -r fdescribe specs/ `.length > 1
raise("fit left in tests") if `grep -r fit specs/ `.length > 1

toc.check
changelog.check
