
install.packages("workflowr")

library("workflowr")

wflow_git_config(user.name = "Mohamed Yusuf", user.email = "mohamedayusuf87@gmail.com")

# Start a new workflowr project
wflow_start("Responserate_mres", git = FALSE, existing = T)

# Build the site
wflow_build()

# Customize site!
#   1. Edit the R Markdown files in analysis/
#   2. Edit the theme and layout in analysis/_site.yml
#   3. Add new or copy existing R Markdown files to analysis/

# publish

wflow_publish(c("analysis/index.Rmd", "analysis/about.Rmd", "analysis/license.Rmd"),
              "Publish the initial files for myproject")

wflow_status()


wflow_git_remote("origins", "truenomad", "Response Rate meta-analysis")

wflow_git_push(dry_run = TRUE)


# add new analysis file

wflow_open("analysis/RR_Meta-analysis.Rmd")

# publish analysis

wflow_publish("analysis/RR_Meta-analysis.Rmd")

# check if up to date

wflow_status()

# Save this file witout commiting
wflow_git_commit("initial.workflor.R")

